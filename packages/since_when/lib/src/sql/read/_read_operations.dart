// icodeforyou_flutter/packages/since_when/lib/src/sql/read/_read_operations.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:sqflite/sqflite.dart';

/// Handles CRUD Read operations for SinceWhen records.
///
/// This class is internal and should not be exported publicly.
// TODO(steven): Implement read operations.
abstract final class ReadOperations {
  /// Gets a record by its createdTimeStamp.
  ///
  /// Returns the record and all its direct children (shallow query),
  /// ordered by sequenceNumber.
  static Future<Either<SinceWhenFailure, List<SinceWhenRecord>>>
  getByCreatedTimeStamp(
    Database db,
    String createdTimeStamp,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('getByCreatedTimeStamp not yet implemented');
  }

  /// Gets all records matching a specific tag.
  static Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByTag(
    Database db,
    String tag,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('getByTag not yet implemented');
  }

  /// Gets all records in a category.
  static Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByCategory(
    Database db,
    String category,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('getByCategory not yet implemented');
  }

  /// Gets all root records (records with no parent).
  static Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getRootRecords(
    Database db,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('getRootRecords not yet implemented');
  }

  /// Gets all records in the database.
  static Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getAllRecords(
    Database db,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('getAllRecords not yet implemented');
  }
}
