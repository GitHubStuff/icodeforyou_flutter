// packages/sqlite_viewer/lib/src/utils/query_validator.dart

import 'package:dartz/dartz.dart';

import 'package:sqlite_viewer/src/failures/sqlite_viewer_failure.dart';

/// Validates SQL queries for sqlite_viewer.
///
/// Only SELECT and WITH (Common Table Expression) statements are allowed.
/// Rejects EXPLAIN, PRAGMA, and any data-modifying statements.
abstract final class QueryValidator {
  /// Validates that [sql] is a safe read-only query.
  ///
  /// Returns [Right] with the trimmed query if valid.
  /// Returns [Left] with [ViewerInvalidQuery] if invalid.
  ///
  /// Validation rules:
  /// - Must start with SELECT or WITH (case-insensitive)
  /// - Must not contain semicolons (prevents SQL injection)
  /// - Must not be empty
  ///
  /// Examples:
  /// ```dart
  /// validate('SELECT * FROM users');              // Right('SELECT * FROM users')
  /// validate('  select * from users  ');          // Right('select * from users')
  /// validate('WITH cte AS (...) SELECT ...');     // Right(...)
  /// validate('DROP TABLE users');                 // Left(ViewerInvalidQuery)
  /// validate('SELECT *; DROP TABLE users');       // Left(ViewerInvalidQuery)
  /// validate('EXPLAIN SELECT * FROM users');      // Left(ViewerInvalidQuery)
  /// validate('PRAGMA table_info(users)');         // Left(ViewerInvalidQuery)
  /// ```
  static Either<SqliteViewerFailure, String> validate(String sql) {
    final trimmed = sql.trim();

    // Check for empty query
    if (trimmed.isEmpty) {
      return const Left(
        ViewerInvalidQuery('', 'Query cannot be empty'),
      );
    }

    // Check for SQL injection (multiple statements)
    if (trimmed.contains(';')) {
      return Left(
        ViewerInvalidQuery(
          trimmed,
          'Multiple statements not allowed (semicolon detected)',
        ),
      );
    }

    // Normalize for keyword checking
    final normalized = trimmed.toUpperCase();

    // Check for valid starting keywords
    if (!_isValidStart(normalized)) {
      return Left(
        ViewerInvalidQuery(
          trimmed,
          'Only SELECT and WITH statements are allowed',
        ),
      );
    }

    // Check for explicitly disallowed keywords at start
    if (_isDisallowedStart(normalized)) {
      return Left(
        ViewerInvalidQuery(
          trimmed,
          'EXPLAIN and PRAGMA statements are not allowed',
        ),
      );
    }

    return Right(trimmed);
  }

  /// Returns true if query starts with SELECT or WITH.
  static bool _isValidStart(String normalizedSql) {
    return normalizedSql.startsWith('SELECT') ||
        normalizedSql.startsWith('WITH');
  }

  /// Returns true if query starts with disallowed keywords.
  static bool _isDisallowedStart(String normalizedSql) {
    return normalizedSql.startsWith('EXPLAIN') ||
        normalizedSql.startsWith('PRAGMA');
  }

  /// Quick check if a query is valid without returning Either.
  ///
  /// Useful for UI validation before submission.
  static bool isValid(String sql) {
    return validate(sql).isRight();
  }
}
