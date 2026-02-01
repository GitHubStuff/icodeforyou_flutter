// lib/src/domain/tag_definition.dart

import 'package:equatable/equatable.dart';

/// A tag definition with name, description, and color.
///
/// Tags are stored in the glossary table and referenced by records
/// via the junction table. Each tag has a unique [createdTimeStamp]
/// as its primary key and a unique [tagName].
///
/// Example:
/// ```dart
/// final tag = TagDefinition(
///   id: 1,
///   createdTimeStamp: '2024-01-15T10:30:00.000Z',
///   tagName: 'flutter',
///   tagDescription: 'Flutter framework related',
///   color: 0xFF2196F3,
/// );
/// ```
class TagDefinition extends Equatable {
  /// Creates a [TagDefinition].
  const TagDefinition({
    required this.id,
    required this.createdTimeStamp,
    required this.tagName,
    required this.tagDescription,
    required this.color,
  });

  /// Creates from JSON map.
  factory TagDefinition.fromJson(Map<String, dynamic> json) {
    return TagDefinition(
      id: json['id'] as int,
      createdTimeStamp: json['createdTimeStamp'] as String,
      tagName: json['tagName'] as String,
      tagDescription: json['tagDescription'] as String,
      color: json['color'] as int,
    );
  }

  /// Auto-increment ID for internal database use.
  final int id;

  /// Unique identifier for this tag (ISO8601 UTC).
  ///
  /// This is the primary key used for relationships.
  final String createdTimeStamp;

  /// Unique tag name (case-sensitive, non-empty).
  final String tagName;

  /// Optional description of the tag's purpose.
  final String tagDescription;

  /// Color value as ARGB integer (e.g., 0xFF2196F3).
  ///
  /// Use `Color(tag.color)` to convert to Flutter Color.
  final int color;

  /// Creates a copy with modified fields.
  TagDefinition copyWith({
    int? id,
    String? createdTimeStamp,
    String? tagName,
    String? tagDescription,
    int? color,
  }) {
    return TagDefinition(
      id: id ?? this.id,
      createdTimeStamp: createdTimeStamp ?? this.createdTimeStamp,
      tagName: tagName ?? this.tagName,
      tagDescription: tagDescription ?? this.tagDescription,
      color: color ?? this.color,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdTimeStamp': createdTimeStamp,
      'tagName': tagName,
      'tagDescription': tagDescription,
      'color': color,
    };
  }

  @override
  List<Object?> get props => [
    id,
    createdTimeStamp,
    tagName,
    tagDescription,
    color,
  ];

  @override
  String toString() {
    final hex = color.toRadixString(16).toUpperCase();
    return 'TagDefinition(tagName: $tagName, color: 0x$hex)';
  }
}
