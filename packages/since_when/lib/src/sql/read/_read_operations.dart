// lib/src/sql/read/_read_operations.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/data/_since_when_record_mapper.dart';
import 'package:since_when/src/data/_tag_definition_mapper.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/domain/tag_definition.dart';
import 'package:since_when/src/domain/tag_match_mode.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:sqflite/sqflite.dart';

/// Handles CRUD Read operations for SinceWhen records.
///
/// This class is internal and should not be exported publicly.
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

  /// Gets all records matching a specific tag by glossary timestamp.
  static Future<Either<SinceWhenFailure, List<SinceWhenRecord>>>
      getByTagTimestamp(
    Database db,
    String glossaryTimestamp,
  ) async {
    try {
      final rows = await db.rawQuery(
        SqlStatements.selectRecordsByTagTimestamp,
        [glossaryTimestamp],
      );

      final records = <SinceWhenRecord>[];
      for (final row in rows) {
        final tags = await _getTagsForRecord(
          db,
          row['createdTimeStamp']! as String,
        );
        records.add(SinceWhenRecordMapper.fromRow(row, tags));
      }

      return Right(records);
    } on Exception catch (e) {
      return Left(
        UnexpectedDatabaseError('Failed to query records by tag', e),
      );
    }
  }

  /// Gets all records matching a specific tag by tag name.
  static Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByTagName(
    Database db,
    String tagName,
  ) async {
    try {
      final rows = await db.rawQuery(
        SqlStatements.selectRecordsByTagName,
        [tagName],
      );

      final records = <SinceWhenRecord>[];
      for (final row in rows) {
        final tags = await _getTagsForRecord(
          db,
          row['createdTimeStamp']! as String,
        );
        records.add(SinceWhenRecordMapper.fromRow(row, tags));
      }

      return Right(records);
    } on Exception catch (e) {
      return Left(
        UnexpectedDatabaseError('Failed to query records by tag name', e),
      );
    }
  }

  /// Gets all records matching the specified tags based on [mode].
  ///
  /// - [TagMatchMode.any]: Returns records with at least one matching tag.
  /// - [TagMatchMode.all]: Returns records with all specified tags.
  ///
  /// [tagTimestamps] should be glossary createdTimeStamp values.
  /// Returns empty list if [tagTimestamps] is empty.
  static Future<Either<SinceWhenFailure, List<SinceWhenRecord>>>
      getByTagTimestamps(
    Database db,
    List<String> tagTimestamps, {
    TagMatchMode mode = TagMatchMode.any,
  }) async {
    if (tagTimestamps.isEmpty) {
      return const Right([]);
    }

    try {
      final String sql;
      final List<Object?> args;

      if (mode == TagMatchMode.any) {
        // ANY: Records with at least one of the specified tags
        final placeholders = List.filled(tagTimestamps.length, '?').join(', ');
        sql = '''
          SELECT DISTINCT sw.*
          FROM ${SqlStatements.tableSinceWhen} sw
          INNER JOIN ${SqlStatements.tableTags} t 
            ON sw.createdTimeStamp = t.record_timestamp
          WHERE t.glossary_timestamp IN ($placeholders)
          ORDER BY sw.createdTimeStamp DESC
        ''';
        args = tagTimestamps;
      } else {
        // ALL: Records with all specified tags
        final placeholders = List.filled(tagTimestamps.length, '?').join(', ');
        sql = '''
          SELECT sw.*
          FROM ${SqlStatements.tableSinceWhen} sw
          WHERE (
            SELECT COUNT(DISTINCT t.glossary_timestamp)
            FROM ${SqlStatements.tableTags} t
            WHERE t.record_timestamp = sw.createdTimeStamp
              AND t.glossary_timestamp IN ($placeholders)
          ) = ?
          ORDER BY sw.createdTimeStamp DESC
        ''';
        args = [...tagTimestamps, tagTimestamps.length];
      }

      final rows = await db.rawQuery(sql, args);

      // Build records with their tags
      final records = <SinceWhenRecord>[];
      for (final row in rows) {
        final tags = await _getTagsForRecord(
          db,
          row['createdTimeStamp']! as String,
        );
        records.add(SinceWhenRecordMapper.fromRow(row, tags));
      }

      return Right(records);
    } on Exception catch (e) {
      return Left(
        UnexpectedDatabaseError('Failed to query records by tags', e),
      );
    }
  }

  /// Gets all records matching the specified tag names based on [mode].
  ///
  /// - [TagMatchMode.any]: Returns records with at least one matching tag.
  /// - [TagMatchMode.all]: Returns records with all specified tags.
  ///
  /// Returns empty list if [tagNames] is empty.
  static Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByTagNames(
    Database db,
    List<String> tagNames, {
    TagMatchMode mode = TagMatchMode.any,
  }) async {
    if (tagNames.isEmpty) {
      return const Right([]);
    }

    try {
      final String sql;
      final List<Object?> args;

      if (mode == TagMatchMode.any) {
        // ANY: Records with at least one of the specified tags
        final placeholders = List.filled(tagNames.length, '?').join(', ');
        sql = '''
          SELECT DISTINCT sw.*
          FROM ${SqlStatements.tableSinceWhen} sw
          INNER JOIN ${SqlStatements.tableTags} t 
            ON sw.createdTimeStamp = t.record_timestamp
          INNER JOIN ${SqlStatements.tableTagGlossary} g
            ON t.glossary_timestamp = g.createdTimeStamp
          WHERE g.tagName IN ($placeholders)
          ORDER BY sw.createdTimeStamp DESC
        ''';
        args = tagNames;
      } else {
        // ALL: Records with all specified tags
        final placeholders = List.filled(tagNames.length, '?').join(', ');
        sql = '''
          SELECT sw.*
          FROM ${SqlStatements.tableSinceWhen} sw
          WHERE (
            SELECT COUNT(DISTINCT g.tagName)
            FROM ${SqlStatements.tableTags} t
            INNER JOIN ${SqlStatements.tableTagGlossary} g
              ON t.glossary_timestamp = g.createdTimeStamp
            WHERE t.record_timestamp = sw.createdTimeStamp
              AND g.tagName IN ($placeholders)
          ) = ?
          ORDER BY sw.createdTimeStamp DESC
        ''';
        args = [...tagNames, tagNames.length];
      }

      final rows = await db.rawQuery(sql, args);

      // Build records with their tags
      final records = <SinceWhenRecord>[];
      for (final row in rows) {
        final tags = await _getTagsForRecord(
          db,
          row['createdTimeStamp']! as String,
        );
        records.add(SinceWhenRecordMapper.fromRow(row, tags));
      }

      return Right(records);
    } on Exception catch (e) {
      return Left(
        UnexpectedDatabaseError('Failed to query records by tag names', e),
      );
    }
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

  // ═══════════════════════════════════════════════════════════════════════════
  // TAG GLOSSARY READ OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Gets a tag definition by its createdTimeStamp.
  static Future<Either<SinceWhenFailure, TagDefinition>>
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
        UnexpectedDatabaseError('Failed to get tag definition', e),
      );
    }
  }

  /// Gets a tag definition by its name.
  static Future<Either<SinceWhenFailure, TagDefinition>> getTagDefinitionByName(
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
        UnexpectedDatabaseError('Failed to get tag definition by name', e),
      );
    }
  }

  /// Gets all tag definitions from the glossary.
  static Future<Either<SinceWhenFailure, List<TagDefinition>>>
      getAllTagDefinitions(
    Database db,
  ) async {
    try {
      final rows = await db.rawQuery(SqlStatements.selectAllTagDefinitions);
      return Right(TagDefinitionMapper.fromRows(rows));
    } on Exception catch (e) {
      return Left(
        UnexpectedDatabaseError('Failed to get all tag definitions', e),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Gets all tags for a record from the junction table.
  static Future<List<TagDefinition>> _getTagsForRecord(
    Database db,
    String recordTimestamp,
  ) async {
    final tagRows = await db.rawQuery(
      SqlStatements.selectTagsForRecord,
      [recordTimestamp],
    );
    return TagDefinitionMapper.fromRows(tagRows);
  }
}
