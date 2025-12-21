// icodeforyou_flutter/packages/since_when/lib/src/utils/_import_from_json.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/domain/since_when_import_mode.dart';
import 'package:sqflite/sqflite.dart';

/// Handles importing database records from a JSON file.
///
/// This class is internal and should not be exported publicly.
// TODO(steven): Implement import from file.
abstract final class ImportFromJson {
  /// Imports records and tags from a JSON file.
  ///
  /// If [path] is a full file path, reads directly from that location.
  /// If [path] is just a filename, reads from the documents directory.
  ///
  /// The [mode] determines how duplicates are handled:
  /// - [SinceWhenImportMode.merge]: Duplicates ignored (keep existing)
  /// - [SinceWhenImportMode.update]: Duplicates overwritten with incoming
  /// - [SinceWhenImportMode.replace]: Wipe DB, load incoming
  /// - [SinceWhenImportMode.refresh]: Compare editedTimeStamp, keep newest
  ///
  /// Returns [Right] with count of imported records on success.
  /// Returns [Left] with [FileNotFound] or [ImportFailed] on error.
  static Future<Either<SinceWhenFailure, int>> importFromFile(
    Database db, {
    required String path,
    SinceWhenImportMode mode = SinceWhenImportMode.merge,
  }) async {
    // TODO(steven): Implement
    throw UnimplementedError('importFromFile not yet implemented');
  }

  /// Imports records and tags from a JSON file in the documents directory.
  ///
  /// Uses the provided [filename] to locate the file.
  ///
  /// Returns [Right] with count of imported records on success.
  /// Returns [Left] with [FileNotFound] or [ImportFailed] on error.
  static Future<Either<SinceWhenFailure, int>> importFromDocuments(
    Database db, {
    required String filename,
    SinceWhenImportMode mode = SinceWhenImportMode.merge,
  }) async {
    // TODO(steven): Implement
    throw UnimplementedError('importFromDocuments not yet implemented');
  }
}
