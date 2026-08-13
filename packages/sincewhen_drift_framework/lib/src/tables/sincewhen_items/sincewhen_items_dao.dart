// packages/sincewhen_drift_framework/lib/src/tables/sincewhen_items/sincewhen_items_dao.dart

import 'package:drift/drift.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items.dart';

part 'sincewhen_items_dao.g.dart';

/// Data access for [SinceWhenItems].
@DriftAccessor(tables: [SinceWhenItems])
class SinceWhenItemsDao extends DatabaseAccessor<SinceWhenDatabase>
    with _$SinceWhenItemsDaoMixin {
  /// Creates the accessor over the attached database.
  SinceWhenItemsDao(super.attachedDatabase);

  /// Returns all items ordered by creation timestamp.
  Future<List<SinceWhenItem>> allItems() => _orderedByCreatedTimeStamp().get();

  /// Streams all items ordered by creation timestamp, re-emitting on
  /// change.
  Stream<List<SinceWhenItem>> watchAllItems() =>
      _orderedByCreatedTimeStamp().watch();

  /// Returns the total number of items.
  Future<int> itemCount() => sinceWhenItems.count().getSingle();

  /// Streams the total number of items, re-emitting on change.
  Stream<int> watchItemCount() => sinceWhenItems.count().watchSingle();

  /// Selects all items ordered by creation timestamp.
  SimpleSelectStatement<$SinceWhenItemsTable, SinceWhenItem>
  _orderedByCreatedTimeStamp() =>
      select(sinceWhenItems)
        ..orderBy([(item) => OrderingTerm.asc(item.createdTimeStamp)]);
}
