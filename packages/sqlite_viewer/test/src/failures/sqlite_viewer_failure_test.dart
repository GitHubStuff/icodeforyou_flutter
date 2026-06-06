// test/src/failures/sqlite_viewer_failure_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

/// Returns [value] unchanged through a runtime call so the result is **not**
/// a compile-time constant expression.
///
/// Passing failure-constructor arguments through this helper forces every
/// `const` failure constructor to be invoked at runtime instead of being
/// canonicalized at compile time. Without it, const canonicalization means:
///   * constructor bodies never execute (no line hits), and
///   * `Equatable.==` short-circuits on `identical(this, other)` and never
///     reads `props`.
/// Runtime construction is what makes the LCOV line counter record the
/// constructors and getters as executed.
String nonConst(String value) => value;

void main() {
  group('ViewerDatabaseNotOpen', () {
    test('has expected message', () {
      // ignore: prefer_const_constructors — runtime instance for coverage.
      final failure = ViewerDatabaseNotOpen();
      expect(failure.message, 'Database is not open');
    });

    test('props falls through to the base [message] getter', () {
      // ignore: prefer_const_constructors — runtime instance for coverage.
      final failure = ViewerDatabaseNotOpen();
      // This subtype does not override props, so reading it exercises the
      // base SqliteViewerFailure.props => [message] getter.
      expect(failure.props, ['Database is not open']);
    });

    test('equality holds across distinct runtime instances', () {
      // ignore: prefer_const_constructors — distinct (non-identical) instances
      // force Equatable past its identical() check so props is read on both.
      final a = ViewerDatabaseNotOpen();
      // ignore: prefer_const_constructors
      final b = ViewerDatabaseNotOpen();
      expect(identical(a, b), isFalse);
      expect(a, equals(b));
    });
  });

  group('ViewerTableNotFound', () {
    test('formats message with tableName', () {
      final failure = ViewerTableNotFound(nonConst('users'));
      expect(failure.message, 'Table not found: users');
    });

    test('exposes tableName property', () {
      final failure = ViewerTableNotFound(nonConst('users'));
      expect(failure.tableName, 'users');
    });

    test('props includes tableName', () {
      final failure = ViewerTableNotFound(nonConst('users'));
      expect(failure.props, ['users']);
    });

    test('equality respects tableName across distinct instances', () {
      final a = ViewerTableNotFound(nonConst('a'));
      final b = ViewerTableNotFound(nonConst('a'));
      final c = ViewerTableNotFound(nonConst('b'));
      expect(identical(a, b), isFalse);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('ViewerInvalidQuery', () {
    test('uses default message when reason is null', () {
      final failure = ViewerInvalidQuery(nonConst('DROP TABLE x'));
      expect(
        failure.message,
        'Invalid query: only SELECT and WITH statements are allowed',
      );
      expect(failure.reason, isNull);
    });

    test('uses reason when provided', () {
      final failure = ViewerInvalidQuery(nonConst('foo'), nonConst('because'));
      expect(failure.message, 'because');
    });

    test('exposes query and reason properties', () {
      final failure = ViewerInvalidQuery(nonConst('foo'), nonConst('because'));
      expect(failure.query, 'foo');
      expect(failure.reason, 'because');
    });

    test('props includes query and reason', () {
      final failure = ViewerInvalidQuery(nonConst('q'), nonConst('r'));
      expect(failure.props, ['q', 'r']);
    });

    test('props includes query and null reason', () {
      final failure = ViewerInvalidQuery(nonConst('q'));
      expect(failure.props, ['q', null]);
    });

    test('equality respects query and reason across distinct instances', () {
      final a = ViewerInvalidQuery(nonConst('q'), nonConst('r'));
      final b = ViewerInvalidQuery(nonConst('q'), nonConst('r'));
      final c = ViewerInvalidQuery(nonConst('q'), nonConst('other'));
      expect(identical(a, b), isFalse);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('ViewerQueryFailed', () {
    test('formats message with error', () {
      final failure =
          ViewerQueryFailed(nonConst('SELECT *'), nonConst('syntax error'));
      expect(failure.message, 'Query failed: syntax error');
    });

    test('exposes query and error', () {
      final failure =
          ViewerQueryFailed(nonConst('SELECT *'), nonConst('syntax error'));
      expect(failure.query, 'SELECT *');
      expect(failure.error, 'syntax error');
    });

    test('props includes query and error', () {
      final failure = ViewerQueryFailed(nonConst('q'), nonConst('e'));
      expect(failure.props, ['q', 'e']);
    });

    test('equality respects fields across distinct instances', () {
      final a = ViewerQueryFailed(nonConst('q'), nonConst('e'));
      final b = ViewerQueryFailed(nonConst('q'), nonConst('e'));
      final c = ViewerQueryFailed(nonConst('q'), nonConst('x'));
      expect(identical(a, b), isFalse);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('ViewerPragmaFailed', () {
    test('formats message with table, key, error', () {
      final failure = ViewerPragmaFailed(
        nonConst('users'),
        nonConst('tableInfo'),
        nonConst('oops'),
      );
      expect(failure.message, 'Failed to get tableInfo for users: oops');
    });

    test('exposes tableName, pragmaKey, error', () {
      final failure = ViewerPragmaFailed(
        nonConst('users'),
        nonConst('tableInfo'),
        nonConst('oops'),
      );
      expect(failure.tableName, 'users');
      expect(failure.pragmaKey, 'tableInfo');
      expect(failure.error, 'oops');
    });

    test('props includes all fields', () {
      final failure =
          ViewerPragmaFailed(nonConst('t'), nonConst('k'), nonConst('e'));
      expect(failure.props, ['t', 'k', 'e']);
    });

    test('equality respects fields across distinct instances', () {
      final a = ViewerPragmaFailed(nonConst('t'), nonConst('k'), nonConst('e'));
      final b = ViewerPragmaFailed(nonConst('t'), nonConst('k'), nonConst('e'));
      final c = ViewerPragmaFailed(nonConst('t'), nonConst('k'), nonConst('x'));
      expect(identical(a, b), isFalse);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('ViewerMetadataFailed', () {
    test('formats message with operation and error', () {
      final failure =
          ViewerMetadataFailed(nonConst('version'), nonConst('broken'));
      expect(failure.message, 'Failed to get version: broken');
    });

    test('exposes operation and error', () {
      final failure =
          ViewerMetadataFailed(nonConst('version'), nonConst('broken'));
      expect(failure.operation, 'version');
      expect(failure.error, 'broken');
    });

    test('props includes operation and error', () {
      final failure = ViewerMetadataFailed(nonConst('op'), nonConst('e'));
      expect(failure.props, ['op', 'e']);
    });

    test('equality respects fields across distinct instances', () {
      final a = ViewerMetadataFailed(nonConst('op'), nonConst('e'));
      final b = ViewerMetadataFailed(nonConst('op'), nonConst('e'));
      final c = ViewerMetadataFailed(nonConst('op'), nonConst('x'));
      expect(identical(a, b), isFalse);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('ViewerUnexpectedError', () {
    test('formats message with error', () {
      final failure = ViewerUnexpectedError(nonConst('boom'));
      expect(failure.message, 'Unexpected error: boom');
    });

    test('exposes error', () {
      final failure = ViewerUnexpectedError(nonConst('boom'));
      expect(failure.error, 'boom');
    });

    test('props includes error', () {
      final failure = ViewerUnexpectedError(nonConst('boom'));
      expect(failure.props, ['boom']);
    });

    test('equality respects error across distinct instances', () {
      final a = ViewerUnexpectedError(nonConst('a'));
      final b = ViewerUnexpectedError(nonConst('a'));
      final c = ViewerUnexpectedError(nonConst('b'));
      expect(identical(a, b), isFalse);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('SqliteViewerFailure sealed hierarchy', () {
    test('all subtypes are SqliteViewerFailure', () {
      // ignore: prefer_const_constructors — runtime instance for coverage.
      expect(ViewerDatabaseNotOpen(), isA<SqliteViewerFailure>());
      expect(
        ViewerTableNotFound(nonConst('x')),
        isA<SqliteViewerFailure>(),
      );
      expect(
        ViewerInvalidQuery(nonConst('x')),
        isA<SqliteViewerFailure>(),
      );
      expect(
        ViewerQueryFailed(nonConst('x'), nonConst('y')),
        isA<SqliteViewerFailure>(),
      );
      expect(
        ViewerPragmaFailed(nonConst('x'), nonConst('y'), nonConst('z')),
        isA<SqliteViewerFailure>(),
      );
      expect(
        ViewerMetadataFailed(nonConst('x'), nonConst('y')),
        isA<SqliteViewerFailure>(),
      );
      expect(
        ViewerUnexpectedError(nonConst('x')),
        isA<SqliteViewerFailure>(),
      );
    });
  });
}
