// packages/sincewhen_drift_framework/lib/src/tables/sincewhen_items/sincewhen_items_dao.dart

import 'package:drift/drift.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

// NOTE To generate : '% dart run build_runner build'
part 'sincewhen_items_dao.g.dart';

/// Data access for [SinceWhenItems].
@DriftAccessor(tables: [SinceWhenItems])
class SinceWhenItemsDao extends DatabaseAccessor<SinceWhenDatabase>
    with _$SinceWhenItemsDaoMixin {
  /// Creates the accessor over the attached database.
  SinceWhenItemsDao(super.attachedDatabase);

  /// Returns all items ordered by creation timestamp.
  Future<List<SinceWhenItem>> allItems() => _orderedByCreatedTimestamp().get();

  /// Streams all items ordered by creation timestamp, re-emitting on
  /// change.
  Stream<List<SinceWhenItem>> watchAllItems() =>
      _orderedByCreatedTimestamp().watch();

  /// Returns the item with the given unique creation timestamp, or `null`
  /// if none exists.
  Future<SinceWhenItem?> itemByCreatedTimestamp(int createdTimestamp) =>
      (select(sinceWhenItems)
            ..where((item) => item.createdTimestamp.equals(createdTimestamp)))
          .getSingleOrNull();

  /// Returns the total number of items.
  Future<int> itemCount() => sinceWhenItems.count().getSingle();

  /// Streams the total number of items, re-emitting on change.
  Stream<int> watchItemCount() => sinceWhenItems.count().watchSingle();

  /// Inserts [item] and returns the persisted row, including its
  /// database-assigned [SinceWhenItem.id].
  Future<SinceWhenItem> insertItem(SinceWhenItem item) =>
      into(sinceWhenItems).insertReturning(_toInsertCompanion(item));

  /// Updates the row matching [SinceWhenItem.id]. Returns `true` when a
  /// row was updated.
  Future<bool> updateItem(SinceWhenItem item) async {
    final rowsUpdated = await (update(
      sinceWhenItems,
    )..where((row) => row.id.equals(item.id))).write(_toUpdateCompanion(item));
    return rowsUpdated > 0;
  }

  /// Deletes the row matching [SinceWhenItem.id]. Returns `true` when a
  /// row was deleted.
  Future<bool> deleteItem(SinceWhenItem item) async {
    final rowsDeleted = await (delete(
      sinceWhenItems,
    )..where((row) => row.id.equals(item.id))).go();
    return rowsDeleted > 0;
  }

  /// Selects all items ordered by creation timestamp.
  SimpleSelectStatement<$SinceWhenItemsTable, SinceWhenItem>
  _orderedByCreatedTimestamp() =>
      select(sinceWhenItems)
        ..orderBy([(item) => OrderingTerm.asc(item.createdTimestamp)]);

  /// Maps [item] to an insert companion, letting the database assign the
  /// primary key.
  SinceWhenItemsCompanion _toInsertCompanion(SinceWhenItem item) =>
      SinceWhenItemsCompanion.insert(
        createdTimestamp: item.createdTimestamp,
        reviewedTimestamp: item.reviewedTimestamp,
        editedTimestamp: item.editedTimestamp,
        sequenceNumber: Value(item.sequenceNumber),
        parentTimestamp: Value(item.parentTimestamp),
        eventTimestamp: Value(item.eventTimestamp),
        metaData: Value(item.metaData),
        //+ CHANGED
        tldr: Value(item.tldr),
        content: item.content,
      );

  /// Maps [item] to an update companion covering every non-key column.
  SinceWhenItemsCompanion _toUpdateCompanion(SinceWhenItem item) =>
      SinceWhenItemsCompanion(
        createdTimestamp: Value(item.createdTimestamp),
        reviewedTimestamp: Value(item.reviewedTimestamp),
        editedTimestamp: Value(item.editedTimestamp),
        sequenceNumber: Value(item.sequenceNumber),
        parentTimestamp: Value(item.parentTimestamp),
        eventTimestamp: Value(item.eventTimestamp),
        metaData: Value(item.metaData),
        //+ CHANGED
        tldr: Value(item.tldr),
        content: Value(item.content),
      );
}
