// packages/sincewhen_models/lib/src/repositories/since_when_repository.dart

import 'package:sincewhen_models/src/models/since_when_item.dart';

/// {@template since_when_repository}
/// Persistence-free contract for reading and writing [SinceWhenItem]s.
///
/// Feature packages and blocs depend on this interface only. Concrete
/// implementations live in persistence packages (e.g.
/// `DriftSinceWhenRepository` in `sincewhen_drift_framework`) and are bound
/// at the composition root via dependency injection — the single place in
/// an application that knows which backend is in use.
/// {@endtemplate}
abstract interface class SinceWhenRepository {
  /// Returns all items ordered by creation timestamp.
  Future<List<SinceWhenItem>> allItems();

  /// Streams all items ordered by creation timestamp, re-emitting on
  /// change.
  Stream<List<SinceWhenItem>> watchAllItems();

  /// Returns the item with the given unique creation timestamp, or `null`
  /// if none exists.
  Future<SinceWhenItem?> itemByCreatedTimestamp(int createdTimestamp);

  /// Returns the total number of items.
  Future<int> itemCount();

  /// Streams the total number of items, re-emitting on change.
  Stream<int> watchItemCount();

  /// Inserts [item] and returns the persisted row, including its
  /// database-assigned [SinceWhenItem.id].
  Future<SinceWhenItem> insertItem(SinceWhenItem item);

  /// Updates the row matching [SinceWhenItem.id]. Returns `true` when a
  /// row was updated.
  Future<bool> updateItem(SinceWhenItem item);

  /// Deletes the row matching [SinceWhenItem.id]. Returns `true` when a
  /// row was deleted.
  Future<bool> deleteItem(SinceWhenItem item);
}
