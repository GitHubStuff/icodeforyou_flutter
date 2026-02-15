// lib/src/store/since_when_data_store.dart

import 'package:since_when/src/domain/data_store_failure.dart' show StoreNotReady;
import 'package:since_when/src/store/since_when_data_transfer_store.dart';
import 'package:since_when/src/store/since_when_record_store.dart';
import 'package:since_when/src/store/since_when_tag_store.dart';

/// Complete data store contract.
///
/// Composes [SinceWhenRecordStore], [SinceWhenTagStore], and
/// [SinceWhenDataTransferStore] into a single interface with
/// lifecycle management.
///
/// Implement this when your backend supports all three concerns.
/// If your backend only handles records, implement
/// [SinceWhenRecordStore] directly instead.
///
/// ## Implementing a full backend
///
/// ```dart
/// class FirebaseDataStore implements SinceWhenDataStore {
///   final FirebaseFirestore _firestore;
///   bool _isOpen = false;
///
///   FirebaseDataStore(this._firestore);
///
///   /// Call this after construction to initialize.
///   Future<void> open() async {
///     // Firebase-specific setup
///     _isOpen = true;
///   }
///
///   @override
///   bool get isOpen => _isOpen;
///
///   @override
///   Future<void> close() async {
///     // Firebase-specific teardown
///     _isOpen = false;
///   }
///
///   // ... implement all record, tag, and transfer methods
/// }
/// ```
///
/// ## Injecting into an app
///
/// ```dart
/// // At app startup — decide which backend to use:
/// final SinceWhenDataStore store = SinceWhenSqliteDataStore(...);
/// // or
/// final SinceWhenDataStore store = FirebaseDataStore(...);
///
/// // Pass to consumers via constructor injection:
/// final recordCubit = RecordCubit(recordStore: store);
/// final tagCubit = TagManagerCubit(tagStore: store);
/// final backupCubit = BackupCubit(transferStore: store);
/// ```
///
/// ## Using segregated interfaces for narrower dependencies
///
/// A consumer that only needs records should depend on
/// [SinceWhenRecordStore], not the full [SinceWhenDataStore].
/// This follows the Interface Segregation Principle — consumers
/// only know about the methods they actually use.
///
/// ```dart
/// // Good — narrow dependency:
/// class RecordCubit extends Cubit<RecordState> {
///   RecordCubit({required SinceWhenRecordStore recordStore})
///     : _recordStore = recordStore,
///       super(const RecordState.initial());
///
///   final SinceWhenRecordStore _recordStore;
/// }
///
/// // Works — but wider than needed:
/// class RecordCubit extends Cubit<RecordState> {
///   RecordCubit({required SinceWhenDataStore dataStore})
///     : _dataStore = dataStore,
///       super(const RecordState.initial());
///
///   final SinceWhenDataStore _dataStore;
/// }
/// ```
abstract interface class SinceWhenDataStore
    implements
        SinceWhenRecordStore,
        SinceWhenTagStore,
        SinceWhenDataTransferStore {
  /// Whether the data store is currently open and ready for operations.
  bool get isOpen;

  /// Closes the data store and releases any resources.
  ///
  /// After calling [close], all operations will return [StoreNotReady].
  /// The store cannot be reopened — create a new instance instead.
  Future<void> close();
}
