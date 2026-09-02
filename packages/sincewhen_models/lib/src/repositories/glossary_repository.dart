// packages/sincewhen_models/lib/src/repositories/glossary_repository.dart

import 'package:sincewhen_models/src/models/glossary_item.dart';

/// {@template glossary_repository}
/// Persistence-free contract for reading and writing [GlossaryItem]s.
///
/// Feature packages and blocs depend on this interface only. Concrete
/// implementations live in persistence packages (e.g.
/// `DriftGlossaryRepository` in `sincewhen_drift_framework`) and are bound
/// at the composition root via dependency injection.
/// {@endtemplate}
abstract interface class GlossaryRepository {
  /// Returns all items ordered by tag.
  Future<List<GlossaryItem>> allItems();

  /// Streams all items ordered by tag, re-emitting on change.
  Stream<List<GlossaryItem>> watchAllItems();

  //+ CHANGED (new method)
  /// Returns the packed ARGB color values of all items.
  Future<Set<int>> allColorArgbValues();

  /// Returns the item with the given unique [tag], or `null` if none
  /// exists.
  Future<GlossaryItem?> itemByTag(String tag);

  //+ CHANGED (new method)
  /// Returns the item whose color matches [colorArgb], or `null` when no
  /// item uses that color.
  Future<GlossaryItem?> itemWithColor(int colorArgb);

  /// Returns the total number of items.
  Future<int> itemCount();

  /// Streams the total number of items, re-emitting on change.
  Stream<int> watchItemCount();

  /// Inserts [item] and returns the persisted row, including its
  /// database-assigned [GlossaryItem.id].
  Future<GlossaryItem> insertItem(GlossaryItem item);

  /// Updates the row matching [GlossaryItem.id]. Returns `true` when a
  /// row was updated.
  Future<bool> updateItem(GlossaryItem item);

  /// Deletes the row matching [GlossaryItem.id]. Returns `true` when a
  /// row was deleted.
  Future<bool> deleteItem(GlossaryItem item);
}
