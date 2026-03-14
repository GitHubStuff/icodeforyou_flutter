// lib/src/domain/since_when_record.dart

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

/// A record stored in the [since_when] table.
///
/// All timestamps are milliseconds since epoch (INTEGER in SQLite).
/// [id] is null for records that have not yet been persisted.
class SinceWhenRecord extends Equatable {
  const SinceWhenRecord({
    required this.createdTimeStamp,
    required this.reviewedTimeStamp,
    required this.editedTimeStamp,
    required this.metaData,
    required this.sequenceNumber,
    required this.dataString,
    required this.category,
    this.id,
    this.parentTimeStamp,
    this.metaTimeStamp,
  });

  factory SinceWhenRecord.fromRow(Map<String, dynamic> row) {
    return SinceWhenRecord(
      id: row['id'] as int,
      createdTimeStamp: row['createdTimeStamp'] as int,
      parentTimeStamp: row['parentTimeStamp'] as int?,
      reviewedTimeStamp: row['reviewedTimeStamp'] as int,
      editedTimeStamp: row['editedTimeStamp'] as int,
      metaTimeStamp: row['metaTimeStamp'] as int?,
      metaData: row['metaData'] as String,
      sequenceNumber: row['sequenceNumber'] as int,
      dataString: row['dataString'] as String,
      category: row['category'] as String,
    );
  }

  /// Database primary key. Null for records not yet persisted.
  final int? id;

  /// Unique record identifier — ms since epoch.
  final int createdTimeStamp;

  /// Parent record's [createdTimeStamp]; null for root records.
  final int? parentTimeStamp;

  /// Timestamp of the last review — ms since epoch.
  final int reviewedTimeStamp;

  /// Timestamp of the last edit — ms since epoch.
  final int editedTimeStamp;

  /// Optional metadata timestamp — ms since epoch.
  final int? metaTimeStamp;

  /// Short metadata string (~100 characters guideline).
  final String metaData;

  /// Ordering within sibling records; 0 for root records.
  final int sequenceNumber;

  /// Primary data content.
  final String dataString;

  /// Free-form category classification.
  final String category;

  /// Returns a map suitable for [sqflite] insert/update operations.
  ///
  /// Excludes [id] — the database assigns this on insert.
  Map<String, Object?> toRow() {
    return {
      'createdTimeStamp': createdTimeStamp,
      'parentTimeStamp': parentTimeStamp,
      'reviewedTimeStamp': reviewedTimeStamp,
      'editedTimeStamp': editedTimeStamp,
      'metaTimeStamp': metaTimeStamp,
      'metaData': metaData,
      'sequenceNumber': sequenceNumber,
      'dataString': dataString,
      'category': category,
    };
  }

  SinceWhenRecord copyWith({
    int? id,
    int? createdTimeStamp,
    int? reviewedTimeStamp,
    int? editedTimeStamp,
    String? metaData,
    int? sequenceNumber,
    String? dataString,
    String? category,
    Option<int>? parentTimeStamp,
    Option<int>? metaTimeStamp,
  }) {
    return SinceWhenRecord(
      id: id ?? this.id,
      createdTimeStamp: createdTimeStamp ?? this.createdTimeStamp,
      reviewedTimeStamp: reviewedTimeStamp ?? this.reviewedTimeStamp,
      editedTimeStamp: editedTimeStamp ?? this.editedTimeStamp,
      metaData: metaData ?? this.metaData,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      dataString: dataString ?? this.dataString,
      category: category ?? this.category,
      parentTimeStamp: parentTimeStamp == null
          ? this.parentTimeStamp
          : parentTimeStamp.toNullable(),
      metaTimeStamp: metaTimeStamp == null
          ? this.metaTimeStamp
          : metaTimeStamp.toNullable(),
    );
  }

  @override
  List<Object?> get props => [
        id,
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
