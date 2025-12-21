// icodeforyou_flutter/packages/since_when/lib/src/utils/_export_to_string.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:sqflite/sqflite.dart';

/// Handles exporting database records to JSON string.
///
/// This class is internal and should not be exported publicly.
// TODO(steven): Implement export to string.
abstract final class ExportToString {
  /// Exports all records and tags to a JSON string.
  ///
  /// The JSON structure includes both tables for complete backup:
  /// ```json
  /// {
  ///   "version": 1,
  ///   "exportedAt": "2025-01-15T12:00:00.000Z",
  ///   "records": [...],
  ///   "tags": [...]
  /// }
  /// ```
  ///
  /// Returns [Right] with JSON string on success.
  /// Returns [Left] with [SinceWhenFailure] on error.
  static Future<Either<SinceWhenFailure, String>> exportToString(
    Database db,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('exportToString not yet implemented');
  }
}
