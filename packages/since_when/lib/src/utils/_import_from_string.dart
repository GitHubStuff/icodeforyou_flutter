// icodeforyou_flutter/packages/since_when/lib/src/utils/_import_from_string.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/domain/since_when_import_mode.dart';
import 'package:sqflite/sqflite.dart';

/// Handles importing database records from JSON string.
///
/// This class is internal and should not be exported publicly.
// TODO(steven): Implement import from string.
abstract final class ImportFromString {
  /// Imports records and tags from a JSON string.
  ///
  /// The [mode] determines how duplicates are handled:
  /// - [SinceWhenImportMode.merge]: Duplicates ignored (keep existing)
  /// - [SinceWhenImportMode.update]: Duplicates overwritten with incoming
  /// - [SinceWhenImportMode.replace]: Wipe DB, load incoming
  /// - [SinceWhenImportMode.refresh]: Compare editedTimeStamp, keep newest
  ///
  /// Returns [Right] with count of imported records on success.
  /// Returns [Left] with [SinceWhenFailure] on error.
  static Future<Either<SinceWhenFailure, int>> importFromString(
    Database db,
    String jsonString, {
    SinceWhenImportMode mode = SinceWhenImportMode.merge,
  }) async {
    // TODO(steven): Implement
    throw UnimplementedError('importFromString not yet implemented');
  }
}
