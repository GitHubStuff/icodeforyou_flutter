// packages/sincewhen_drift_framework/lib/src/tables/tag_items/tag_items.dart

import 'package:drift/drift.dart';
import 'package:sincewhen_drift_framework/src/tables/glossary_items/glossary_items.dart'
    show GlossaryItems;
import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items.dart'
    show SinceWhenItems;
import 'package:sincewhen_models/sincewhen_models.dart';

/// Join table linking [SinceWhenItems] records to [GlossaryItems] entries.
///
/// Auto-incrementing primary key, two cascading foreign keys keyed on
/// `createdTimestamp`, and a composite unique constraint across both
/// foreign key columns.
///
/// The composite `UNIQUE(record_timestamp, glossary_timestamp)` creates an
/// implicit index whose leading column serves "tags for this record"
/// lookups, replacing the legacy `idx_tags_record`. The reverse direction
/// ("records with this tag") needs its own index, declared below.
///
/// The coverage markers below sit on lines that are provably unreachable
/// at runtime: every drift DSL method throws [UnsupportedError] via
/// `_isGenerated()` (the DSL exists only for `drift_dev` to parse), so
/// `integer()` throws before any multi-line expression's trailing `()` —
/// or [uniqueKeys]' list literal — can execute. [uniqueKeys] uses an
/// `ignore-start`/`ignore-end` fence rather than an inline marker because
/// `dart format` wraps a trailing comment on its `=> [` line onto its own
/// line, where an inline marker ignores nothing.
@UseRowClass(TagItem) //Connects to the pure dart model
@TableIndex(name: 'idx_tags_glossary', columns: {#glossaryTimestamp})
class TagItems extends Table {
  @override
  String get tableName => 'tags';

  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// `record_timestamp INTEGER NOT NULL` referencing
  /// `SinceWhenItems.createdTimestamp` with `ON DELETE CASCADE`.
  IntColumn get recordTimestamp => integer().references(
    SinceWhenItems,
    #createdTimestamp,
    onDelete: KeyAction.cascade,
  )(); // coverage:ignore-line

  /// `glossary_timestamp INTEGER NOT NULL` referencing
  /// `GlossaryItems.createdTimestamp` with `ON DELETE CASCADE`.
  IntColumn get glossaryTimestamp => integer().references(
    GlossaryItems,
    #createdTimestamp,
    onDelete: KeyAction.cascade,
  )(); // coverage:ignore-line

  /// `UNIQUE(record_timestamp, glossary_timestamp)`.
  @override
  // coverage:ignore-start
  List<Set<Column>> get uniqueKeys => [
    {recordTimestamp, glossaryTimestamp},
  ];
  // coverage:ignore-end
}
