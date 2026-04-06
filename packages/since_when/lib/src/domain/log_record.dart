
// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/domain/log_action.dart';

/// An audit entry stored in the [since_when_log] table.
///
/// [id] is null for records that have not yet been persisted.
/// [logTimeStamp] is milliseconds since epoch (INTEGER in SQLite).
/// [action] is stored as TEXT using [LogAction.name].
/// [targetId] and [detail] are optional.
class LogRecord extends Equatable {
  const LogRecord({
    required this.logTimeStamp,
    required this.action,
    required this.tableName,
    this.id,
    this.targetId,
    this.detail,
  });

  factory LogRecord.fromRow(Map<String, dynamic> row) {
    return LogRecord(
      id: row['id'] as int,
      logTimeStamp: row['logTimeStamp'] as int,
      action: LogAction.values.byName(row['action'] as String),
      tableName: row['tableName'] as String,
      targetId: row['targetId'] as int?,
      detail: row['detail'] as String?,
    );
  }

  /// Database primary key. Null for records not yet persisted.
  final int? id;

  /// Timestamp of this log entry — ms since epoch.
  final int logTimeStamp;

  /// The action that was performed.
  final LogAction action;

  /// The table that was affected.
  final String tableName;

  /// [createdTimeStamp] of the affected row; null for table-level operations.
  final int? targetId;

  /// Optional free-text context (error message, diff, etc.).
  final String? detail;

  /// Returns a map suitable for [sqflite] insert operations.
  ///
  /// Excludes [id] — the database assigns this on insert.
  /// [action] is serialised as its name string.
  Map<String, Object?> toRow() {
    return {
      'logTimeStamp': logTimeStamp,
      'action': action.name,
      'tableName': tableName,
      'targetId': targetId,
      'detail': detail,
    };
  }

  LogRecord copyWith({
    int? id,
    int? logTimeStamp,
    LogAction? action,
    String? tableName,
    Option<int>? targetId,
    Option<String>? detail,
  }) {
    return LogRecord(
      id: id ?? this.id,
      logTimeStamp: logTimeStamp ?? this.logTimeStamp,
      action: action ?? this.action,
      tableName: tableName ?? this.tableName,
      targetId: targetId == null ? this.targetId : targetId.toNullable(),
      detail: detail == null ? this.detail : detail.toNullable(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        logTimeStamp,
        action,
        tableName,
        targetId,
        detail,
      ];
}
