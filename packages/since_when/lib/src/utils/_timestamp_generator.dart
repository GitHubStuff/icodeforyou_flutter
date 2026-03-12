// lib/src/utils/_timestamp_generator.dart

import 'package:fpdart/fpdart.dart';
import 'package:sqflite/sqflite.dart';

part '_timestamp_failure.dart';

const int _maxRetries = 100;

abstract final class TimestampGenerator {
  /// Generates a unique timestamp in milliseconds since epoch.
  ///
  /// Retries up to [_maxRetries] times if a collision is detected.
  static Future<Either<TimestampFailure, int>> generate(
    Database db, {
    required String table,
  }) async {
    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final candidate = DateTime.now().millisecondsSinceEpoch;

      if (!await _exists(db, table: table, timestamp: candidate)) {
        return Right(candidate);
      }

      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    return const Left(TimestampCollisionExhausted());
  }

  static Future<bool> _exists(
    Database db, {
    required String table,
    required int timestamp,
  }) async {
    final result = await db.rawQuery(
      'SELECT 1 FROM $table WHERE createdTimeStamp = ? LIMIT 1',
      [timestamp],
    );
    return result.isNotEmpty;
  }
}
