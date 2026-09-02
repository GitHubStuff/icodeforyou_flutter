// packages/sincewhen_models/lib/src/repositories/tag_repository.dart

import 'package:sincewhen_models/src/models/tag_item.dart';

/// {@template tag_repository}
/// Persistence-free contract for reading and writing [TagItem]s: the
/// links between since-when records and glossary entries.
///
/// Feature packages and blocs depend on this interface only. Concrete
/// implementations live in persistence packages (e.g.
/// `DriftTagRepository` in `sincewhen_drift_framework`) and are bound
/// at the composition root via dependency injection.
/// {@endtemplate}
abstract interface class TagRepository {
  /// Returns all tag links.
  Future<List<TagItem>> allItems();

  /// Streams all tag links, re-emitting on change.
  Stream<List<TagItem>> watchAllItems();

  /// Returns the tag links attached to the since-when record with the
  /// given creation timestamp.
  Future<List<TagItem>> itemsForRecord(int recordTimestamp);

  /// Streams the tag links attached to the since-when record with the
  /// given creation timestamp, re-emitting on change.
  Stream<List<TagItem>> watchItemsForRecord(int recordTimestamp);

  /// Returns the tag links using the glossary entry with the given
  /// creation timestamp.
  Future<List<TagItem>> itemsForGlossary(int glossaryTimestamp);

  /// Returns the total number of tag links.
  Future<int> itemCount();

  /// Streams the total number of tag links, re-emitting on change.
  Stream<int> watchItemCount();

  /// Inserts [item] and returns the persisted row, including its
  /// database-assigned [TagItem.id].
  Future<TagItem> insertItem(TagItem item);

  /// Deletes the row matching [TagItem.id]. Returns `true` when a row
  /// was deleted.
  Future<bool> deleteItem(TagItem item);
}
