// lib/src/store/since_when_tag_store.dart

import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/domain/data_store_failure.dart';
import 'package:since_when/src/domain/tag_definition.dart';

/// Contract for tag operations.
///
/// Covers tag CRUD on the glossary and tag-to-record linking.
///
/// Any data store backend (SQLite, Firebase, Hive, REST API, etc.)
/// implements this interface to provide tag storage.
///
/// ## Implementing a custom backend
///
/// ```dart
/// class HiveTagStore implements SinceWhenTagStore {
///   final Box<TagDefinition> _tagBox;
///
///   HiveTagStore(this._tagBox);
///
///   @override
///   Future<Either<DataStoreFailure, TagDefinition>> createTag({
///     required String tagName,
///     required String tagDescription,
///     required int color,
///   }) async {
///     // Your Hive implementation here
///   }
///
///   // ... remaining methods
/// }
/// ```
///
/// ## Injecting into a consumer
///
/// ```dart
/// class TagManagerCubit extends Cubit<TagManagerState> {
///   TagManagerCubit({required SinceWhenTagStore tagStore})
///     : _tagStore = tagStore,
///       super(const TagManagerState.initial());
///
///   final SinceWhenTagStore _tagStore;
///
///   Future<void> loadAllTags() async {
///     final result = await _tagStore.getAllTags();
///     result.match(
///       (failure) => emit(TagManagerState.error(failure)),
///       (tags) => emit(TagManagerState.loaded(tags)),
///     );
///   }
/// }
/// ```
abstract interface class SinceWhenTagStore {
  // ===========================================================================
  // Create
  // ===========================================================================

  /// Creates a new tag definition in the glossary.
  ///
  /// Returns the created [TagDefinition] on success.
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [InvalidTagName] if [tagName] is empty or whitespace-only.
  /// - [TagNameAlreadyExists] if [tagName] is already in the glossary.
  /// - [IdentifierCollision] if a unique identifier could not be generated.
  Future<Either<DataStoreFailure, TagDefinition>> createTag({
    required String tagName,
    required String tagDescription,
    required int color,
  });

  // ===========================================================================
  // Read
  // ===========================================================================

  /// Gets a tag definition by its [createdTimeStamp].
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [TagNotFound] if no tag matches [createdTimeStamp].
  Future<Either<DataStoreFailure, TagDefinition>> getTagByTimestamp(
    String createdTimeStamp,
  );

  /// Gets a tag definition by its [tagName].
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [TagNotFound] if no tag matches [tagName].
  Future<Either<DataStoreFailure, TagDefinition>> getTagByName(
    String tagName,
  );

  /// Gets all tag definitions from the glossary.
  ///
  /// Returns an empty list if no tags exist.
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  Future<Either<DataStoreFailure, List<TagDefinition>>> getAllTags();

  // ===========================================================================
  // Update
  // ===========================================================================

  /// Updates a tag definition in the glossary.
  ///
  /// The tag is identified by [createdTimeStamp]. All other fields
  /// are overwritten with the provided values.
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [TagNotFound] if no tag matches [createdTimeStamp].
  /// - [InvalidTagName] if [tagName] is empty or whitespace-only.
  /// - [TagNameAlreadyExists] if [tagName] conflicts with another tag.
  Future<Either<DataStoreFailure, TagDefinition>> updateTag({
    required String createdTimeStamp,
    required String tagName,
    required String tagDescription,
    required int color,
  });

  // ===========================================================================
  // Delete
  // ===========================================================================

  /// Deletes a tag definition from the glossary.
  ///
  /// When [force] is `false` (default), deletion fails if the tag
  /// is still referenced by any records. When [force] is `true`,
  /// the tag is removed from all records and then deleted.
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [TagNotFound] if no tag matches [createdTimeStamp].
  /// - [TagInUse] if the tag is in use and [force] is `false`.
  Future<Either<DataStoreFailure, bool>> deleteTag(
    String createdTimeStamp, {
    bool force = false,
  });

  // ===========================================================================
  // Tag ↔ Record Linking
  // ===========================================================================

  /// Adds a tag to a record.
  ///
  /// Links the tag identified by [glossaryTimestamp] to the record
  /// identified by [recordTimestamp].
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [RecordNotFound] if the record does not exist.
  /// - [TagNotFound] if the tag does not exist.
  Future<Either<DataStoreFailure, bool>> addTagToRecord(
    String recordTimestamp,
    String glossaryTimestamp,
  );

  /// Removes a tag from a record.
  ///
  /// Unlinks the tag identified by [glossaryTimestamp] from the record
  /// identified by [recordTimestamp].
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  Future<Either<DataStoreFailure, bool>> removeTagFromRecord(
    String recordTimestamp,
    String glossaryTimestamp,
  );
}
