// icodeforyou_flutter/packages/since_when/lib/src/data/_since_when_record_mapper.dart

import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/sql/_sql_statements.dart';

/// Maps between database rows and [SinceWhenRecord] entities.
///
/// This class is internal and should not be exported publicly.
abstract final class SinceWhenRecordMapper {
  /// Converts a database row to a [SinceWhenRecord].
  ///
  /// [row] is the map from the since_when table.
  /// [tags] is the list of tags from the junction table.
  static SinceWhenRecord fromRow(
    Map<String, dynamic> row,
    List<String> tags,
  ) {
    return SinceWhenRecord(
      id: row['id'] as int,
      createdTimeStamp: row['createdTimeStamp'] as String,
      parentTimeStamp: row['parentTimeStamp'] as String?,
      reviewedTimeStamp: row['reviewedTimeStamp'] as String,
      editedTimeStamp: row['editedTimeStamp'] as String,
      metaTimeStamp: row['metaTimeStamp'] as String?,
      metaData: row['metaData'] as String,
      sequenceNumber: row['sequenceNumber'] as int,
      dataString: row['dataString'] as String,
      category: row['category'] as String,
      tags: tags,
    );
  }

  /// Converts a [SinceWhenRecord] to a list of values for SQL insertion.
  ///
  /// Returns values in the order expected by [SqlStatements.insertRecord]:
  /// createdTimeStamp, parentTimeStamp, reviewedTimeStamp, editedTimeStamp,
  /// metaTimeStamp, metaData, sequenceNumber, dataString, category
  ///
  /// Note: Does NOT include id (auto-generated) or tags (separate table).
  static List<Object?> toInsertValues(SinceWhenRecord record) {
    return [
      record.createdTimeStamp,
      record.parentTimeStamp,
      record.reviewedTimeStamp,
      record.editedTimeStamp,
      record.metaTimeStamp,
      record.metaData,
      record.sequenceNumber,
      record.dataString,
      record.category,
    ];
  }

  /// Converts creation parameters to a list of values for SQL insertion.
  ///
  /// Used during record creation when we don't yet have a full record.
  static List<Object?> toInsertValuesFromParams({
    required String createdTimeStamp,
    required String? parentTimeStamp,
    required String reviewedTimeStamp,
    required String editedTimeStamp,
    required String? metaTimeStamp,
    required String metaData,
    required int sequenceNumber,
    required String dataString,
    required String category,
  }) {
    return [
      createdTimeStamp,
      parentTimeStamp,
      reviewedTimeStamp,
      editedTimeStamp,
      metaTimeStamp,
      metaData,
      sequenceNumber,
      dataString,
      category,
    ];
  }
}
