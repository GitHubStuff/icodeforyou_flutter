// lib/src/sql/create/_create_operations.dart

import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/data/_since_when_record_mapper.dart';
import 'package:since_when/src/data/_tag_definition_mapper.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/domain/tag_definition.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:since_when/src/utils/_timestamp_generator.dart';
import 'package:sqflite/sqflite.dart';

/// Handles CRUD Create operations for SinceWhen records.
///
/// This class is internal and should not be exported publicly.
abstract final class CreateOperations {
  /// Creates a new record in the database.
  ///
  /// If [parentTimeStamp] is provided:
  /// - Validates the parent exists (sets to null if not found)
  /// - Calculates sequenceNumber as max(siblings) + 1
  ///
  /// If [parentTimeStamp] is null:
  /// - sequenceNumber defaults to 0
  ///
  /// [tagTimestamps] should be a list of glossary createdTimeStamp values.
  /// Invalid timestamps are silently ignored.
  ///
  /// Returns [Right] with created [SinceWhenRecord] on success.
  /// Returns [Left] with appropriate [SinceWhenFailure] on error.
  static Future<Either<SinceWhenFailure, SinceWhenRecord>> createRecord(
    Database db, {
    required String metaData,
    required String dataString,
    required String category,
    required List<String> tagTimestamps,
    String? parentTimeStamp,
  }) async {
    try {
      // Generate unique timestamp
      final timestampResult = await TimestampGenerator.generateUniqueTimestamp(
        db,
      );

      return timestampResult.match(
        Left.new,
        (createdTimeStamp) async {
          // Validate parent and calculate sequence number
          final validatedParent = await _validateParent(db, parentTimeStamp);
          final sequenceNumber = await _calculateSequenceNumber(
            db,
            validatedParent,
          );

          // All timestamps start the same on creation
          final nowUtc = createdTimeStamp;

          // Insert the record
          final insertValues = SinceWhenRecordMapper.toInsertValuesFromParams(
            createdTimeStamp: createdTimeStamp,
            parentTimeStamp: validatedParent,
            reviewedTimeStamp: nowUtc,
            editedTimeStamp: nowUtc,
            metaTimeStamp: null,
            metaData: metaData,
            sequenceNumber: sequenceNumber,
            dataString: dataString,
            category: category,
          );

          final recordId = await db.rawInsert(
            SqlStatements.insertRecord,
            insertValues,
          );

          // Insert tag links and collect valid tags
          final validTags = await _insertTagLinks(
            db,
            createdTimeStamp,
            tagTimestamps,
          );

          // Build and return the record
          final record = SinceWhenRecord(
            id: recordId,
            createdTimeStamp: createdTimeStamp,
            parentTimeStamp: validatedParent,
            reviewedTimeStamp: nowUtc,
            editedTimeStamp: nowUtc,
            metaData: metaData,
            sequenceNumber: sequenceNumber,
            dataString: dataString,
            category: category,
            tags: validTags,
          );

          return Right(record);
        },
      );
    } on Object catch (e) {
      return Left(UnexpectedDatabaseError('Failed to create record', e));
    }
  }

  /// Creates a new tag definition in the glossary.
  ///
  /// Returns [Right] with created [TagDefinition] on success.
  /// Returns [Left] with [TagNameAlreadyExists] if name is taken.
  /// Returns [Left] with [InvalidTagName] if name is empty.
  static Future<Either<SinceWhenFailure, TagDefinition>> createTagDefinition(
    Database db, {
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

      // Check if tag name already exists
      final existsResult = await db.rawQuery(
        SqlStatements.existsTagName,
        [trimmedName],
      );
      if (existsResult.isNotEmpty) {
        return Left(TagNameAlreadyExists(trimmedName));
      }

      // Generate unique timestamp for glossary entry
      final timestampResult = await TimestampGenerator.generateUniqueTimestamp(
        db,
        table: SqlStatements.tableTagGlossary,
      );

      return timestampResult.match(
        Left.new,
        (createdTimeStamp) async {
          final insertValues = TagDefinitionMapper.toInsertValues(
            createdTimeStamp: createdTimeStamp,
            tagName: trimmedName,
            tagDescription: tagDescription,
            color: color,
          );

          final tagId = await db.rawInsert(
            SqlStatements.insertTagDefinition,
            insertValues,
          );

          final tag = TagDefinition(
            id: tagId,
            createdTimeStamp: createdTimeStamp,
            tagName: trimmedName,
            tagDescription: tagDescription,
            color: color,
          );

          return Right(tag);
        },
      );
    } on Object catch (e) {
      return Left(
        UnexpectedDatabaseError('Failed to create tag definition', e),
      );
    }
  }

  /// Validates that the parent record exists.
  ///
  /// Returns the parentTimeStamp if valid, null otherwise.
  static Future<String?> _validateParent(
    Database db,
    String? parentTimeStamp,
  ) async {
    if (parentTimeStamp == null) {
      return null;
    }

    final result = await db.rawQuery(
      SqlStatements.existsByCreatedTimeStamp,
      [parentTimeStamp],
    );

    return result.isNotEmpty ? parentTimeStamp : null;
  }

  /// Calculates the sequence number for a new child record.
  ///
  /// Returns max(sequenceNumber) + 1 for siblings, or 1 if no siblings.
  /// Returns 0 if no parent (root record).
  static Future<int> _calculateSequenceNumber(
    Database db,
    String? parentTimeStamp,
  ) async {
    if (parentTimeStamp == null) {
      return 0;
    }

    final result = await db.rawQuery(
      SqlStatements.maxSequenceNumberForParent,
      [parentTimeStamp],
    );

    if (result.isEmpty || result.first['maxSeq'] == null) {
      return 1;
    }

    final maxSeq = result.first['maxSeq']! as int;
    return maxSeq + 1;
  }

  /// Inserts tag links into the junction table.
  ///
  /// Returns the list of valid [TagDefinition]s that were linked.
  /// Invalid timestamps are silently ignored.
  static Future<List<TagDefinition>> _insertTagLinks(
    Database db,
    String recordTimestamp,
    List<String> tagTimestamps,
  ) async {
    final validTags = <TagDefinition>[];

    for (final glossaryTimestamp in tagTimestamps) {
      // Verify the glossary entry exists
      final tagRows = await db.rawQuery(
        SqlStatements.selectTagDefinitionByTimestamp,
        [glossaryTimestamp],
      );

      if (tagRows.isNotEmpty) {
        // Insert the link
        await db.rawInsert(
          SqlStatements.insertRecordTag,
          [recordTimestamp, glossaryTimestamp],
        );

        validTags.add(TagDefinitionMapper.fromRow(tagRows.first));
      }
    }

    return validTags;
  }
}
