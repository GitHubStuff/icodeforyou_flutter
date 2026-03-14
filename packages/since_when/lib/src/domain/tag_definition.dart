// lib/src/domain/tag_definition.dart

import 'package:equatable/equatable.dart';

/// A tag definition stored in the [since_when_tag_glossary] table.
///
/// [id] is null for records that have not yet been persisted.
/// [createdTimeStamp] is milliseconds since epoch (INTEGER in SQLite).
class TagDefinition extends Equatable {
  const TagDefinition({
    required this.createdTimeStamp,
    required this.tagName,
    required this.color,
    this.id,
  });

  factory TagDefinition.fromRow(Map<String, dynamic> row) {
    return TagDefinition(
      id: row['id'] as int,
      createdTimeStamp: row['createdTimeStamp'] as int,
      tagName: row['tagName'] as String,
      color: row['color'] as int,
    );
  }

  /// Database primary key. Null for records not yet persisted.
  final int? id;

  /// Unique tag identifier — ms since epoch.
  final int createdTimeStamp;

  /// Unique tag name. Cannot be empty.
  final String tagName;

  /// Tag colour as a packed ARGB integer.
  final int color;

  /// Returns a map suitable for [sqflite] insert/update operations.
  ///
  /// Excludes [id] — the database assigns this on insert.
  Map<String, Object?> toRow() {
    return {
      'createdTimeStamp': createdTimeStamp,
      'tagName': tagName,
      'color': color,
    };
  }

  TagDefinition copyWith({
    int? id,
    int? createdTimeStamp,
    String? tagName,
    int? color,
  }) {
    return TagDefinition(
      id: id ?? this.id,
      createdTimeStamp: createdTimeStamp ?? this.createdTimeStamp,
      tagName: tagName ?? this.tagName,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [id, createdTimeStamp, tagName, color];
}
