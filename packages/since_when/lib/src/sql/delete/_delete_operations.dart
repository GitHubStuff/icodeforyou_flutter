// icodeforyou_flutter/packages/since_when/lib/src/sql/delete/_delete_operations.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:sqflite/sqflite.dart';

/// Handles CRUD Delete operations for SinceWhen records.
///
/// This class is internal and should not be exported publicly.
// TODO(steven): Implement delete operations.
abstract final class DeleteOperations {
  /// Deletes a record by its createdTimeStamp.
  ///
  /// Tags are automatically deleted via ON DELETE CASCADE.
  /// Child records are NOT automatically deleted — they become orphans
  /// (parentTimeStamp will reference a non-existent record).
  ///
  /// Returns [Right] with `true` if deleted, `false` if not found.
  static Future<Either<SinceWhenFailure, bool>> deleteByCreatedTimeStamp(
    Database db,
    String createdTimeStamp,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('deleteByCreatedTimeStamp not yet implemented');
  }

  /// Deletes a record and all its descendants recursively.
  ///
  /// Use with caution — this is a cascading delete through the hierarchy.
  static Future<Either<SinceWhenFailure, int>> deleteWithDescendants(
    Database db,
    String createdTimeStamp,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('deleteWithDescendants not yet implemented');
  }

  /// Deletes all records in the database.
  ///
  /// Tags are automatically deleted via ON DELETE CASCADE.
  /// Returns the number of records deleted.
  static Future<Either<SinceWhenFailure, int>> deleteAllRecords(
    Database db,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('deleteAllRecords not yet implemented');
  }
}
