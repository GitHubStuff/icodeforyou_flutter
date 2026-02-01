// lib/src/data/_tag_definition_mapper.dart

import 'package:since_when/src/domain/tag_definition.dart';

/// Maps between database rows and [TagDefinition] entities.
///
/// This class is internal and should not be exported publicly.
abstract final class TagDefinitionMapper {
  /// Converts a database row to a [TagDefinition].
  static TagDefinition fromRow(Map<String, dynamic> row) {
    return TagDefinition(
      id: row['id'] as int,
      createdTimeStamp: row['createdTimeStamp'] as String,
      tagName: row['tagName'] as String,
      tagDescription: row['tagDescription'] as String,
      color: row['color'] as int,
    );
  }

  /// Converts a list of database rows to [TagDefinition] list.
  static List<TagDefinition> fromRows(List<Map<String, dynamic>> rows) {
    return rows.map(fromRow).toList();
  }

  /// Converts creation parameters to a list of values for SQL insertion.
  ///
  /// Order: createdTimeStamp, tagName, tagDescription, color
  static List<Object?> toInsertValues({
    required String createdTimeStamp,
    required String tagName,
    required String tagDescription,
    required int color,
  }) {
    return [
      createdTimeStamp,
      tagName,
      tagDescription,
      color,
    ];
  }

  /// Converts update parameters to a list of values for SQL update.
  ///
  /// Order: tagName, tagDescription, color, createdTimeStamp (WHERE)
  static List<Object?> toUpdateValues({
    required String createdTimeStamp,
    required String tagName,
    required String tagDescription,
    required int color,
  }) {
    return [
      tagName,
      tagDescription,
      color,
      createdTimeStamp,
    ];
  }
}
