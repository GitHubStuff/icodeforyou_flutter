// lib/src/data/_tag_definition_mapper.dart

import 'package:since_when/src/domain/tag_definition.dart';

abstract final class TagDefinitionMapper {
  static TagDefinition fromRow(Map<String, dynamic> row) {
    return TagDefinition(
      id: row['id'] as int,
      createdTimeStamp: row['createdTimeStamp'] as String,
      tagName: row['tagName'] as String,
      color: row['color'] as int,
    );
  }

  static List<TagDefinition> fromRows(List<Map<String, dynamic>> rows) {
    return rows.map(fromRow).toList();
  }

  /// Order: createdTimeStamp, tagName, color
  static List<Object?> toInsertValues({
    required String createdTimeStamp,
    required String tagName,
    required int color,
  }) {
    return [createdTimeStamp, tagName, color];
  }

  /// Order: tagName, color, createdTimeStamp (WHERE)
  static List<Object?> toUpdateValues({
    required String createdTimeStamp,
    required String tagName,
    required int color,
  }) {
    return [tagName, color, createdTimeStamp];
  }
}
