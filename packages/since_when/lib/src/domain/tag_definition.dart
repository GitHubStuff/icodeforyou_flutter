// lib/src/domain/tag_definition.dart

import 'package:equatable/equatable.dart';

/// A tag definition with name and color.
///
/// Example:
/// ```dart
/// final tag = TagDefinition(
///   id: 1,
///   createdTimeStamp: '2024-01-15T10:30:00.000Z',
///   tagName: 'flutter',
///   color: 0xFF2196F3,
/// );
/// ```
class TagDefinition extends Equatable {
  const TagDefinition({
    required this.id,
    required this.createdTimeStamp,
    required this.tagName,
    required this.color,
  });

  factory TagDefinition.fromJson(Map<String, dynamic> json) {
    return TagDefinition(
      id: json['id'] as int,
      createdTimeStamp: json['createdTimeStamp'] as String,
      tagName: json['tagName'] as String,
      color: json['color'] as int,
    );
  }

  final int id;
  final String createdTimeStamp;
  final String tagName;
  final int color;

  TagDefinition copyWith({
    int? id,
    String? createdTimeStamp,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdTimeStamp': createdTimeStamp,
      'tagName': tagName,
      'color': color,
    };
  }

  @override
  List<Object?> get props => [id, createdTimeStamp, tagName, color];

  @override
  String toString() {
    final hex = color.toRadixString(16).toUpperCase();
    return 'TagDefinition(tagName: $tagName, color: 0x$hex)';
  }
}
