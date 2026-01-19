// test/src/failures/sqlite_viewer_failure_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  group('SqliteViewerFailure', () {
    group('ViewerDatabaseNotOpen', () {
      test('message returns expected string', () {
        const failure = ViewerDatabaseNotOpen();
        expect(failure.message, 'Database is not open');
      });

      test('props contains message', () {
        const failure = ViewerDatabaseNotOpen();
        expect(failure.props, ['Database is not open']);
      });

      test('equality works correctly', () {
        const failure1 = ViewerDatabaseNotOpen();
        const failure2 = ViewerDatabaseNotOpen();
        expect(failure1, equals(failure2));
      });
    });

    group('ViewerTableNotFound', () {
      test('message returns expected string with table name', () {
        const failure = ViewerTableNotFound('users');
        expect(failure.message, 'Table not found: users');
      });

      test('props contains tableName', () {
        const failure = ViewerTableNotFound('users');
        expect(failure.props, ['users']);
      });

      test('tableName is accessible', () {
        const failure = ViewerTableNotFound('products');
        expect(failure.tableName, 'products');
      });

      test('equality works correctly', () {
        const failure1 = ViewerTableNotFound('users');
        const failure2 = ViewerTableNotFound('users');
        const failure3 = ViewerTableNotFound('products');
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('ViewerInvalidQuery', () {
      test('message returns default when reason is null', () {
        const failure = ViewerInvalidQuery('DROP TABLE users');
        expect(
          failure.message,
          'Invalid query: only SELECT and WITH statements are allowed',
        );
      });

      test('message returns reason when provided', () {
        const failure = ViewerInvalidQuery(
          'DROP TABLE users',
          'Custom reason',
        );
        expect(failure.message, 'Custom reason');
      });

      test('props contains query and reason', () {
        const failure = ViewerInvalidQuery('query', 'reason');
        expect(failure.props, ['query', 'reason']);
      });

      test('props contains query and null when reason is null', () {
        const failure = ViewerInvalidQuery('query');
        expect(failure.props, ['query', null]);
      });

      test('query is accessible', () {
        const failure = ViewerInvalidQuery('SELECT *', 'reason');
        expect(failure.query, 'SELECT *');
        expect(failure.reason, 'reason');
      });

      test('equality works correctly', () {
        const failure1 = ViewerInvalidQuery('q1', 'r1');
        const failure2 = ViewerInvalidQuery('q1', 'r1');
        const failure3 = ViewerInvalidQuery('q2', 'r1');
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('ViewerQueryFailed', () {
      test('message returns expected string', () {
        const failure = ViewerQueryFailed('SELECT *', 'syntax error');
        expect(failure.message, 'Query failed: syntax error');
      });

      test('props contains query and error', () {
        const failure = ViewerQueryFailed('query', 'error');
        expect(failure.props, ['query', 'error']);
      });

      test('query and error are accessible', () {
        const failure = ViewerQueryFailed('SELECT *', 'no such table');
        expect(failure.query, 'SELECT *');
        expect(failure.error, 'no such table');
      });

      test('equality works correctly', () {
        const failure1 = ViewerQueryFailed('q', 'e');
        const failure2 = ViewerQueryFailed('q', 'e');
        const failure3 = ViewerQueryFailed('q', 'e2');
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('ViewerPragmaFailed', () {
      test('message returns expected string', () {
        const failure = ViewerPragmaFailed('users', 'table_info', 'error');
        expect(
          failure.message,
          'Failed to get table_info for users: error',
        );
      });

      test('props contains tableName, pragmaKey, and error', () {
        const failure = ViewerPragmaFailed('t', 'p', 'e');
        expect(failure.props, ['t', 'p', 'e']);
      });

      test('fields are accessible', () {
        const failure = ViewerPragmaFailed('users', 'index_list', 'err');
        expect(failure.tableName, 'users');
        expect(failure.pragmaKey, 'index_list');
        expect(failure.error, 'err');
      });

      test('equality works correctly', () {
        const failure1 = ViewerPragmaFailed('t', 'p', 'e');
        const failure2 = ViewerPragmaFailed('t', 'p', 'e');
        const failure3 = ViewerPragmaFailed('t2', 'p', 'e');
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('ViewerMetadataFailed', () {
      test('message returns expected string', () {
        const failure = ViewerMetadataFailed('version', 'db closed');
        expect(failure.message, 'Failed to get version: db closed');
      });

      test('props contains operation and error', () {
        const failure = ViewerMetadataFailed('op', 'err');
        expect(failure.props, ['op', 'err']);
      });

      test('fields are accessible', () {
        const failure = ViewerMetadataFailed('size', 'failed');
        expect(failure.operation, 'size');
        expect(failure.error, 'failed');
      });

      test('equality works correctly', () {
        const failure1 = ViewerMetadataFailed('o', 'e');
        const failure2 = ViewerMetadataFailed('o', 'e');
        const failure3 = ViewerMetadataFailed('o2', 'e');
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('ViewerUnexpectedError', () {
      test('message returns expected string', () {
        const failure = ViewerUnexpectedError('Something went wrong');
        expect(failure.message, 'Unexpected error: Something went wrong');
      });

      test('props contains error', () {
        const failure = ViewerUnexpectedError('err');
        expect(failure.props, ['err']);
      });

      test('error is accessible', () {
        const failure = ViewerUnexpectedError('crash');
        expect(failure.error, 'crash');
      });

      test('equality works correctly', () {
        const failure1 = ViewerUnexpectedError('e');
        const failure2 = ViewerUnexpectedError('e');
        const failure3 = ViewerUnexpectedError('e2');
        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });
  });
}
