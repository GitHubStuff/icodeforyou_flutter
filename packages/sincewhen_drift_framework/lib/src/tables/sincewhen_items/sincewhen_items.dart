// packages/sincewhen_drift_framework/lib/src/tables/sincewhen_items/sincewhen_items.dart

import 'package:drift/drift.dart';

/// Core record table: one row per since-when entry.
///
/// Auto-incrementing primary key, a unique creation timestamp, review and
/// edit timestamps, optional parent and event timestamps, a defaulted
/// sequence number, optional metadata, and required content.
class SinceWhenItems extends Table {
  @override
  String get tableName => 'sinceWhen';

  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// `createdTimeStamp INTEGER NOT NULL UNIQUE`.
  ///
  /// Explicitly named to preserve the camelCase column name from the raw
  /// SQL schema. This is the foreign key target for `SinceWhenTags`, so
  /// the `unique()` constraint is required — SQLite rejects foreign keys
  /// that reference non-uniquely-constrained columns.
  IntColumn get createdTimeStamp =>
      integer().named('createdTimeStamp').unique()();

  /// `reviewedTimeStamp INTEGER NOT NULL`.
  IntColumn get reviewedTimeStamp => integer().named('reviewedTimeStamp')();

  /// `editedTimeStamp INTEGER NOT NULL`.
  IntColumn get editedTimeStamp => integer().named('editedTimeStamp')();

  /// `parentTimeStamp INTEGER` (nullable).
  IntColumn get parentTimeStamp =>
      integer().named('parentTimeStamp').nullable()();

  /// `eventTimeStamp INTEGER` (nullable).
  IntColumn get eventTimeStamp =>
      integer().named('eventTimeStamp').nullable()();

  /// `sequenceNumber INTEGER NOT NULL DEFAULT 0`.
  IntColumn get sequenceNumber =>
      integer().named('sequenceNumber').withDefault(const Constant(0))();

  /// `metaData TEXT` (nullable).
  TextColumn get metaData => text().named('metaData').nullable()();

  /// `content TEXT NOT NULL`.
  TextColumn get content => text()();
}
