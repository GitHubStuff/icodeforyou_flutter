// packages/sincewhen_drift_framework/lib/src/tables/glossary_items/glossary_items_dao.dart

import 'package:drift/drift.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/tables/glossary_items/glossary_items.dart';

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

  /// Returns the item whose color matches [colorArgb], or `null` when no
  /// item uses that color.
  Future<GlossaryItem?> itemWithColor(int colorArgb) => (select(
    glossaryItems,
  )..where((item) => item.colorArgb.equals(colorArgb))).getSingleOrNull();

  /// Selects all items ordered by tag.
  SimpleSelectStatement<$GlossaryItemsTable, GlossaryItem> _orderedByTag() =>
      select(glossaryItems)..orderBy([(item) => OrderingTerm.asc(item.tag)]);
}
