// packages/sincewhen_drift_framework/lib/src/tables/tag_items/tag_items_dao.dart

import 'package:drift/drift.dart';
import 'package:sincewhen_drift_framework/src/database/database.dart';
import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items.dart';

part 'tag_items_dao.g.dart';

/// Data access for [TagItems].
@DriftAccessor(tables: [TagItems])
class TagItemsDao extends DatabaseAccessor<SinceWhenDatabase>
    with _$TagItemsDaoMixin {
  /// Creates the accessor over the attached database.
  TagItemsDao(super.attachedDatabase);

  /// Returns all items ordered by record timestamp.
  Future<List<TagItem>> allItems() => _orderedByRecordTimestamp().get();

  /// Streams all items ordered by record timestamp, re-emitting on
  /// change.
  Stream<List<TagItem>> watchAllItems() => _orderedByRecordTimestamp().watch();

  /// Returns the total number of items.
  Future<int> itemCount() => tagItems.count().getSingle();

  /// Streams the total number of items, re-emitting on change.
  Stream<int> watchItemCount() => tagItems.count().watchSingle();

  /// Selects all items ordered by record timestamp.
  SimpleSelectStatement<$TagItemsTable, TagItem> _orderedByRecordTimestamp() =>
      select(tagItems)
        ..orderBy([(item) => OrderingTerm.asc(item.recordTimestamp)]);
}
