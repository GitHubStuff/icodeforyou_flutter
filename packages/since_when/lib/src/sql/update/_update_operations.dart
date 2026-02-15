// lib/src/sql/update/_update_operations.dart

import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/data/_tag_definition_mapper.dart';
import 'package:since_when/src/domain/data_store_failure.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/domain/tag_definition.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:sqflite/sqflite.dart';

/// Handles CRUD Update operations for SinceWhen records.
///
/// This class is internal and should not be exported publicly.
abstract final class UpdateOperations {
  /// Updates an existing record.
  ///
  /// Automatically updates `editedTimeStamp` to current UTC time.
  /// If `metaTimeStamp` is provided in the updated record, it will be set.
  ///
  /// Note: `createdTimeStamp` cannot be modified.
  // TODO(steven): Implement
  static Future<Either<DataStoreFailure, SinceWhenRecord>> updateRecord(
    Database db,
    SinceWhenRecord record,
  ) async {
    throw UnimplementedError('updateRecord not yet implemented');
  }

  /// Marks a record as reviewed.
  ///
  /// Updates 'reviewedTimeStamp' to current UTC time.
  // TODO(steven): Implement
  static Future<Either<DataStoreFailure, SinceWhenRecord>> markReviewed(
    Database db,
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('markReviewed not yet implemented');
  }

  /// Updates the sequenceNumber of a record.
  ///
  /// Used for reordering sibling records.
  // TODO(steven): Implement
  static Future<Either<DataStoreFailure, SinceWhenRecord>> updateSequence(
    Database db,
    String createdTimeStamp,
    int newSequenceNumber,
  ) async {
    throw UnimplementedError('updateSequence not yet implemented');
  }

  /// Updates tags for a record.
  ///
  /// Replaces all existing tag links with the new list of glossary timestamps.
  // TODO(steven): Implement
  static Future<Either<DataStoreFailure, SinceWhenRecord>> updateRecordTags(
    Database db,
    String recordTimestamp,
    List<String> tagTimestamps,
  ) async {
    throw UnimplementedError('updateRecordTags not yet implemented');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAG GLOSSARY UPDATE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Updates a tag definition in the glossary.
  ///
  /// [createdTimeStamp] identifies the tag to update.
  /// Returns [Left] with [TagNotFound] if tag doesn't exist.
  /// Returns [Left] with [TagNameAlreadyExists] if new name conflicts.
  static Future<Either<DataStoreFailure, TagDefinition>> updateTagDefinition(
    Database db, {
    required String createdTimeStamp,
    required String tagName,
    required String tagDescription,
    required int color,
  }) async {
    try {
      // Validate tag name
      final trimmedName = tagName.trim();
      if (trimmedName.isEmpty) {
        return const Left(InvalidTagName('Tag name cannot be empty'));
      }

      // Check if tag exists
      final existsResult = await db.rawQuery(
        SqlStatements.selectTagDefinitionByTimestamp,
        [createdTimeStamp],
      );
      if (existsResult.isEmpty) {
        return Left(TagNotFound(createdTimeStamp));
      }

      final currentTag = TagDefinitionMapper.fromRow(existsResult.first);

      // Check if new name conflicts with another tag
      if (trimmedName != currentTag.tagName) {
        final nameConflict = await db.rawQuery(
          SqlStatements.existsTagName,
          [trimmedName],
        );
        if (nameConflict.isNotEmpty) {
          return Left(TagNameAlreadyExists(trimmedName));
        }
      }

      // Update the tag
      final updateValues = TagDefinitionMapper.toUpdateValues(
        createdTimeStamp: createdTimeStamp,
        tagName: trimmedName,
        tagDescription: tagDescription,
        color: color,
      );

      await db.rawUpdate(
        SqlStatements.updateTagDefinition,
        updateValues,
      );

      final updatedTag = TagDefinition(
        id: currentTag.id,
        createdTimeStamp: createdTimeStamp,
        tagName: trimmedName,
        tagDescription: tagDescription,
        color: color,
      );

      return Right(updatedTag);
    } on Exception catch (e) {
      return Left(
        UnexpectedStoreError('Failed to update tag definition', e),
      );
    }
  }
}
