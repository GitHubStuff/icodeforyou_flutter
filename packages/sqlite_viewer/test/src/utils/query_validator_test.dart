// test/src/utils/query_validator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/src/failures/sqlite_viewer_failure.dart';
import 'package:sqlite_viewer/src/utils/query_validator.dart';

void main() {
  group('QueryValidator', () {
    group('validate', () {
      group('valid queries', () {
        test('accepts SELECT query', () {
          final result = QueryValidator.validate('SELECT * FROM users');
          expect(result.isRight(), isTrue);
          expect(result.getOrElse(() => ''), 'SELECT * FROM users');
        });

        test('accepts SELECT query with lowercase', () {
          final result = QueryValidator.validate('select * from users');
          expect(result.isRight(), isTrue);
          expect(result.getOrElse(() => ''), 'select * from users');
        });

        test('accepts SELECT query with mixed case', () {
          final result = QueryValidator.validate('SeLeCt * FrOm users');
          expect(result.isRight(), isTrue);
        });

        test('accepts WITH (CTE) query', () {
          final result = QueryValidator.validate(
            'WITH cte AS (SELECT 1) SELECT * FROM cte',
          );
          expect(result.isRight(), isTrue);
        });

        test('accepts WITH query with lowercase', () {
          final result = QueryValidator.validate(
            'with cte as (select 1) select * from cte',
          );
          expect(result.isRight(), isTrue);
        });

        test('trims whitespace from valid query', () {
          final result = QueryValidator.validate('  SELECT * FROM users  ');
          expect(result.isRight(), isTrue);
          expect(result.getOrElse(() => ''), 'SELECT * FROM users');
        });

        test('accepts complex SELECT query', () {
          final result = QueryValidator.validate(
            'SELECT u.id, u.name, p.title '
            'FROM users u '
            'JOIN posts p ON u.id = p.user_id '
            'WHERE u.active = 1 '
            'ORDER BY p.created_at DESC '
            'LIMIT 10',
          );
          expect(result.isRight(), isTrue);
        });
      });

      group('empty query', () {
        test('rejects empty string', () {
          final result = QueryValidator.validate('');
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<ViewerInvalidQuery>());
            expect(failure.message, 'Query cannot be empty');
          }, (_) => fail('Should be Left'));
        });

        test('rejects whitespace-only string', () {
          final result = QueryValidator.validate('   ');
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<ViewerInvalidQuery>());
            expect(failure.message, 'Query cannot be empty');
          }, (_) => fail('Should be Left'));
        });

        test('rejects tabs and newlines only', () {
          final result = QueryValidator.validate('\t\n\r');
          expect(result.isLeft(), isTrue);
        });
      });

      group('semicolon detection', () {
        test('rejects query with semicolon', () {
          final result = QueryValidator.validate('SELECT *; DROP TABLE users');
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<ViewerInvalidQuery>());
            expect(
              failure.message,
              'Multiple statements not allowed (semicolon detected)',
            );
          }, (_) => fail('Should be Left'));
        });

        test('rejects query ending with semicolon', () {
          final result = QueryValidator.validate('SELECT * FROM users;');
          expect(result.isLeft(), isTrue);
        });

        test('rejects query with multiple semicolons', () {
          final result = QueryValidator.validate(
            'SELECT 1; SELECT 2; SELECT 3',
          );
          expect(result.isLeft(), isTrue);
        });
      });

      group('invalid start keywords', () {
        test('rejects INSERT query', () {
          final result = QueryValidator.validate(
            'INSERT INTO users VALUES (1, "test")',
          );
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<ViewerInvalidQuery>());
            expect(
              failure.message,
              'Only SELECT and WITH statements are allowed',
            );
          }, (_) => fail('Should be Left'));
        });

        test('rejects UPDATE query', () {
          final result = QueryValidator.validate(
            'UPDATE users SET name = "test"',
          );
          expect(result.isLeft(), isTrue);
        });

        test('rejects DELETE query', () {
          final result = QueryValidator.validate('DELETE FROM users');
          expect(result.isLeft(), isTrue);
        });

        test('rejects DROP query', () {
          final result = QueryValidator.validate('DROP TABLE users');
          expect(result.isLeft(), isTrue);
        });

        test('rejects CREATE query', () {
          final result = QueryValidator.validate(
            'CREATE TABLE test (id INTEGER)',
          );
          expect(result.isLeft(), isTrue);
        });

        test('rejects ALTER query', () {
          final result = QueryValidator.validate(
            'ALTER TABLE users ADD COLUMN email TEXT',
          );
          expect(result.isLeft(), isTrue);
        });
      });

      group('disallowed keywords', () {
        test('rejects EXPLAIN query', () {
          final result = QueryValidator.validate('EXPLAIN SELECT * FROM users');
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<ViewerInvalidQuery>());
            expect(
              failure.message,
              'Only SELECT and WITH statements are allowed',
            );
          }, (_) => fail('Should be Left'));
        });

        test('rejects EXPLAIN with lowercase', () {
          final result = QueryValidator.validate('explain select * from users');
          expect(result.isLeft(), isTrue);
        });

        test('rejects PRAGMA query', () {
          final result = QueryValidator.validate('PRAGMA table_info(users)');
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<ViewerInvalidQuery>());
            expect(
              failure.message,
              'Only SELECT and WITH statements are allowed',
            );
          }, (_) => fail('Should be Left'));
        });

        test('rejects PRAGMA with lowercase', () {
          final result = QueryValidator.validate('pragma table_info(users)');
          expect(result.isLeft(), isTrue);
        });
      });

      group('ViewerInvalidQuery properties', () {
        test('contains original query', () {
          QueryValidator.validate('DROP TABLE users').fold(
            (failure) {
              expect(failure, isA<ViewerInvalidQuery>());
              final invalidQuery = failure as ViewerInvalidQuery;
              expect(invalidQuery.query, 'DROP TABLE users');
            },
            (_) => fail('Should be Left'),
          );
        });

        test('contains reason for empty query', () {
          QueryValidator.validate('').fold((failure) {
            final invalidQuery = failure as ViewerInvalidQuery;
            expect(invalidQuery.reason, 'Query cannot be empty');
          }, (_) => fail('Should be Left'));
        });
      });
    });

    group('isValid', () {
      test('returns true for valid SELECT', () {
        expect(QueryValidator.isValid('SELECT * FROM users'), isTrue);
      });

      test('returns true for valid WITH', () {
        expect(
          QueryValidator.isValid('WITH cte AS (SELECT 1) SELECT * FROM cte'),
          isTrue,
        );
      });

      test('returns false for empty string', () {
        expect(QueryValidator.isValid(''), isFalse);
      });

      test('returns false for semicolon', () {
        expect(QueryValidator.isValid('SELECT 1;'), isFalse);
      });

      test('returns false for invalid start', () {
        expect(QueryValidator.isValid('DROP TABLE users'), isFalse);
      });

      test('returns false for EXPLAIN', () {
        expect(QueryValidator.isValid('EXPLAIN SELECT 1'), isFalse);
      });

      test('returns false for PRAGMA', () {
        expect(QueryValidator.isValid('PRAGMA table_info(users)'), isFalse);
      });
    });
  });
}
