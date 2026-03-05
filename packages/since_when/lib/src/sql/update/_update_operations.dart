// lib/src/sql/update/_update_operations.dart

import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/data/_tag_definition_mapper.dart';
import 'package:since_when/src/domain/data_store_failure.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/domain/tag_definition.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:sqflite/sqflite.dart';

abstract final class UpdateOperations {
  // TODO(steven): Implement
  static Future<Either<DataStoreFailure, SinceWhenRecord>> updateRecord(
    Database db,
    SinceWhenRecord record,
  ) async {
    throw UnimplementedError('updateRecord not yet implemented');
  }

  // TODO(steven): Implement
  static Future<Either<DataStoreFailure, SinceWhenRecord>> markReviewed(
    Database db,
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('markReviewed not yet implemented');
  }

  // TODO(steven): Implement
  static Future<Either<DataStoreFailure, SinceWhenRecord>> updateSequence(
    Database db,
    String createdTimeStamp,
    int newSequenceNumber,
  ) async {
    throw UnimplementedError('updateSequence not yet implemented');
  }

  // TODO(steven): Implement
  static Future<Either<DataStoreFailure, SinceWhenRecord>> updateRecordTags(
    Database db,
    String recordTimestamp,
    List<String> tagTimestamps,
  ) async {
    throw UnimplementedError('updateRecordTags not yet implemented');
  }

  static Future<Either<DataStoreFailure, TagDefinition>> updateTagDefinition(
    Database db, {
    required String createdTimeStamp,
    required String tagName,
    required int color,
  }) async {
    try {
      final trimmedName = tagName.trim();
      if (trimmedName.isEmpty) {
        return const Left(InvalidTagName('Tag name cannot be empty'));
      }

      final existsResult = await db.rawQuery(
        SqlStatements.selectTagDefinitionByTimestamp,
        [createdTimeStamp],
      );
      if (existsResult.isEmpty) {
        return Left(TagNotFound(createdTimeStamp));
      }

      final currentTag = TagDefinitionMapper.fromRow(existsResult.first);

      if (trimmedName != currentTag.tagName) {
        final nameConflict = await db.rawQuery(
          SqlStatements.existsTagName,
          [trimmedName],
        );
        if (nameConflict.isNotEmpty) {
          return Left(TagNameAlreadyExists(trimmedName));
        }
      }

      final updateValues = TagDefinitionMapper.toUpdateValues(
        createdTimeStamp: createdTimeStamp,
        tagName: trimmedName,
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
        color: color,
      );

      return Right(updatedTag);
    } on Exception catch (e) {
      return Left(UnexpectedStoreError('Failed to update tag definition', e));
    }
  }
}
