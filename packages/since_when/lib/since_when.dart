// lib/since_when.dart

/// A timestamped record storage package with hierarchical
/// relationships and tagging.
///
/// ## Backend-agnostic usage
///
/// Depend on the interfaces, not the implementation:
///
/// ```dart
/// import 'package:since_when/since_when.dart';
///
/// class RecordCubit extends Cubit<RecordState> {
///   RecordCubit({required SinceWhenRecordStore recordStore})
///     : _recordStore = recordStore,
///       super(const RecordState.initial());
///
///   final SinceWhenRecordStore _recordStore;
/// }
/// ```
///
/// ## SQLite backend (default)
///
/// ```dart
/// import 'package:since_when/since_when.dart';
///
/// // Open with defaults (db/since_when.sqlite)
/// final result = await SinceWhenDatabase.openOrCreate();
/// final db = result.getOrElse(() => throw Exception('Failed'));
///
/// // Inject as the interface type:
/// final cubit = RecordCubit(recordStore: db);
/// ```
///
/// ## Custom backend
///
/// ```dart
/// class MyFirebaseStore implements SinceWhenDataStore {
///   // ... implement all methods
/// }
///
/// final store = MyFirebaseStore();
/// final cubit = RecordCubit(recordStore: store);
/// ```
///
/// ## In-memory (testing)
///
/// ```dart
/// final db = await SinceWhenDatabase.openInMemory();
/// final cubit = RecordCubit(recordStore: db);
/// ```
library;

// Constants (public)
export 'package:since_when/src/constants/database_constants.dart';
// Domain exports (public)
export 'package:since_when/src/domain/data_store_failure.dart';
export 'package:since_when/src/domain/since_when_failure.dart'
    hide
        ExportFailed,
        FileNotFound,
        ImportFailed,
        InvalidTagName,
        ParentNotFound,
        RecordNotFound,
        TagInUse,
        TagNameAlreadyExists,
        TagNotFound;
export 'package:since_when/src/domain/since_when_import_mode.dart';
export 'package:since_when/src/domain/since_when_record.dart';
export 'package:since_when/src/domain/table_info.dart';
export 'package:since_when/src/domain/tag_definition.dart';
export 'package:since_when/src/domain/tag_match_mode.dart';
// Database API — SQLite implementation (public)
export 'package:since_when/src/since_when_database.dart';
// Store interfaces (public)
export 'package:since_when/src/store/store.dart';
