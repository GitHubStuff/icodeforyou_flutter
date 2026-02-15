// lib/src/store/since_when_record_store.dart

import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/domain/data_store_failure.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/domain/tag_match_mode.dart';

/// Contract for record CRUD operations.
///
/// Any data store backend (SQLite, Firebase, Hive, REST API, etc.)
/// implements this interface to provide record storage.
///
/// All methods return [Either<DataStoreFailure, T>] so callers
/// can pattern match on failures without catching exceptions.
///
/// ## Implementing a custom backend
///
/// ```dart
/// class FirebaseRecordStore implements SinceWhenRecordStore {
///   final FirebaseFirestore _firestore;
///
///   FirebaseRecordStore(this._firestore);
///
///   @override
///   Future<Either<DataStoreFailure, SinceWhenRecord>> create({
///     required String metaData,
///     required String dataString,
///     required String category,
///     required List<String> tagTimestamps,
///     String? parentTimeStamp,
///   }) async {
///     // Your Firebase implementation here
///   }
///
///   // ... remaining methods
/// }
/// ```
///
/// ## Injecting into a consumer
///
/// ```dart
/// class RecordCubit extends Cubit<RecordState> {
///   RecordCubit({required SinceWhenRecordStore recordStore})
///     : _recordStore = recordStore,
///       super(const RecordState.initial());
///
///   final SinceWhenRecordStore _recordStore;
///
///   Future<void> loadByTag(String tagTimestamp) async {
///     final result = await _recordStore.getByTagTimestamp(tagTimestamp);
///     result.match(
///       (failure) => emit(RecordState.error(failure)),
///       (records) => emit(RecordState.loaded(records)),
///     );
///   }
/// }
/// ```
abstract interface class SinceWhenRecordStore {
  // ===========================================================================
  // Create
  // ===========================================================================

  /// Creates a new record.
  ///
  /// Returns the created [SinceWhenRecord] on success.
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [ParentNotFound] if [parentTimeStamp] is provided but doesn't exist.
  /// - [IdentifierCollision] if a unique identifier could not be generated.
  /// - [UnexpectedStoreError] for any other backend error.
  Future<Either<DataStoreFailure, SinceWhenRecord>> create({
    required String metaData,
    required String dataString,
    required String category,
    required List<String> tagTimestamps,
    String? parentTimeStamp,
  });

  // ===========================================================================
  // Read
  // ===========================================================================

  /// Gets a record and its direct children by [createdTimeStamp].
  ///
  /// Returns a list where the first element is the requested record
  /// and subsequent elements are its direct children.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [RecordNotFound] if no record matches [createdTimeStamp].
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>>
      getByCreatedTimeStamp(String createdTimeStamp);

  /// Gets all records matching a specific tag by glossary timestamp.
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagTimestamp(
    String glossaryTimestamp,
  );

  /// Gets all records matching a specific tag by name.
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagName(
    String tagName,
  );

  /// Gets all records matching the specified tags based on [mode].
  ///
  /// When [mode] is [TagMatchMode.any], returns records with at least
  /// one of the specified tags. When [mode] is [TagMatchMode.all],
  /// returns only records that have every specified tag.
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagTimestamps(
    List<String> tagTimestamps, {
    TagMatchMode mode = TagMatchMode.any,
  });

  /// Gets all records matching the specified tag names based on [mode].
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagNames(
    List<String> tagNames, {
    TagMatchMode mode = TagMatchMode.any,
  });

  /// Gets all records in a [category].
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByCategory(
    String category,
  );

  // ===========================================================================
  // Update
  // ===========================================================================

  /// Updates an existing record.
  ///
  /// The record is identified by its [SinceWhenRecord.createdTimeStamp].
  /// All mutable fields on [record] are written to the store.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [RecordNotFound] if the record does not exist.
  Future<Either<DataStoreFailure, SinceWhenRecord>> update(
    SinceWhenRecord record,
  );

  /// Marks a record as reviewed by updating its reviewed timestamp.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [RecordNotFound] if the record does not exist.
  Future<Either<DataStoreFailure, SinceWhenRecord>> markReviewed(
    String createdTimeStamp,
  );

  // ===========================================================================
  // Delete
  // ===========================================================================

  /// Deletes a record by its [createdTimeStamp].
  ///
  /// Returns `true` if the record was deleted.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [RecordNotFound] if the record does not exist.
  Future<Either<DataStoreFailure, bool>> delete(String createdTimeStamp);

  /// Deletes a record and all its descendants.
  ///
  /// Returns the total number of records deleted.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [RecordNotFound] if the root record does not exist.
  Future<Either<DataStoreFailure, int>> deleteWithDescendants(
    String createdTimeStamp,
  );
}
