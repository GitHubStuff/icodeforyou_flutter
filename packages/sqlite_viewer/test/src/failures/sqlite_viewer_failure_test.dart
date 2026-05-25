// packages/sqlite_viewer/test/src/failures/sqlite_viewer_failure_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/src/failures/sqlite_viewer_failure.dart';

void main() {
  group('ViewerTableNotFound', () {
    test('message includes the table name', () {
      const failure = ViewerTableNotFound('users');

      expect(failure.message, 'Table not found: users');
    });

    test('value equality is based on tableName', () {
      const a = ViewerTableNotFound('users');
      const b = ViewerTableNotFound('users');
      const other = ViewerTableNotFound('posts');

      expect(a, equals(b));
      expect(a, isNot(equals(other)));
    });
  });

  group('ViewerQueryFailed', () {
    test('message includes the error detail', () {
      const failure = ViewerQueryFailed('SELECT * FROM x', 'no such table: x');

      expect(failure.message, 'Query failed: no such table: x');
    });

    test('value equality is based on query and error', () {
      const a = ViewerQueryFailed('SELECT 1', 'boom');
      const b = ViewerQueryFailed('SELECT 1', 'boom');
      const differentQuery = ViewerQueryFailed('SELECT 2', 'boom');
      const differentError = ViewerQueryFailed('SELECT 1', 'kaboom');

      expect(a, equals(b));
      expect(a, isNot(equals(differentQuery)));
      expect(a, isNot(equals(differentError)));
    });
  });

  group('ViewerPragmaFailed', () {
    test('message includes pragma key, table name, and error', () {
      const failure = ViewerPragmaFailed('users', 'table_info', 'disk I/O');

      expect(failure.message, 'Failed to get table_info for users: disk I/O');
    });

    test('value equality is based on tableName, pragmaKey, and error', () {
      const a = ViewerPragmaFailed('users', 'table_info', 'boom');
      const b = ViewerPragmaFailed('users', 'table_info', 'boom');
      const differentTable = ViewerPragmaFailed('posts', 'table_info', 'boom');
      const differentKey = ViewerPragmaFailed('users', 'index_list', 'boom');
      const differentError = ViewerPragmaFailed('users', 'table_info', 'bang');

      expect(a, equals(b));
      expect(a, isNot(equals(differentTable)));
      expect(a, isNot(equals(differentKey)));
      expect(a, isNot(equals(differentError)));
    });
  });

  group('ViewerMetadataFailed', () {
    test('message includes operation and error', () {
      const failure = ViewerMetadataFailed('sqlite_version', 'locked');

      expect(failure.message, 'Failed to get sqlite_version: locked');
    });

    test('value equality is based on operation and error', () {
      const a = ViewerMetadataFailed('size', 'boom');
      const b = ViewerMetadataFailed('size', 'boom');
      const differentOperation = ViewerMetadataFailed('path', 'boom');
      const differentError = ViewerMetadataFailed('size', 'kaboom');

      expect(a, equals(b));
      expect(a, isNot(equals(differentOperation)));
      expect(a, isNot(equals(differentError)));
    });
  });

  group('ViewerUnexpectedError', () {
    test('message includes the error detail', () {
      const failure = ViewerUnexpectedError('something exploded');

      expect(failure.message, 'Unexpected error: something exploded');
    });

    test('value equality is based on error', () {
      const a = ViewerUnexpectedError('boom');
      const b = ViewerUnexpectedError('boom');
      const other = ViewerUnexpectedError('kaboom');

      expect(a, equals(b));
      expect(a, isNot(equals(other)));
    });
  });
}
