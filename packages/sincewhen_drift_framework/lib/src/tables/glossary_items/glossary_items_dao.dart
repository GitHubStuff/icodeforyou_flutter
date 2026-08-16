// packages/sincewhen_drift_framework/lib/src/tables/glossary_items/glossary_items_dao.dart

import 'package:drift/drift.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/tables/glossary_items/glossary_items.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

// NOTE To generate : '% dart run build_runner build'
part 'glossary_items_dao.g.dart';

/// Data access for [GlossaryItems].
@DriftAccessor(tables: [GlossaryItems])
class GlossaryItemsDao extends DatabaseAccessor<SinceWhenDatabase>
    with _$GlossaryItemsDaoMixin {
  /// Creates the accessor over the attached database.
  GlossaryItemsDao(super.attachedDatabase);

  /// Returns all glossary items ordered by tag.
  Future<List<GlossaryItem>> allItems() => _orderedByTag().get();

  /// Streams all glossary items ordered by tag, re-emitting on change.
  Stream<List<GlossaryItem>> watchAllItems() => _orderedByTag().watch();

  /// Returns the packed ARGB color values of all glossary items.
  Future<Set<int>> allColorArgbValues() async {
    final query = selectOnly(glossaryItems)
      ..addColumns([glossaryItems.colorArgb]);
    final rows = await query.get();
    return rows.map((row) => row.read(glossaryItems.colorArgb)!).toSet();
  }

  /// Returns the total number of glossary items.
  Future<int> itemCount() => glossaryItems.count().getSingle();

  /// Streams the total number of glossary items, re-emitting on change.
  Stream<int> watchItemCount() => glossaryItems.count().watchSingle();

  /// Returns the item with the given unique [tag], or `null` if none
  /// exists.
  Future<GlossaryItem?> itemByTag(String tag) => (select(
    glossaryItems,
  )..where((item) => item.tag.equals(tag))).getSingleOrNull();

  /// Returns the item whose color matches [colorArgb], or `null` when no
  /// item uses that color.
  Future<GlossaryItem?> itemWithColor(int colorArgb) => (select(
    glossaryItems,
  )..where((item) => item.colorArgb.equals(colorArgb))).getSingleOrNull();

  /// Inserts [item] and returns the persisted row, including its
  /// database-assigned [GlossaryItem.id].
  Future<GlossaryItem> insertItem(GlossaryItem item) =>
      into(glossaryItems).insertReturning(_toInsertCompanion(item));

  /// Updates the row matching [GlossaryItem.id]. Returns `true` when a
  /// row was updated.
  Future<bool> updateItem(GlossaryItem item) async {
    final rowsUpdated = await (update(
      glossaryItems,
    )..where((row) => row.id.equals(item.id))).write(_toUpdateCompanion(item));
    return rowsUpdated > 0;
  }

  /// Deletes the row matching [GlossaryItem.id]. Returns `true` when a
  /// row was deleted.
  Future<bool> deleteItem(GlossaryItem item) async {
    final rowsDeleted = await (delete(
      glossaryItems,
    )..where((row) => row.id.equals(item.id))).go();
    return rowsDeleted > 0;
  }

  /// Selects all items ordered by tag.
  SimpleSelectStatement<$GlossaryItemsTable, GlossaryItem> _orderedByTag() =>
      select(glossaryItems)..orderBy([(item) => OrderingTerm.asc(item.tag)]);

  /// Maps [item] to an insert companion, letting the database assign the
  /// primary key.
  GlossaryItemsCompanion _toInsertCompanion(GlossaryItem item) =>
      GlossaryItemsCompanion.insert(
        createdTimestamp: item.createdTimestamp,
        tag: item.tag,
        colorArgb: item.colorArgb,
      );

  /// Maps [item] to an update companion covering every non-key column.
  GlossaryItemsCompanion _toUpdateCompanion(GlossaryItem item) =>
      GlossaryItemsCompanion(
        createdTimestamp: Value(item.createdTimestamp),
        tag: Value(item.tag),
        colorArgb: Value(item.colorArgb),
      );
}
