// lib/src/sql/read/_read_tag_operations.dart

import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/data/_tag_definition_mapper.dart';
import 'package:since_when/src/domain/data_store_failure.dart';
import 'package:since_when/src/domain/tag_definition.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:sqflite/sqflite.dart';

/// Handles Read operations for tag definitions.
abstract final class ReadTagOperations {
  /// Gets a tag definition by its createdTimeStamp.
  static Future<Either<DataStoreFailure, TagDefinition>>
      getTagDefinitionByTimestamp(
    Database db,
    String createdTimeStamp,
  ) async {
    try {
      final rows = await db.rawQuery(
        SqlStatements.selectTagDefinitionByTimestamp,
        [createdTimeStamp],
      );

      if (rows.isEmpty) {
        return Left(TagNotFound(createdTimeStamp));
      }

      return Right(TagDefinitionMapper.fromRow(rows.first));
    } on Exception catch (e) {
      return Left(
        UnexpectedStoreError('Failed to get tag definition', e),
      );
    }
  }

  /// Gets a tag definition by its name.
  static Future<Either<DataStoreFailure, TagDefinition>>
      getTagDefinitionByName(
    Database db,
    String tagName,
  ) async {
    try {
      final rows = await db.rawQuery(
        SqlStatements.selectTagDefinitionByName,
        [tagName],
      );

      if (rows.isEmpty) {
        return Left(TagNotFound(tagName));
      }

      return Right(TagDefinitionMapper.fromRow(rows.first));
    } on Exception catch (e) {
      return Left(
        UnexpectedStoreError('Failed to get tag definition by name', e),
      );
    }
  }

  /// Gets all tag definitions from the glossary.
  static Future<Either<DataStoreFailure, List<TagDefinition>>>
      getAllTagDefinitions(
    Database db,
  ) async {
    try {
      final rows = await db.rawQuery(SqlStatements.selectAllTagDefinitions);
      return Right(TagDefinitionMapper.fromRows(rows));
    } on Exception catch (e) {
      return Left(
        UnexpectedStoreError('Failed to get all tag definitions', e),
      );
    }
  }
}
