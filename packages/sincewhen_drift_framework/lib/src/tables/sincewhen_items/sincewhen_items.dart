// packages/sincewhen_drift_framework/lib/src/tables/sincewhen_items/sincewhen_items.dart

import 'package:drift/drift.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

/// {@template sincewhen_items.dart}
/// Core record table: one row per since-when entry.
///
/// Auto-incrementing primary key, a unique creation timestamp, review and
/// edit timestamps, optional parent and event timestamps, a defaulted
/// sequence number, optional metadata, an optional summary, and required
/// content.
/// {@endtemplate}
@UseRowClass(SinceWhenItem) //Connects to the pure dart model
class SinceWhenItems extends Table {
  @override
  String get tableName => 'sinceWhen';

  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// `createdTimestamp INTEGER NOT NULL UNIQUE`.
  ///
  /// Explicitly named to keep the column camelCase. This is the foreign
  /// key target for `TagItems`, so the `unique()` constraint is
  /// required — SQLite rejects foreign keys that reference
  /// non-uniquely-constrained columns.
  IntColumn get createdTimestamp =>
      integer().named('createdTimestamp').unique()();

  /// `reviewedTimestamp INTEGER NOT NULL`.
  IntColumn get reviewedTimestamp => integer().named('reviewedTimestamp')();

  /// `editedTimestamp INTEGER NOT NULL`.
  IntColumn get editedTimestamp => integer().named('editedTimestamp')();

  /// `parentTimestamp INTEGER` (nullable).
  IntColumn get parentTimestamp =>
      integer().named('parentTimestamp').nullable()();

  /// `eventTimestamp INTEGER` (nullable).
  IntColumn get eventTimestamp =>
      integer().named('eventTimestamp').nullable()();

  /// `sequenceNumber INTEGER NOT NULL DEFAULT 0`.
  IntColumn get sequenceNumber =>
      integer().named('sequenceNumber').withDefault(const Constant(0))();

  /// `metaData TEXT` (nullable).
  TextColumn get metaData => text().named('metaData').nullable()();

  /// `tldr TEXT` (nullable).
  TextColumn get tldr => text().named('tldr').nullable()();

  /// `content TEXT NOT NULL`.
  TextColumn get content => text()();
}
