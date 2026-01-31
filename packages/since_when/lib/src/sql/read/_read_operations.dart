// icodeforyou_flutter/packages/since_when/lib/src/sql/read/_read_operations.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/data/_since_when_record_mapper.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/domain/since_when_record.dart';
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

  /// Gets all records matching a specific tag.
  static Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByTag(
    Database db,
    String tag,
  ) async {
    // Delegate to getByTags with a single tag and ANY mode
    return getByTags(db, [tag], mode: TagMatchMode.any);
  }

  /// Gets all records matching the specified tags based on [mode].
  ///
  /// - [TagMatchMode.any]: Returns records with at least one matching tag.
  /// - [TagMatchMode.all]: Returns records with all specified tags.
  ///
  /// Returns empty list if [tags] is empty.
  static Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByTags(
    Database db,
    List<String> tags, {
    TagMatchMode mode = TagMatchMode.any,
  }) async {
    if (tags.isEmpty) {
      return const Right([]);
    }

    try {
      final String sql;
      final List<Object?> args;

      if (mode == TagMatchMode.any) {
        // ANY: Records with at least one of the specified tags
        final placeholders = List.filled(tags.length, '?').join(', ');
        sql = '''
          SELECT DISTINCT sw.*
          FROM ${SqlStatements.tableSinceWhen} sw
          INNER JOIN ${SqlStatements.tableTags} t 
            ON sw.createdTimeStamp = t.created_time_stamp
          WHERE t.tag IN ($placeholders)
          ORDER BY sw.createdTimeStamp DESC
        ''';
        args = tags;
      } else {
        // ALL: Records with all specified tags
        final placeholders = List.filled(tags.length, '?').join(', ');
        sql = '''
          SELECT sw.*
          FROM ${SqlStatements.tableSinceWhen} sw
          WHERE (
            SELECT COUNT(DISTINCT t.tag)
            FROM ${SqlStatements.tableTags} t
            WHERE t.created_time_stamp = sw.createdTimeStamp
              AND t.tag IN ($placeholders)
          ) = ?
          ORDER BY sw.createdTimeStamp DESC
        ''';
        args = [...tags, tags.length];
      }

      final rows = await db.rawQuery(sql, args);

      // Build records with their tags
      final records = <SinceWhenRecord>[];
      for (final row in rows) {
        final createdTimeStamp = row['createdTimeStamp'] as String;
        final tagRows = await db.rawQuery(
          SqlStatements.selectTagsForRecord,
          [createdTimeStamp],
        );
        final recordTags = tagRows.map((r) => r['tag'] as String).toList();

        records.add(SinceWhenRecordMapper.fromRow(row, recordTags));
      }

      return Right(records);
    } on Exception catch (e) {
      return Left(
        UnexpectedDatabaseError('Failed to query records by tags', e),
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
}
