// lib/src/sql/create/_create_operations.dart

import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/data/_since_when_record_mapper.dart';
import 'package:since_when/src/data/_tag_definition_mapper.dart';
import 'package:since_when/src/domain/data_store_failure.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/domain/tag_definition.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:since_when/src/utils/_timestamp_generator.dart';
import 'package:sqflite/sqflite.dart';

abstract final class CreateOperations {
  static Future<Either<DataStoreFailure, SinceWhenRecord>> createRecord(
    Database db, {
    required String metaData,
    required String dataString,
    required String category,
    required List<String> tagTimestamps,
    String? parentTimeStamp,
  }) async {
    try {
      final timestampResult = await TimestampGenerator.generateUniqueTimestamp(
        db,
      );

      return timestampResult.match(
        Left.new,
        (createdTimeStamp) async {
          final validatedParent = await _validateParent(db, parentTimeStamp);
          final sequenceNumber = await _calculateSequenceNumber(
            db,
            validatedParent,
          );

          final nowUtc = createdTimeStamp;

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

          final validTags = await _insertTagLinks(
            db,
            createdTimeStamp,
            tagTimestamps,
          );

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
      return Left(UnexpectedStoreError('Failed to create record', e));
    }
  }

  static Future<Either<DataStoreFailure, TagDefinition>> createTagDefinition(
    Database db, {
    required String tagName,
    required int color,
  }) async {
    try {
      final trimmedName = tagName.trim();
      if (trimmedName.isEmpty) {
        return const Left(InvalidTagName('Tag name cannot be empty'));
      }

      final existsResult = await db.rawQuery(
        SqlStatements.existsTagName,
        [trimmedName],
      );
      if (existsResult.isNotEmpty) {
        return Left(TagNameAlreadyExists(trimmedName));
      }

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
            color: color,
          );

          return Right(tag);
        },
      );
    } on Object catch (e) {
      return Left(UnexpectedStoreError('Failed to create tag definition', e));
    }
  }

  static Future<String?> _validateParent(
    Database db,
    String? parentTimeStamp,
  ) async {
    if (parentTimeStamp == null) return null;

    final result = await db.rawQuery(
      SqlStatements.existsByCreatedTimeStamp,
      [parentTimeStamp],
    );

    return result.isNotEmpty ? parentTimeStamp : null;
  }

  static Future<int> _calculateSequenceNumber(
    Database db,
    String? parentTimeStamp,
  ) async {
    if (parentTimeStamp == null) return 0;

    final result = await db.rawQuery(
      SqlStatements.maxSequenceNumberForParent,
      [parentTimeStamp],
    );

    if (result.isEmpty || result.first['maxSeq'] == null) return 1;

    final maxSeq = result.first['maxSeq']! as int;
    return maxSeq + 1;
  }

  static Future<List<TagDefinition>> _insertTagLinks(
    Database db,
    String recordTimestamp,
    List<String> tagTimestamps,
  ) async {
    final validTags = <TagDefinition>[];

    for (final glossaryTimestamp in tagTimestamps) {
      final tagRows = await db.rawQuery(
        SqlStatements.selectTagDefinitionByTimestamp,
        [glossaryTimestamp],
      );

      if (tagRows.isNotEmpty) {
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
