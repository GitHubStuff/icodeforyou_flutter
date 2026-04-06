// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';

/// A link record stored in the [since_when_tags] table.
///
/// Represents the many-to-many relationship between [since_when] records
/// and [since_when_tag_glossary] entries.
///
/// [id] is null for records that have not yet been persisted.
/// [recordTimestamp] references [since_when.createdTimeStamp].
/// [glossaryTimestamp] references [since_when_tag_glossary.createdTimeStamp].
/// The pair ([recordTimestamp], [glossaryTimestamp]) is unique in the table.
class RecordTag extends Equatable {
  const RecordTag({
    required this.recordTimestamp,
    required this.glossaryTimestamp,
    this.id,
  });

  factory RecordTag.fromRow(Map<String, dynamic> row) {
    return RecordTag(
      id: row['id'] as int,
      recordTimestamp: row['record_timestamp'] as int,
      glossaryTimestamp: row['glossary_timestamp'] as int,
    );
  }

  /// Database primary key. Null for records not yet persisted.
  final int? id;

  /// Foreign key → [since_when.createdTimeStamp].
  final int recordTimestamp;

  /// Foreign key → [since_when_tag_glossary.createdTimeStamp].
  final int glossaryTimestamp;

  /// Returns a map suitable for [sqflite] insert operations.
  ///
  /// Excludes [id] — the database assigns this on insert.
  Map<String, Object?> toRow() {
    return {
      'record_timestamp': recordTimestamp,
      'glossary_timestamp': glossaryTimestamp,
    };
  }

  RecordTag copyWith({
    int? id,
    int? recordTimestamp,
    int? glossaryTimestamp,
  }) {
    return RecordTag(
      id: id ?? this.id,
      recordTimestamp: recordTimestamp ?? this.recordTimestamp,
      glossaryTimestamp: glossaryTimestamp ?? this.glossaryTimestamp,
    );
  }

  @override
  List<Object?> get props => [id, recordTimestamp, glossaryTimestamp];
}
