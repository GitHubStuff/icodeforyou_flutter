// lib/src/store/since_when_tag_store.dart

import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/domain/data_store_failure.dart';
import 'package:since_when/src/domain/tag_definition.dart';

abstract interface class SinceWhenTagStore {
  // ===========================================================================
  // Create
  // ===========================================================================

  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [InvalidTagName] if [tagName] is empty or whitespace-only.
  /// - [TagNameAlreadyExists] if [tagName] is already in the glossary.
  /// - [IdentifierCollision] if a unique identifier could not be generated.
  Future<Either<DataStoreFailure, TagDefinition>> createTag({
    required String tagName,
    required int color,
  });

  // ===========================================================================
  // Read
  // ===========================================================================

  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [TagNotFound] if no tag matches [createdTimeStamp].
  Future<Either<DataStoreFailure, TagDefinition>> getTagByTimestamp(
    String createdTimeStamp,
  );

  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [TagNotFound] if no tag matches [tagName].
  Future<Either<DataStoreFailure, TagDefinition>> getTagByName(
    String tagName,
  );

  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  Future<Either<DataStoreFailure, List<TagDefinition>>> getAllTags();

  // ===========================================================================
  // Update
  // ===========================================================================

  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [TagNotFound] if no tag matches [createdTimeStamp].
  /// - [InvalidTagName] if [tagName] is empty or whitespace-only.
  /// - [TagNameAlreadyExists] if [tagName] conflicts with another tag.
  Future<Either<DataStoreFailure, TagDefinition>> updateTag({
    required String createdTimeStamp,
    required String tagName,
    required int color,
  });

  // ===========================================================================
  // Delete
  // ===========================================================================

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

  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [RecordNotFound] if the record does not exist.
  /// - [TagNotFound] if the tag does not exist.
  Future<Either<DataStoreFailure, bool>> addTagToRecord(
    String recordTimestamp,
    String glossaryTimestamp,
  );

  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  Future<Either<DataStoreFailure, bool>> removeTagFromRecord(
    String recordTimestamp,
    String glossaryTimestamp,
  );
}
