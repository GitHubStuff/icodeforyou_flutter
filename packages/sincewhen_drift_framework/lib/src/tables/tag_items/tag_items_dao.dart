// packages/sincewhen_drift_framework/lib/src/tables/tag_items/tag_items_dao.dart

import 'package:drift/drift.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

part 'tag_items_dao.g.dart';

/// Data access for [TagItems].
@DriftAccessor(tables: [TagItems])
class TagItemsDao extends DatabaseAccessor<SinceWhenDatabase>
    with _$TagItemsDaoMixin {
  /// Creates the accessor over the attached database.
  TagItemsDao(super.attachedDatabase);

  /// Returns all tag links.
  Future<List<TagItem>> allItems() => select(tagItems).get();

  /// Streams all tag links, re-emitting on change.
  Stream<List<TagItem>> watchAllItems() => select(tagItems).watch();

  /// Returns the tag links attached to the since-when record with the
  /// given creation timestamp.
  Future<List<TagItem>> itemsForRecord(int recordTimestamp) =>
      _forRecord(recordTimestamp).get();

  /// Streams the tag links attached to the since-when record with the
  /// given creation timestamp, re-emitting on change.
  Stream<List<TagItem>> watchItemsForRecord(int recordTimestamp) =>
      _forRecord(recordTimestamp).watch();

  /// Returns the tag links using the glossary entry with the given
  /// creation timestamp.
  Future<List<TagItem>> itemsForGlossary(int glossaryTimestamp) => (select(
    tagItems,
  )..where((item) => item.glossaryTimestamp.equals(glossaryTimestamp))).get();

  /// Returns the total number of tag links.
  Future<int> itemCount() => tagItems.count().getSingle();

  /// Streams the total number of tag links, re-emitting on change.
  Stream<int> watchItemCount() => tagItems.count().watchSingle();

  /// Inserts [item] and returns the persisted row, including its
  /// database-assigned [TagItem.id].
  Future<TagItem> insertItem(TagItem item) =>
      into(tagItems).insertReturning(_toInsertCompanion(item));

  /// Deletes the row matching [TagItem.id]. Returns `true` when a row
  /// was deleted.
  Future<bool> deleteItem(TagItem item) async {
    final rowsDeleted = await (delete(
      tagItems,
    )..where((row) => row.id.equals(item.id))).go();
    return rowsDeleted > 0;
  }

  /// Selects the tag links for one since-when record.
  SimpleSelectStatement<$TagItemsTable, TagItem> _forRecord(
    int recordTimestamp,
  ) =>
      select(tagItems)
        ..where((item) => item.recordTimestamp.equals(recordTimestamp));

  /// Maps [item] to an insert companion, letting the database assign the
  /// primary key.
  TagItemsCompanion _toInsertCompanion(TagItem item) =>
      TagItemsCompanion.insert(
        recordTimestamp: item.recordTimestamp,
        glossaryTimestamp: item.glossaryTimestamp,
      );
}
