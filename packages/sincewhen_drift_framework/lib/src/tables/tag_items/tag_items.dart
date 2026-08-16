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
@UseRowClass(TagItem) //Connects to the pure dart model
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
  )();

  /// `glossary_timestamp INTEGER NOT NULL` referencing
  /// `GlossaryItems.createdTimestamp` with `ON DELETE CASCADE`.
  IntColumn get glossaryTimestamp => integer().references(
    GlossaryItems,
    #createdTimestamp,
    onDelete: KeyAction.cascade,
  )();

  /// `UNIQUE(record_timestamp, glossary_timestamp)`.
  @override
  List<Set<Column>> get uniqueKeys => [
    {recordTimestamp, glossaryTimestamp},
  ];
}
