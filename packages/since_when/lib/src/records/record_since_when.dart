// lib/src/records/record_since_when.dart

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

/// A record stored in the [since_when] table.
///
/// All timestamps are milliseconds since epoch (INTEGER in SQLite).
/// [id] is null for records that have not yet been persisted.
class RecordSinceWhen extends Equatable {
  const RecordSinceWhen({
    required this.createdTimeStamp,
    required this.reviewedTimeStamp,
    required this.editedTimeStamp,
    required this.metaData,
    required this.sequenceNumber,
    required this.data,
    this.id,
    this.parentTimeStamp,
    this.metaTimeStamp,
  });

  factory RecordSinceWhen.fromRow(Map<String, dynamic> row) {
    return RecordSinceWhen(
      id: row['id'] as int,
      createdTimeStamp: row['createdTimeStamp'] as int,
      parentTimeStamp: row['parentTimeStamp'] as int?,
      reviewedTimeStamp: row['reviewedTimeStamp'] as int,
      editedTimeStamp: row['editedTimeStamp'] as int,
      metaTimeStamp: row['metaTimeStamp'] as int?,
      metaData: row['metaData'] as String,
      sequenceNumber: row['sequenceNumber'] as int,
      data: row['data'] as String,
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
  final String data;

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
      'data': data,
    };
  }

  RecordSinceWhen copyWith({
    int? id,
    int? createdTimeStamp,
    int? reviewedTimeStamp,
    int? editedTimeStamp,
    String? metaData,
    int? sequenceNumber,
    String? data,
    Option<int>? parentTimeStamp,
    Option<int>? metaTimeStamp,
  }) {
    return RecordSinceWhen(
      id: id ?? this.id,
      createdTimeStamp: createdTimeStamp ?? this.createdTimeStamp,
      reviewedTimeStamp: reviewedTimeStamp ?? this.reviewedTimeStamp,
      editedTimeStamp: editedTimeStamp ?? this.editedTimeStamp,
      metaData: metaData ?? this.metaData,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      data: data ?? this.data,
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
        data,
      ];
}
