// packages/sincewhen_drift_framework/lib/src/repositories/drift_since_when_repository.dart

import 'package:sincewhen_drift_framework/src/tables/sincewhen_items/sincewhen_items_dao.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

/// {@template drift_since_when_repository}
/// Drift-backed implementation of [SinceWhenRepository].
///
/// Pure delegation: every drift statement lives in [SinceWhenItemsDao];
/// this class only satisfies the persistence-free contract that feature
/// packages depend on. Bind it at the composition root via
/// `registerSinceWhenRepository`.
/// {@endtemplate}
final class DriftSinceWhenRepository implements SinceWhenRepository {
  /// {@macro drift_since_when_repository}
  const DriftSinceWhenRepository(this._dao);

  final SinceWhenItemsDao _dao;

  @override
  Future<List<SinceWhenItem>> allItems() => _dao.allItems();

  @override
  Stream<List<SinceWhenItem>> watchAllItems() => _dao.watchAllItems();

  @override
  Future<SinceWhenItem?> itemByCreatedTimestamp(int createdTimestamp) =>
      _dao.itemByCreatedTimestamp(createdTimestamp);

  @override
  Future<int> itemCount() => _dao.itemCount();

  @override
  Stream<int> watchItemCount() => _dao.watchItemCount();

  @override
  Future<SinceWhenItem> insertItem(SinceWhenItem item) => _dao.insertItem(item);

  @override
  Future<bool> updateItem(SinceWhenItem item) => _dao.updateItem(item);

  @override
  Future<bool> deleteItem(SinceWhenItem item) => _dao.deleteItem(item);
}
