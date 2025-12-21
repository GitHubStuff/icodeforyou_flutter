// icodeforyou_flutter/packages/since_when/lib/src/utils/_timestamp_generator.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:sqflite/sqflite.dart';

/// Maximum retry attempts for generating a unique timestamp.
const int _maxRetryAttempts = 100;

/// Delay between retry attempts in microseconds.
const int _retryDelayMicroseconds = 1;

/// Generates unique ISO8601 UTC timestamps for record creation.
///
/// Uses check-then-insert with retry loop to guarantee uniqueness.
/// This class is internal and should not be exported publicly.
abstract final class TimestampGenerator {
  /// Generates a unique ISO8601 UTC timestamp.
  ///
  /// Checks the database to ensure no existing record has this timestamp.
  /// Retries with microsecond delays if collision detected.
  ///
  /// Returns [Right] with unique timestamp string on success.
  /// Returns [Left] with [TimestampCollisionRetryExhausted] if max retries hit.
  static Future<Either<SinceWhenFailure, String>> generateUniqueTimestamp(
    Database db,
  ) async {
    for (var attempt = 0; attempt < _maxRetryAttempts; attempt++) {
      final timestamp = DateTime.now().toUtc().toIso8601String();

      final exists = await _timestampExists(db, timestamp);

      if (!exists) {
        return Right(timestamp);
      }

      // Wait a microsecond and retry
      await Future<void>.delayed(
        const Duration(microseconds: _retryDelayMicroseconds),
      );
    }

    return const Left(TimestampCollisionRetryExhausted());
  }

  /// Checks if a timestamp already exists in the database.
  static Future<bool> _timestampExists(
    Database db,
    String timestamp,
  ) async {
    final result = await db.rawQuery(
      SqlStatements.existsByCreatedTimeStamp,
      [timestamp],
    );
    return result.isNotEmpty;
  }

  /// Converts a [DateTime] to ISO8601 UTC string.
  static String toIso8601Utc(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  /// Parses an ISO8601 string to [DateTime].
  ///
  /// Returns `null` if parsing fails.
  static DateTime? fromIso8601(String iso8601String) {
    return DateTime.tryParse(iso8601String);
  }
}
