// lib/src/sql/delete/_delete_operations.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:sqflite/sqflite.dart';

/// Handles CRUD Delete operations for SinceWhen records.
///
/// This class is internal and should not be exported publicly.
abstract final class DeleteOperations {
  /// Deletes a record by its createdTimeStamp.
  ///
  /// Tag links are automatically deleted via ON DELETE CASCADE.
  /// Child records are NOT automatically deleted — they become orphans
  /// (parentTimeStamp will reference a non-existent record).
  ///
  /// Returns [Right] with `true` if deleted, `false` if not found.
  // TODO(steven): Implement
  static Future<Either<SinceWhenFailure, bool>> deleteByCreatedTimeStamp(
    Database db,
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('deleteByCreatedTimeStamp not yet implemented');
  }

  /// Deletes a record and all its descendants recursively.
  ///
  /// Use with caution — this is a cascading delete through the hierarchy.
  // TODO(steven): Implement
  static Future<Either<SinceWhenFailure, int>> deleteWithDescendants(
    Database db,
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('deleteWithDescendants not yet implemented');
  }

  /// Deletes all records in the database.
  ///
  /// Tag links are automatically deleted via ON DELETE CASCADE.
  /// Returns the number of records deleted.
  // TODO(steven): Implement
  static Future<Either<SinceWhenFailure, int>> deleteAllRecords(
    Database db,
  ) async {
    throw UnimplementedError('deleteAllRecords not yet implemented');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAG GLOSSARY DELETE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Deletes a tag definition from the glossary.
  ///
  /// If [force] is false (default), returns [TagInUse] if any records use it.
  /// If [force] is true, deletes the tag and all its record links.
  ///
  /// Returns [Right] with `true` if deleted, [Left] with [TagNotFound] if not.
  static Future<Either<SinceWhenFailure, bool>> deleteTagDefinition(
    Database db,
    String createdTimeStamp, {
    bool force = false,
  }) async {
    try {
      // Check if tag exists
      final existsResult = await db.rawQuery(
        SqlStatements.selectTagDefinitionByTimestamp,
        [createdTimeStamp],
      );
      if (existsResult.isEmpty) {
        return Left(TagNotFound(createdTimeStamp));
      }

      final tagName = existsResult.first['tagName']! as String;

      // Check if tag is in use
      if (!force) {
        final usageResult = await db.rawQuery(
          '''
          SELECT COUNT(*) as count FROM ${SqlStatements.tableTags}
          WHERE glossary_timestamp = ?
          ''',
          [createdTimeStamp],
        );
        final usageCount = usageResult.first['count']! as int;

        if (usageCount > 0) {
          return Left(TagInUse(tagName, usageCount));
        }
      }

      // Delete the tag (cascade will remove junction entries)
      final deletedCount = await db.rawDelete(
        SqlStatements.deleteTagDefinition,
        [createdTimeStamp],
      );

      return Right(deletedCount > 0);
    } on Exception catch (e) {
      return Left(
        UnexpectedDatabaseError('Failed to delete tag definition', e),
      );
    }
  }

  /// Removes a tag from a specific record.
  ///
  /// Returns [Right] with `true` if removed, `false` if link didn't exist.
  static Future<Either<SinceWhenFailure, bool>> removeTagFromRecord(
    Database db,
    String recordTimestamp,
    String glossaryTimestamp,
  ) async {
    try {
      final deletedCount = await db.rawDelete(
        SqlStatements.deleteRecordTag,
        [recordTimestamp, glossaryTimestamp],
      );

      return Right(deletedCount > 0);
    } on Exception catch (e) {
      return Left(
        UnexpectedDatabaseError('Failed to remove tag from record', e),
      );
    }
  }

  /// Removes all tags from a specific record.
  ///
  /// Returns [Right] with count of tags removed.
  static Future<Either<SinceWhenFailure, int>> removeAllTagsFromRecord(
    Database db,
    String recordTimestamp,
  ) async {
    try {
      final deletedCount = await db.rawDelete(
        SqlStatements.deleteTagsForRecord,
        [recordTimestamp],
      );

      return Right(deletedCount);
    } on Exception catch (e) {
      return Left(
        UnexpectedDatabaseError('Failed to remove tags from record', e),
      );
    }
  }

  /// Deletes all tag definitions from the glossary.
  ///
  /// Also removes all tag links via CASCADE.
  /// Returns the number of tag definitions deleted.
  static Future<Either<SinceWhenFailure, int>> deleteAllTagDefinitions(
    Database db,
  ) async {
    try {
      final deletedCount = await db.rawDelete(
        SqlStatements.deleteAllTagDefinitions,
      );

      return Right(deletedCount);
    } on Exception catch (e) {
      return Left(
        UnexpectedDatabaseError('Failed to delete all tag definitions', e),
      );
    }
  }
}
