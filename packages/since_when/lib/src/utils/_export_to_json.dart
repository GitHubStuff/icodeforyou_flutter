// icodeforyou_flutter/packages/since_when/lib/src/utils/_export_to_json.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:sqflite/sqflite.dart';

/// Handles exporting database records to a JSON file.
///
/// This class is internal and should not be exported publicly.
// TODO(steven): Implement export to file.
abstract final class ExportToJson {
  /// Exports all records and tags to a JSON file.
  ///
  /// If [path] is a full file path, writes directly to that location.
  /// If [path] is just a filename, writes to the documents directory.
  ///
  /// Returns [Right] with the full path of the exported file on success.
  /// Returns [Left] with [ExportFailed] on error.
  static Future<Either<SinceWhenFailure, String>> exportToFile(
    Database db, {
    required String path,
  }) async {
    // TODO(steven): Implement
    throw UnimplementedError('exportToFile not yet implemented');
  }

  /// Exports all records and tags to a JSON file in the documents directory.
  ///
  /// Uses the provided [filename] with .json extension.
  ///
  /// Returns [Right] with the full path of the exported file on success.
  /// Returns [Left] with [ExportFailed] on error.
  static Future<Either<SinceWhenFailure, String>> exportToDocuments(
    Database db, {
    required String filename,
  }) async {
    // TODO(steven): Implement
    throw UnimplementedError('exportToDocuments not yet implemented');
  }
}
