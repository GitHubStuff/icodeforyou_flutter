// test/src/db_record_ops_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:since_when/since_when.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SinceWhenRecordOps', () {
    late SinceWhenDatabase db;

    setUp(() async {
      db = await SinceWhenDatabase.openInMemory();
    });

    tearDown(() async {
      await db.close();
    });

    group('create', () {
      test('returns DatabaseNotInitialized when db is closed', () async {
        await db.close();

        final result = await db.create(
          metaData: 'test',
          dataString: 'data',
          category: 'cat',
          tagTimestamps: [],
        );

        expect(result, isA<Left<SinceWhenFailure, SinceWhenRecord>>());
        result.fold(
          (failure) => expect(failure, isA<DatabaseNotInitialized>()),
          (_) => fail('Expected Left'),
        );
      });

      test('creates record successfully', () async {
        final result = await db.create(
          metaData: 'test',
          dataString: 'data',
          category: 'cat',
          tagTimestamps: [],
        );

        expect(result, isA<Right<SinceWhenFailure, SinceWhenRecord>>());
      });
    });

    group('getByCreatedTimeStamp', () {
      test('throws UnimplementedError', () async {
        expect(
          () => db.getByCreatedTimeStamp('any-timestamp'),
          throwsUnimplementedError,
        );
      });
    });

    group('getByTagTimestamp', () {
      test('returns DatabaseNotInitialized when db is closed', () async {
        await db.close();

        final result = await db.getByTagTimestamp('any-timestamp');

        expect(result, isA<Left<SinceWhenFailure, List<SinceWhenRecord>>>());
        result.fold(
          (failure) => expect(failure, isA<DatabaseNotInitialized>()),
          (_) => fail('Expected Left'),
        );
      });

      test('delegates to ReadOperations', () async {
        final result = await db.getByTagTimestamp('nonexistent');

        expect(result, isA<Right<SinceWhenFailure, List<SinceWhenRecord>>>());
      });
    });

    group('getByTagName', () {
      test('returns DatabaseNotInitialized when db is closed', () async {
        await db.close();

        final result = await db.getByTagName('any-name');

        expect(result, isA<Left<SinceWhenFailure, List<SinceWhenRecord>>>());
        result.fold(
          (failure) => expect(failure, isA<DatabaseNotInitialized>()),
          (_) => fail('Expected Left'),
        );
      });

      test('delegates to ReadOperations', () async {
        final result = await db.getByTagName('TestTag');

        expect(result, isA<Right<SinceWhenFailure, List<SinceWhenRecord>>>());
      });
    });

    group('getByTagTimestamps', () {
      test('returns DatabaseNotInitialized when db is closed', () async {
        await db.close();

        final result = await db.getByTagTimestamps(['ts1', 'ts2']);

        expect(result, isA<Left<SinceWhenFailure, List<SinceWhenRecord>>>());
        result.fold(
          (failure) => expect(failure, isA<DatabaseNotInitialized>()),
          (_) => fail('Expected Left'),
        );
      });

      test('delegates to ReadOperations with default mode', () async {
        final result = await db.getByTagTimestamps(['ts1', 'ts2']);

        expect(result, isA<Right<SinceWhenFailure, List<SinceWhenRecord>>>());
      });

      test('delegates to ReadOperations with TagMatchMode.all', () async {
        final result = await db.getByTagTimestamps(
          ['ts1', 'ts2'],
          mode: TagMatchMode.all,
        );

        expect(result, isA<Right<SinceWhenFailure, List<SinceWhenRecord>>>());
      });
    });

    group('getByTagNames', () {
      test('returns DatabaseNotInitialized when db is closed', () async {
        await db.close();

        final result = await db.getByTagNames(['Tag1', 'Tag2']);

        expect(result, isA<Left<SinceWhenFailure, List<SinceWhenRecord>>>());
        result.fold(
          (failure) => expect(failure, isA<DatabaseNotInitialized>()),
          (_) => fail('Expected Left'),
        );
      });

      test('delegates to ReadOperations with default mode', () async {
        final result = await db.getByTagNames(['Tag1', 'Tag2']);

        expect(result, isA<Right<SinceWhenFailure, List<SinceWhenRecord>>>());
      });

      test('delegates to ReadOperations with TagMatchMode.all', () async {
        final result = await db.getByTagNames(
          ['Tag1', 'Tag2'],
          mode: TagMatchMode.all,
        );

        expect(result, isA<Right<SinceWhenFailure, List<SinceWhenRecord>>>());
      });
    });

    group('getByCategory', () {
      test('throws UnimplementedError', () async {
        expect(
          () => db.getByCategory('any-category'),
          throwsUnimplementedError,
        );
      });
    });

    group('update', () {
      test('throws UnimplementedError', () async {
        final createResult = await db.create(
          metaData: 'test',
          dataString: 'data',
          category: 'cat',
          tagTimestamps: [],
        );

        final record = createResult.getOrElse(
          () => throw Exception('Setup failed'),
        );

        expect(() => db.update(record), throwsUnimplementedError);
      });
    });

    group('markReviewed', () {
      test('throws UnimplementedError', () async {
        expect(
          () => db.markReviewed('any-timestamp'),
          throwsUnimplementedError,
        );
      });
    });

    group('delete', () {
      test('throws UnimplementedError', () async {
        expect(
          () => db.delete('any-timestamp'),
          throwsUnimplementedError,
        );
      });
    });

    group('deleteWithDescendants', () {
      test('throws UnimplementedError', () async {
        expect(
          () => db.deleteWithDescendants('any-timestamp'),
          throwsUnimplementedError,
        );
      });
    });

    group('exportToString', () {
      test('throws UnimplementedError', () async {
        expect(() => db.exportToString(), throwsUnimplementedError);
      });
    });

    group('importFromString', () {
      test('throws UnimplementedError with default mode', () async {
        expect(
          () => db.importFromString('{}'),
          throwsUnimplementedError,
        );
      });

      test('throws UnimplementedError with replace mode', () async {
        expect(
          () => db.importFromString(
            '{}',
            mode: SinceWhenImportMode.replace,
          ),
          throwsUnimplementedError,
        );
      });
    });

    group('exportToFile', () {
      test('throws UnimplementedError', () async {
        expect(
          () => db.exportToFile(path: '/tmp/export.json'),
          throwsUnimplementedError,
        );
      });
    });

    group('importFromFile', () {
      test('throws UnimplementedError with default mode', () async {
        expect(
          () => db.importFromFile(path: '/tmp/import.json'),
          throwsUnimplementedError,
        );
      });

      test('throws UnimplementedError with replace mode', () async {
        expect(
          () => db.importFromFile(
            path: '/tmp/import.json',
            mode: SinceWhenImportMode.replace,
          ),
          throwsUnimplementedError,
        );
      });
    });
  });
}
