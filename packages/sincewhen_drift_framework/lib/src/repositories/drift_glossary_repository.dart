// packages/sincewhen_drift_framework/lib/src/repositories/drift_glossary_repository.dart

import 'package:sincewhen_drift_framework/src/tables/glossary_items/glossary_items_dao.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

/// {@template drift_glossary_repository}
/// Drift-backed implementation of [GlossaryRepository].
///
/// Pure delegation: every drift statement lives in [GlossaryItemsDao];
/// this class only satisfies the persistence-free contract that feature
/// packages depend on. Bind it at the composition root via
/// `registerGlossaryRepository`.
/// {@endtemplate}
final class DriftGlossaryRepository implements GlossaryRepository {
  /// {@macro drift_glossary_repository}
  const DriftGlossaryRepository(this._dao);

  final GlossaryItemsDao _dao;

  @override
  Future<List<GlossaryItem>> allItems() => _dao.allItems();

  @override
  Stream<List<GlossaryItem>> watchAllItems() => _dao.watchAllItems();

  @override
  Future<Set<int>> allColorArgbValues() => _dao.allColorArgbValues();

  @override
  Future<GlossaryItem?> itemByTag(String tag) => _dao.itemByTag(tag);

  @override
  Future<GlossaryItem?> itemWithColor(int colorArgb) =>
      _dao.itemWithColor(colorArgb);

  @override
  Future<int> itemCount() => _dao.itemCount();

  @override
  Stream<int> watchItemCount() => _dao.watchItemCount();

  @override
  Future<GlossaryItem> insertItem(GlossaryItem item) => _dao.insertItem(item);

  @override
  Future<bool> updateItem(GlossaryItem item) => _dao.updateItem(item);

  @override
  Future<bool> deleteItem(GlossaryItem item) => _dao.deleteItem(item);
}
