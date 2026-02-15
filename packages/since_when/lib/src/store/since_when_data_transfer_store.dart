// lib/src/store/since_when_data_transfer_store.dart

import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/domain/data_store_failure.dart';
import 'package:since_when/src/domain/since_when_import_mode.dart';
import 'package:since_when/src/store/since_when_record_store.dart' show SinceWhenRecordStore;
import 'package:since_when/src/store/since_when_tag_store.dart' show SinceWhenTagStore;

/// Contract for bulk data transfer operations.
///
/// Handles export and import of records (and their tags) as a unit.
/// This is intentionally separate from [SinceWhenRecordStore] and
/// [SinceWhenTagStore] because:
///
/// 1. Export/import crosses aggregate boundaries (records + tags).
/// 2. Not every backend needs it — a lightweight cache has no business
///    implementing file export.
/// 3. The mechanism varies wildly by backend (JSON dump, Firestore
///    snapshot, REST endpoint, etc.).
///
/// ## Implementing a custom backend
///
/// ```dart
/// class RestApiDataTransfer implements SinceWhenDataTransferStore {
///   final HttpClient _client;
///
///   RestApiDataTransfer(this._client);
///
///   @override
///   Future<Either<DataStoreFailure, String>> exportToString() async {
///     final response = await _client.get('/api/export');
///     return Right(response.body);
///   }
///
///   // ... remaining methods
/// }
/// ```
///
/// ## Injecting into a consumer
///
/// ```dart
/// class BackupCubit extends Cubit<BackupState> {
///   BackupCubit({required SinceWhenDataTransferStore transferStore})
///     : _transferStore = transferStore,
///       super(const BackupState.initial());
///
///   final SinceWhenDataTransferStore _transferStore;
///
///   Future<void> exportData(String path) async {
///     final result = await _transferStore.exportToFile(path: path);
///     result.match(
///       (failure) => emit(BackupState.error(failure)),
///       (filePath) => emit(BackupState.exported(filePath)),
///     );
///   }
/// }
/// ```
abstract interface class SinceWhenDataTransferStore {
  // ===========================================================================
  // Export
  // ===========================================================================

  /// Exports all records and tags to a serialized string.
  ///
  /// The format of the string is implementation-defined (typically JSON).
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [ExportFailed] if serialization fails.
  Future<Either<DataStoreFailure, String>> exportToString();

  /// Exports all records and tags to a file at [path].
  ///
  /// Returns the full path of the written file on success.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [ExportFailed] if the file could not be written.
  Future<Either<DataStoreFailure, String>> exportToFile({
    required String path,
  });

  // ===========================================================================
  // Import
  // ===========================================================================

  /// Imports records and tags from a serialized string.
  ///
  /// The [mode] determines how conflicts are resolved:
  /// - [SinceWhenImportMode.merge] — skip duplicates.
  /// - [SinceWhenImportMode.update] — overwrite duplicates.
  /// - [SinceWhenImportMode.replace] — wipe and reload.
  /// - [SinceWhenImportMode.refresh] — keep newest by editedTimeStamp.
  ///
  /// Returns the number of records imported on success.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [InvalidDataFormat] if the string cannot be parsed.
  /// - [ImportFailed] if the import operation fails.
  Future<Either<DataStoreFailure, int>> importFromString(
    String data, {
    SinceWhenImportMode mode = SinceWhenImportMode.merge,
  });

  /// Imports records and tags from a file at [path].
  ///
  /// See [importFromString] for [mode] behavior.
  ///
  /// Returns the number of records imported on success.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  ///
  /// Possible failures:
  /// - [StoreNotReady] if the store has not been opened.
  /// - [FileNotFound] if the file does not exist.
  /// - [InvalidDataFormat] if the file contents cannot be parsed.
  /// - [ImportFailed] if the import operation fails.
  Future<Either<DataStoreFailure, int>> importFromFile({
    required String path,
    SinceWhenImportMode mode = SinceWhenImportMode.merge,
  });
}
