// test/since_when_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:since_when/since_when.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize FFI for desktop testing
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  group('SinceWhenDatabase', () {
    late SinceWhenDatabase db;

    setUp(() async {
      db = await SinceWhenDatabase.openInMemory();
    });

    tearDown(() async {
      await db.close();
    });

    group('initialization', () {
      test('openInMemory creates a valid database', () {
        expect(db.isOpen, isTrue);
      });

      test('openOrCreate rejects reserved database name', () async {
        final result = await SinceWhenDatabase.openOrCreate(
          dbName: 'since_when.db',
        );

        result.fold(
          (failure) => expect(failure, isA<ReservedDatabaseName>()),
          (db) => fail('Should have returned failure'),
        );
      });

      test('close closes the database', () async {
        await db.close();
        expect(db.isOpen, isFalse);
      });
    });

    group('tag glossary', () {
      test('creates a tag definition', () async {
        final result = await db.createTag(
          tagName: 'flutter',
          tagDescription: 'Flutter related',
          color: 0xFF2196F3,
        );

        result.fold(
          (failure) => fail('Should have succeeded: $failure'),
          (tag) {
            expect(tag.id, greaterThan(0));
            expect(tag.tagName, equals('flutter'));
            expect(tag.tagDescription, equals('Flutter related'));
            expect(tag.color, equals(0xFF2196F3));
            expect(tag.createdTimeStamp, isNotEmpty);
          },
        );
      });

      test('rejects duplicate tag names', () async {
        await db.createTag(
          tagName: 'flutter',
          tagDescription: 'First',
          color: 0xFF2196F3,
        );

        final result = await db.createTag(
          tagName: 'flutter',
          tagDescription: 'Second',
          color: 0xFF4CAF50,
        );

        result.fold(
          (failure) => expect(failure, isA<TagNameAlreadyExists>()),
          (_) => fail('Should have returned failure'),
        );
      });

      test('rejects empty tag names', () async {
        final result = await db.createTag(
          tagName: '',
          tagDescription: 'Empty name',
          color: 0xFF2196F3,
        );

        result.fold(
          (failure) => expect(failure, isA<InvalidTagName>()),
          (_) => fail('Should have returned failure'),
        );
      });

      test('gets all tags', () async {
        await db.createTag(
          tagName: 'tag1',
          tagDescription: 'First',
          color: 0xFF2196F3,
        );
        await db.createTag(
          tagName: 'tag2',
          tagDescription: 'Second',
          color: 0xFF4CAF50,
        );

        final result = await db.getAllTags();

        result.fold(
          (failure) => fail('Should have succeeded: $failure'),
          (tags) {
            expect(tags.length, equals(2));
            expect(tags.map((t) => t.tagName), containsAll(['tag1', 'tag2']));
          },
        );
      });

      test('updates a tag definition', () async {
        final createResult = await db.createTag(
          tagName: 'old_name',
          tagDescription: 'Old description',
          color: 0xFF2196F3,
        );
        final tag = createResult.getOrElse(() => throw Exception());

        final updateResult = await db.updateTag(
          createdTimeStamp: tag.createdTimeStamp,
          tagName: 'new_name',
          tagDescription: 'New description',
          color: 0xFF4CAF50,
        );

        updateResult.fold(
          (failure) => fail('Should have succeeded: $failure'),
          (updated) {
            expect(updated.tagName, equals('new_name'));
            expect(updated.tagDescription, equals('New description'));
            expect(updated.color, equals(0xFF4CAF50));
            expect(updated.createdTimeStamp, equals(tag.createdTimeStamp));
          },
        );
      });

      test('deletes an unused tag', () async {
        final createResult = await db.createTag(
          tagName: 'to_delete',
          tagDescription: 'Will be deleted',
          color: 0xFF2196F3,
        );
        final tag = createResult.getOrElse(() => throw Exception());

        final deleteResult = await db.deleteTag(tag.createdTimeStamp);

        deleteResult.fold(
          (failure) => fail('Should have succeeded: $failure'),
          (deleted) => expect(deleted, isTrue),
        );

        final getResult = await db.getTagByTimestamp(tag.createdTimeStamp);
        getResult.fold(
          (failure) => expect(failure, isA<TagNotFound>()),
          (_) => fail('Should have returned failure'),
        );
      });
    });

    group('create', () {
      test('creates a root record with correct timestamps', () async {
        // First create tags in glossary
        final tag1Result = await db.createTag(
          tagName: 'tag1',
          tagDescription: 'Tag 1',
          color: 0xFF2196F3,
        );
        final tag2Result = await db.createTag(
          tagName: 'tag2',
          tagDescription: 'Tag 2',
          color: 0xFF4CAF50,
        );
        final tag1 = tag1Result.getOrElse(() => throw Exception());
        final tag2 = tag2Result.getOrElse(() => throw Exception());

        final result = await db.create(
          metaData: 'Test meta',
          dataString: 'Test data',
          category: 'test',
          tagTimestamps: [tag1.createdTimeStamp, tag2.createdTimeStamp],
        );

        result.fold(
          (failure) => fail('Should have succeeded: $failure'),
          (record) {
            expect(record.id, greaterThan(0));
            expect(record.metaData, equals('Test meta'));
            expect(record.dataString, equals('Test data'));
            expect(record.category, equals('test'));
            expect(record.tags.length, equals(2));
            expect(
              record.tags.map((t) => t.tagName),
              containsAll(['tag1', 'tag2']),
            );
            expect(record.parentTimeStamp, isNull);
            expect(record.sequenceNumber, equals(0));
            expect(record.metaTimeStamp, isNull);

            // All timestamps should be equal on creation
            expect(record.reviewedTimeStamp, equals(record.createdTimeStamp));
            expect(record.editedTimeStamp, equals(record.createdTimeStamp));
          },
        );
      });

      test('creates a child record with auto-calculated sequence', () async {
        // Create parent
        final parentResult = await db.create(
          metaData: 'Parent',
          dataString: 'Parent data',
          category: 'test',
          tagTimestamps: [],
        );

        final parent = parentResult.getOrElse(() => throw Exception());

        // Create first child
        final child1Result = await db.create(
          metaData: 'Child 1',
          dataString: 'Child 1 data',
          category: 'test',
          tagTimestamps: [],
          parentTimeStamp: parent.createdTimeStamp,
        );

        final child1 = child1Result.getOrElse(() => throw Exception());
        expect(child1.parentTimeStamp, equals(parent.createdTimeStamp));
        expect(child1.sequenceNumber, equals(1));

        // Create second child
        final child2Result = await db.create(
          metaData: 'Child 2',
          dataString: 'Child 2 data',
          category: 'test',
          tagTimestamps: [],
          parentTimeStamp: parent.createdTimeStamp,
        );

        final child2 = child2Result.getOrElse(() => throw Exception());
        expect(child2.sequenceNumber, equals(2));
      });

      test('sets parentTimeStamp to null if parent does not exist', () async {
        final result = await db.create(
          metaData: 'Orphan',
          dataString: 'Orphan data',
          category: 'test',
          tagTimestamps: [],
          parentTimeStamp: 'non-existent-timestamp',
        );

        result.fold(
          (failure) => fail('Should have succeeded: $failure'),
          (record) {
            expect(record.parentTimeStamp, isNull);
            expect(record.sequenceNumber, equals(0));
          },
        );
      });

      test('creates record with empty tags', () async {
        final result = await db.create(
          metaData: 'No tags',
          dataString: 'Data',
          category: 'test',
          tagTimestamps: [],
        );

        result.fold(
          (failure) => fail('Should have succeeded: $failure'),
          (record) => expect(record.tags, isEmpty),
        );
      });

      test('ignores invalid tag timestamps', () async {
        final result = await db.create(
          metaData: 'Invalid tags',
          dataString: 'Data',
          category: 'test',
          tagTimestamps: ['non-existent-tag-timestamp'],
        );

        result.fold(
          (failure) => fail('Should have succeeded: $failure'),
          (record) => expect(record.tags, isEmpty),
        );
      });

      test('creates multiple records with unique timestamps', () async {
        final results = await Future.wait([
          db.create(
            metaData: 'Record 1',
            dataString: 'Data 1',
            category: 'test',
            tagTimestamps: [],
          ),
          db.create(
            metaData: 'Record 2',
            dataString: 'Data 2',
            category: 'test',
            tagTimestamps: [],
          ),
          db.create(
            metaData: 'Record 3',
            dataString: 'Data 3',
            category: 'test',
            tagTimestamps: [],
          ),
        ]);

        final timestamps = results
            .map((r) => r.getOrElse(() => throw Exception()))
            .map((r) => r.createdTimeStamp)
            .toSet();

        // All timestamps should be unique
        expect(timestamps.length, equals(3));
      });
    });

    group('query by tag', () {
      test('gets records by tag name', () async {
        final tagResult = await db.createTag(
          tagName: 'flutter',
          tagDescription: 'Flutter',
          color: 0xFF2196F3,
        );
        final tag = tagResult.getOrElse(() => throw Exception());

        await db.create(
          metaData: 'Record 1',
          dataString: 'Data 1',
          category: 'test',
          tagTimestamps: [tag.createdTimeStamp],
        );
        await db.create(
          metaData: 'Record 2',
          dataString: 'Data 2',
          category: 'test',
          tagTimestamps: [tag.createdTimeStamp],
        );
        await db.create(
          metaData: 'Record 3',
          dataString: 'Data 3',
          category: 'test',
          tagTimestamps: [],
        );

        final result = await db.getByTagName('flutter');

        result.fold(
          (failure) => fail('Should have succeeded: $failure'),
          (records) {
            expect(records.length, equals(2));
            expect(
              records.map((r) => r.metaData),
              containsAll(['Record 1', 'Record 2']),
            );
          },
        );
      });

      test('gets records by multiple tag names with ANY mode', () async {
        final tag1Result = await db.createTag(
          tagName: 'flutter',
          tagDescription: 'Flutter',
          color: 0xFF2196F3,
        );
        final tag2Result = await db.createTag(
          tagName: 'dart',
          tagDescription: 'Dart',
          color: 0xFF4CAF50,
        );
        final tag1 = tag1Result.getOrElse(() => throw Exception());
        final tag2 = tag2Result.getOrElse(() => throw Exception());

        await db.create(
          metaData: 'Flutter only',
          dataString: 'Data',
          category: 'test',
          tagTimestamps: [tag1.createdTimeStamp],
        );
        await db.create(
          metaData: 'Dart only',
          dataString: 'Data',
          category: 'test',
          tagTimestamps: [tag2.createdTimeStamp],
        );
        await db.create(
          metaData: 'No tags',
          dataString: 'Data',
          category: 'test',
          tagTimestamps: [],
        );

        final result = await db.getByTagNames(
          ['flutter', 'dart'],
          mode: TagMatchMode.any,
        );

        result.fold(
          (failure) => fail('Should have succeeded: $failure'),
          (records) {
            expect(records.length, equals(2));
          },
        );
      });

      test('gets records by multiple tag names with ALL mode', () async {
        final tag1Result = await db.createTag(
          tagName: 'flutter',
          tagDescription: 'Flutter',
          color: 0xFF2196F3,
        );
        final tag2Result = await db.createTag(
          tagName: 'dart',
          tagDescription: 'Dart',
          color: 0xFF4CAF50,
        );
        final tag1 = tag1Result.getOrElse(() => throw Exception());
        final tag2 = tag2Result.getOrElse(() => throw Exception());

        await db.create(
          metaData: 'Both tags',
          dataString: 'Data',
          category: 'test',
          tagTimestamps: [tag1.createdTimeStamp, tag2.createdTimeStamp],
        );
        await db.create(
          metaData: 'Flutter only',
          dataString: 'Data',
          category: 'test',
          tagTimestamps: [tag1.createdTimeStamp],
        );

        final result = await db.getByTagNames(
          ['flutter', 'dart'],
          mode: TagMatchMode.all,
        );

        result.fold(
          (failure) => fail('Should have succeeded: $failure'),
          (records) {
            expect(records.length, equals(1));
            expect(records.first.metaData, equals('Both tags'));
          },
        );
      });
    });
  });
}
