// icodeforyou_flutter/packages/since_when/lib/src/sql/update/_update_operations.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:sqflite/sqflite.dart';

/// Handles CRUD Update operations for SinceWhen records.
///
/// This class is internal and should not be exported publicly.
// TODO(steven): Implement update operations.
abstract final class UpdateOperations {
  /// Updates an existing record.
  ///
  /// Automatically updates `editedTimeStamp` to current UTC time.
  /// If `metaTimeStamp` is provided in the updated record, it will be set.
  ///
  /// Note: `createdTimeStamp` cannot be modified.
  static Future<Either<SinceWhenFailure, SinceWhenRecord>> updateRecord(
    Database db,
    SinceWhenRecord record,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('updateRecord not yet implemented');
  }

  /// Marks a record as reviewed.
  ///
  /// Updates 'reviewedTimeStamp' to current UTC time.
  static Future<Either<SinceWhenFailure, SinceWhenRecord>> markReviewed(
    Database db,
    String createdTimeStamp,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('markReviewed not yet implemented');
  }

  /// Updates the sequenceNumber of a record.
  ///
  /// Used for reordering sibling records.
  static Future<Either<SinceWhenFailure, SinceWhenRecord>> updateSequence(
    Database db,
    String createdTimeStamp,
    int newSequenceNumber,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('updateSequence not yet implemented');
  }

  /// Updates tags for a record.
  ///
  /// Replaces all existing tags with the new list.
  static Future<Either<SinceWhenFailure, SinceWhenRecord>> updateTags(
    Database db,
    String createdTimeStamp,
    List<String> tags,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('updateTags not yet implemented');
  }
}
