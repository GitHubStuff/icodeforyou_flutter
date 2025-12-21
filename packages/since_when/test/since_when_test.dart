// icodeforyou_flutter/packages/since_when/test/since_when_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:since_when/since_when.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize FFI for desktop testing
  setUpAll(() {
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

    group('create', () {
      test('creates a root record with correct timestamps', () async {
        final result = await db.create(
          metaData: 'Test meta',
          dataString: 'Test data',
          category: 'test',
          tags: ['tag1', 'tag2'],
        );

        result.fold(
          (failure) => fail('Should have succeeded: $failure'),
          (record) {
            expect(record.id, greaterThan(0));
            expect(record.metaData, equals('Test meta'));
            expect(record.dataString, equals('Test data'));
            expect(record.category, equals('test'));
            expect(record.tags, equals(['tag1', 'tag2']));
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
          tags: [],
        );

        final parent = parentResult.getOrElse(() => throw Exception());

        // Create first child
        final child1Result = await db.create(
          metaData: 'Child 1',
          dataString: 'Child 1 data',
          category: 'test',
          tags: [],
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
          tags: [],
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
          tags: [],
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
          tags: [],
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
            tags: [],
          ),
          db.create(
            metaData: 'Record 2',
            dataString: 'Data 2',
            category: 'test',
            tags: [],
          ),
          db.create(
            metaData: 'Record 3',
            dataString: 'Data 3',
            category: 'test',
            tags: [],
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
  });
}
