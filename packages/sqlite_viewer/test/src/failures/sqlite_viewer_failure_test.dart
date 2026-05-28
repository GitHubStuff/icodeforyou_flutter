// test/src/failures/sqlite_viewer_failure_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  group('ViewerDatabaseNotOpen', () {
    test('has expected message', () {
      const failure = ViewerDatabaseNotOpen();
      expect(failure.message, 'Database is not open');
    });

    test('equality holds across instances', () {
      expect(
        const ViewerDatabaseNotOpen(),
        equals(const ViewerDatabaseNotOpen()),
      );
    });

    test('props uses the default base message', () {
      const failure = ViewerDatabaseNotOpen();
      expect(failure.props, ['Database is not open']);
    });
  });

  group('ViewerTableNotFound', () {
    test('formats message with tableName', () {
      const failure = ViewerTableNotFound('users');
      expect(failure.message, 'Table not found: users');
    });

    test('exposes tableName property', () {
      const failure = ViewerTableNotFound('users');
      expect(failure.tableName, 'users');
    });

    test('equality respects tableName', () {
      expect(
        const ViewerTableNotFound('a'),
        equals(const ViewerTableNotFound('a')),
      );
      expect(
        const ViewerTableNotFound('a'),
        isNot(equals(const ViewerTableNotFound('b'))),
      );
    });

    test('props includes tableName', () {
      const failure = ViewerTableNotFound('users');
      expect(failure.props, ['users']);
    });
  });

  group('ViewerInvalidQuery', () {
    test('uses default message when reason is null', () {
      const failure = ViewerInvalidQuery('DROP TABLE x');
      expect(
        failure.message,
        'Invalid query: only SELECT and WITH statements are allowed',
      );
    });

    test('uses reason when provided', () {
      const failure = ViewerInvalidQuery('foo', 'because');
      expect(failure.message, 'because');
    });

    test('exposes query and reason properties', () {
      const failure = ViewerInvalidQuery('foo', 'because');
      expect(failure.query, 'foo');
      expect(failure.reason, 'because');
    });

    test('equality respects query and reason', () {
      expect(
        const ViewerInvalidQuery('q', 'r'),
        equals(const ViewerInvalidQuery('q', 'r')),
      );
      expect(
        const ViewerInvalidQuery('q', 'r'),
        isNot(equals(const ViewerInvalidQuery('q', 'other'))),
      );
    });

    test('props includes query and reason', () {
      const failure = ViewerInvalidQuery('q', 'r');
      expect(failure.props, ['q', 'r']);
    });
  });

  group('ViewerQueryFailed', () {
    test('formats message with error', () {
      const failure = ViewerQueryFailed('SELECT *', 'syntax error');
      expect(failure.message, 'Query failed: syntax error');
    });

    test('exposes query and error', () {
      const failure = ViewerQueryFailed('SELECT *', 'syntax error');
      expect(failure.query, 'SELECT *');
      expect(failure.error, 'syntax error');
    });

    test('equality respects fields', () {
      expect(
        const ViewerQueryFailed('q', 'e'),
        equals(const ViewerQueryFailed('q', 'e')),
      );
      expect(
        const ViewerQueryFailed('q', 'e'),
        isNot(equals(const ViewerQueryFailed('q', 'x'))),
      );
    });

    test('props includes query and error', () {
      const failure = ViewerQueryFailed('q', 'e');
      expect(failure.props, ['q', 'e']);
    });
  });

  group('ViewerPragmaFailed', () {
    test('formats message with table, key, error', () {
      const failure = ViewerPragmaFailed('users', 'tableInfo', 'oops');
      expect(failure.message, 'Failed to get tableInfo for users: oops');
    });

    test('exposes tableName, pragmaKey, error', () {
      const failure = ViewerPragmaFailed('users', 'tableInfo', 'oops');
      expect(failure.tableName, 'users');
      expect(failure.pragmaKey, 'tableInfo');
      expect(failure.error, 'oops');
    });

    test('equality respects fields', () {
      expect(
        const ViewerPragmaFailed('t', 'k', 'e'),
        equals(const ViewerPragmaFailed('t', 'k', 'e')),
      );
      expect(
        const ViewerPragmaFailed('t', 'k', 'e'),
        isNot(equals(const ViewerPragmaFailed('t', 'k', 'x'))),
      );
    });

    test('props includes all fields', () {
      const failure = ViewerPragmaFailed('t', 'k', 'e');
      expect(failure.props, ['t', 'k', 'e']);
    });
  });

  group('ViewerMetadataFailed', () {
    test('formats message with operation and error', () {
      const failure = ViewerMetadataFailed('version', 'broken');
      expect(failure.message, 'Failed to get version: broken');
    });

    test('exposes operation and error', () {
      const failure = ViewerMetadataFailed('version', 'broken');
      expect(failure.operation, 'version');
      expect(failure.error, 'broken');
    });

    test('equality respects fields', () {
      expect(
        const ViewerMetadataFailed('op', 'e'),
        equals(const ViewerMetadataFailed('op', 'e')),
      );
      expect(
        const ViewerMetadataFailed('op', 'e'),
        isNot(equals(const ViewerMetadataFailed('op', 'x'))),
      );
    });

    test('props includes operation and error', () {
      const failure = ViewerMetadataFailed('op', 'e');
      expect(failure.props, ['op', 'e']);
    });
  });

  group('ViewerUnexpectedError', () {
    test('formats message with error', () {
      const failure = ViewerUnexpectedError('boom');
      expect(failure.message, 'Unexpected error: boom');
    });

    test('exposes error', () {
      const failure = ViewerUnexpectedError('boom');
      expect(failure.error, 'boom');
    });

    test('equality respects error', () {
      expect(
        const ViewerUnexpectedError('a'),
        equals(const ViewerUnexpectedError('a')),
      );
      expect(
        const ViewerUnexpectedError('a'),
        isNot(equals(const ViewerUnexpectedError('b'))),
      );
    });

    test('props includes error', () {
      const failure = ViewerUnexpectedError('boom');
      expect(failure.props, ['boom']);
    });
  });

  group('SqliteViewerFailure sealed hierarchy', () {
    test('all subtypes are SqliteViewerFailure', () {
      expect(const ViewerDatabaseNotOpen(), isA<SqliteViewerFailure>());
      expect(const ViewerTableNotFound('x'), isA<SqliteViewerFailure>());
      expect(const ViewerInvalidQuery('x'), isA<SqliteViewerFailure>());
      expect(const ViewerQueryFailed('x', 'y'), isA<SqliteViewerFailure>());
      expect(
        const ViewerPragmaFailed('x', 'y', 'z'),
        isA<SqliteViewerFailure>(),
      );
      expect(const ViewerMetadataFailed('x', 'y'), isA<SqliteViewerFailure>());
      expect(const ViewerUnexpectedError('x'), isA<SqliteViewerFailure>());
    });
  });
}
