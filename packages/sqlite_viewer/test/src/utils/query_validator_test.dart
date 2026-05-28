// test/src/utils/query_validator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/src/failures/sqlite_viewer_failure.dart';
import 'package:sqlite_viewer/src/utils/query_validator.dart';

void main() {
  group('QueryValidator.validate', () {
    test('returns Right with trimmed sql for SELECT', () {
      final result = QueryValidator.validate('  SELECT * FROM users  ');
      expect(result.isRight(), isTrue);
      expect(
        result.match((_) => '', (s) => s),
        'SELECT * FROM users',
      );
    });

    test('returns Right for lowercase select', () {
      final result = QueryValidator.validate('select * from users');
      expect(result.isRight(), isTrue);
    });

    test('returns Right for WITH (CTE) statements', () {
      final result = QueryValidator.validate(
        'WITH cte AS (SELECT 1) SELECT * FROM cte',
      );
      expect(result.isRight(), isTrue);
    });

    test('returns Right for lowercase with', () {
      final result = QueryValidator.validate('with cte AS (SELECT 1) SELECT 1');
      expect(result.isRight(), isTrue);
    });

    test('returns Left with empty-query reason for empty string', () {
      final result = QueryValidator.validate('');
      expect(result.isLeft(), isTrue);
      result.match(
        (f) {
          expect(f, isA<ViewerInvalidQuery>());
          expect(f.message, 'Query cannot be empty');
        },
        (_) => fail('expected Left'),
      );
    });

    test('returns Left for whitespace-only input', () {
      final result = QueryValidator.validate('   \n\t  ');
      expect(result.isLeft(), isTrue);
      result.match(
        (f) => expect(f.message, 'Query cannot be empty'),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left when semicolon is present', () {
      final result = QueryValidator.validate('SELECT 1; DROP TABLE users');
      expect(result.isLeft(), isTrue);
      result.match(
        (f) {
          expect(f, isA<ViewerInvalidQuery>());
          expect(
            f.message,
            'Multiple statements not allowed (semicolon detected)',
          );
        },
        (_) => fail('expected Left'),
      );
    });

    test('returns Left when trailing semicolon present', () {
      final result = QueryValidator.validate('SELECT 1;');
      expect(result.isLeft(), isTrue);
    });

    test('returns Left for DROP TABLE', () {
      final result = QueryValidator.validate('DROP TABLE users');
      expect(result.isLeft(), isTrue);
      result.match(
        (f) => expect(
          f.message,
          'Only SELECT and WITH statements are allowed',
        ),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left for EXPLAIN', () {
      final result = QueryValidator.validate('EXPLAIN SELECT * FROM users');
      expect(result.isLeft(), isTrue);
    });

    test('returns Left for PRAGMA', () {
      final result = QueryValidator.validate('PRAGMA table_info(users)');
      expect(result.isLeft(), isTrue);
    });

    test('returns Left for INSERT', () {
      final result = QueryValidator.validate('INSERT INTO users VALUES (1)');
      expect(result.isLeft(), isTrue);
    });

    test('returns Left for UPDATE', () {
      final result = QueryValidator.validate("UPDATE users SET name = 'x'");
      expect(result.isLeft(), isTrue);
    });

    test('returns Left for DELETE', () {
      final result = QueryValidator.validate('DELETE FROM users');
      expect(result.isLeft(), isTrue);
    });

    test('preserves trimmed query in failure when not SELECT/WITH', () {
      final result = QueryValidator.validate('  DROP TABLE users  ');
      result.match(
        (f) {
          expect(f, isA<ViewerInvalidQuery>());
          expect((f as ViewerInvalidQuery).query, 'DROP TABLE users');
        },
        (_) => fail('expected Left'),
      );
    });

    test('preserves trimmed query in failure when semicolon present', () {
      final result = QueryValidator.validate('  SELECT 1; SELECT 2  ');
      result.match(
        (f) {
          expect(f, isA<ViewerInvalidQuery>());
          expect((f as ViewerInvalidQuery).query, 'SELECT 1; SELECT 2');
        },
        (_) => fail('expected Left'),
      );
    });
  });

  group('QueryValidator.isValid', () {
    test('returns true for SELECT', () {
      expect(QueryValidator.isValid('SELECT * FROM users'), isTrue);
    });

    test('returns true for WITH', () {
      expect(
        QueryValidator.isValid('WITH cte AS (SELECT 1) SELECT * FROM cte'),
        isTrue,
      );
    });

    test('returns false for empty', () {
      expect(QueryValidator.isValid(''), isFalse);
    });

    test('returns false for DROP', () {
      expect(QueryValidator.isValid('DROP TABLE users'), isFalse);
    });

    test('returns false for query with semicolon', () {
      expect(QueryValidator.isValid('SELECT 1; SELECT 2'), isFalse);
    });
  });
}
