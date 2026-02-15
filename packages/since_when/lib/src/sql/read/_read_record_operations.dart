// lib/src/sql/read/_read_record_operations.dart

import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/data/_since_when_record_mapper.dart';
import 'package:since_when/src/data/_tag_definition_mapper.dart';
import 'package:since_when/src/domain/data_store_failure.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/domain/tag_definition.dart';
import 'package:since_when/src/domain/tag_match_mode.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:sqflite/sqflite.dart';

/// Handles Read operations for SinceWhen records.
abstract final class ReadRecordOperations {
  /// Gets a record by its createdTimeStamp.
  ///
  /// Returns the record and all its direct children (shallow query),
  /// ordered by sequenceNumber.
  static Future<Either<DataStoreFailure, List<SinceWhenRecord>>>
      getByCreatedTimeStamp(
    Database db,
    String createdTimeStamp,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('getByCreatedTimeStamp not yet implemented');
  }

  /// Gets all records matching a specific tag by glossary timestamp.
  static Future<Either<DataStoreFailure, List<SinceWhenRecord>>>
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
        UnexpectedStoreError('Failed to query records by tag', e),
      );
    }
  }

  /// Gets all records matching a specific tag by tag name.
  static Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagName(
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
        UnexpectedStoreError('Failed to query records by tag name', e),
      );
    }
  }

  /// Gets all records matching the specified tags based on [mode].
  ///
  /// Returns empty list if [tagTimestamps] is empty.
  static Future<Either<DataStoreFailure, List<SinceWhenRecord>>>
      getByTagTimestamps(
    Database db,
    List<String> tagTimestamps, {
    TagMatchMode mode = TagMatchMode.any,
  }) async {
    if (tagTimestamps.isEmpty) return const Right([]);

    try {
      final ph = List.filled(tagTimestamps.length, '?').join(', ');
      const t = SqlStatements.tableSinceWhen;
      const j = SqlStatements.tableTags;

      final sql = mode == TagMatchMode.any
          ? 'SELECT DISTINCT sw.* FROM $t sw '
              'INNER JOIN $j t ON sw.createdTimeStamp = t.record_timestamp '
              'WHERE t.glossary_timestamp IN ($ph) '
              'ORDER BY sw.createdTimeStamp DESC'
          : 'SELECT sw.* FROM $t sw WHERE '
              '(SELECT COUNT(DISTINCT t.glossary_timestamp) FROM $j t '
              'WHERE t.record_timestamp = sw.createdTimeStamp '
              'AND t.glossary_timestamp IN ($ph)) = ? '
              'ORDER BY sw.createdTimeStamp DESC';

      final args = mode == TagMatchMode.any
          ? tagTimestamps
          : [...tagTimestamps, tagTimestamps.length];

      final rows = await db.rawQuery(sql, args);
      return Right(await _buildRecordsWithTags(db, rows));
    } on Exception catch (e) {
      return Left(
        UnexpectedStoreError('Failed to query records by tags', e),
      );
    }
  }

  /// Gets all records matching the specified tag names based on [mode].
  ///
  /// Returns empty list if [tagNames] is empty.
  static Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagNames(
    Database db,
    List<String> tagNames, {
    TagMatchMode mode = TagMatchMode.any,
  }) async {
    if (tagNames.isEmpty) return const Right([]);

    try {
      final ph = List.filled(tagNames.length, '?').join(', ');
      const t = SqlStatements.tableSinceWhen;
      const j = SqlStatements.tableTags;
      const g = SqlStatements.tableTagGlossary;

      final sql = mode == TagMatchMode.any
          ? 'SELECT DISTINCT sw.* FROM $t sw '
              'INNER JOIN $j t ON sw.createdTimeStamp = t.record_timestamp '
              'INNER JOIN $g g ON t.glossary_timestamp = g.createdTimeStamp '
              'WHERE g.tagName IN ($ph) '
              'ORDER BY sw.createdTimeStamp DESC'
          : 'SELECT sw.* FROM $t sw WHERE '
              '(SELECT COUNT(DISTINCT g.tagName) FROM $j t '
              'INNER JOIN $g g ON t.glossary_timestamp = g.createdTimeStamp '
              'WHERE t.record_timestamp = sw.createdTimeStamp '
              'AND g.tagName IN ($ph)) = ? '
              'ORDER BY sw.createdTimeStamp DESC';

      final args = mode == TagMatchMode.any
          ? tagNames
          : [...tagNames, tagNames.length];

      final rows = await db.rawQuery(sql, args);
      return Right(await _buildRecordsWithTags(db, rows));
    } on Exception catch (e) {
      return Left(
        UnexpectedStoreError('Failed to query records by tag names', e),
      );
    }
  }

  /// Gets all records in a category.
  static Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByCategory(
    Database db,
    String category,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('getByCategory not yet implemented');
  }

  /// Gets all root records (records with no parent).
  static Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getRootRecords(
    Database db,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('getRootRecords not yet implemented');
  }

  /// Gets all records in the database.
  static Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getAllRecords(
    Database db,
  ) async {
    // TODO(steven): Implement
    throw UnimplementedError('getAllRecords not yet implemented');
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Builds records list with their associated tags.
  static Future<List<SinceWhenRecord>> _buildRecordsWithTags(
    Database db,
    List<Map<String, Object?>> rows,
  ) async {
    final records = <SinceWhenRecord>[];
    for (final row in rows) {
      final tags = await _getTagsForRecord(
        db,
        row['createdTimeStamp']! as String,
      );
      records.add(SinceWhenRecordMapper.fromRow(row, tags));
    }
    return records;
  }

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
