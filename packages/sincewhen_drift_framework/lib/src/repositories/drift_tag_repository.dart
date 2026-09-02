// packages/sincewhen_drift_framework/lib/src/repositories/drift_tag_repository.dart

import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items_dao.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

/// {@template drift_tag_repository}
/// Drift-backed implementation of [TagRepository].
///
/// Pure delegation: every drift statement lives in [TagItemsDao];
/// this class only satisfies the persistence-free contract that feature
/// packages depend on. Bind it at the composition root via
/// `registerTagRepository`.
/// {@endtemplate}
final class DriftTagRepository implements TagRepository {
  /// {@macro drift_tag_repository}
  const DriftTagRepository(this._dao);

  final TagItemsDao _dao;

  @override
  Future<List<TagItem>> allItems() => _dao.allItems();

  @override
  Stream<List<TagItem>> watchAllItems() => _dao.watchAllItems();

  @override
  Future<List<TagItem>> itemsForRecord(int recordTimestamp) =>
      _dao.itemsForRecord(recordTimestamp);

  @override
  Stream<List<TagItem>> watchItemsForRecord(int recordTimestamp) =>
      _dao.watchItemsForRecord(recordTimestamp);

  @override
  Future<List<TagItem>> itemsForGlossary(int glossaryTimestamp) =>
      _dao.itemsForGlossary(glossaryTimestamp);

  @override
  Future<int> itemCount() => _dao.itemCount();

  @override
  Stream<int> watchItemCount() => _dao.watchItemCount();

  @override
  Future<TagItem> insertItem(TagItem item) => _dao.insertItem(item);

  @override
  Future<bool> deleteItem(TagItem item) => _dao.deleteItem(item);
}
