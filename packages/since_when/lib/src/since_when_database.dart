// lib/src/since_when_database.dart

import 'package:fpdart/fpdart.dart';
import 'package:since_when/since_when.dart' show SinceWhenRecordStore;
import 'package:since_when/src/constants/database_constants.dart';
import 'package:since_when/src/database/_database_initializer.dart';
import 'package:since_when/src/domain/data_store_failure.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/domain/since_when_import_mode.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/domain/table_info.dart';
import 'package:since_when/src/domain/tag_definition.dart';
import 'package:since_when/src/domain/tag_match_mode.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:since_when/src/sql/create/_create_operations.dart';
import 'package:since_when/src/sql/delete/_delete_operations.dart';
import 'package:since_when/src/sql/read/_read_record_operations.dart';
import 'package:since_when/src/sql/read/_read_tag_operations.dart';
import 'package:since_when/src/sql/update/_update_operations.dart';
import 'package:since_when/src/store/since_when_data_store.dart';
import 'package:since_when/src/store/since_when_data_transfer_store.dart' show SinceWhenDataTransferStore;
import 'package:since_when/src/store/store.dart' show SinceWhenTagStore;
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

part '_db_viewer_impl.dart';

/// Main entry point for SinceWhen database operations.
///
/// This is the **SQLite implementation** of [SinceWhenDataStore].
///
/// Consumers should depend on the interfaces ([SinceWhenRecordStore],
/// [SinceWhenTagStore], [SinceWhenDataTransferStore], or
/// [SinceWhenDataStore]) and receive this class via constructor injection.
///
/// ```dart
/// // Open the SQLite backend:
/// final result = await SinceWhenDatabase.openOrCreate();
/// final db = result.getOrElse(() => throw Exception('Failed'));
///
/// // Inject as the interface type:
/// final cubit = RecordCubit(recordStore: db);
/// ```
class SinceWhenDatabase implements SinceWhenDataStore, SqliteViewerAbstract {
  SinceWhenDatabase._({
    required Database db,
    required String fullPath,
    required bool isInMemory,
  }) : _db = db,
       _fullPath = fullPath,
       _isInMemory = isInMemory;

  final Database _db;
  final String _fullPath;
  final bool _isInMemory;

  static SinceWhenDatabase? _fileInstance;

  /// Returns true if a file-based singleton instance exists.
  static bool get hasFileInstance => _fileInstance != null;

  /// Returns true if the database connection is open.
  @override
  bool get isOpen => _db.isOpen;

  /// Returns true if this is an in-memory database.
  bool get isInMemory => _isInMemory;

  /// Exposes the underlying [Database] for advanced operations.
  Database get database => _db;

  // ===========================================================================
  // Factory Constructors & Lifecycle
  // ===========================================================================

  /// Opens or creates a file-based database (singleton).
  ///
  /// Returns [Left] with [InvalidDatabaseName] if name is empty.
  /// Returns [Left] with [ReservedDatabaseName] if name is 'since_when.db'.
  /// Returns [Left] with [DatabaseAlreadyInitialized] if already open.
  static Future<Either<SinceWhenFailure, SinceWhenDatabase>> openOrCreate({
    String dbName = kDefaultDatabaseName,
    String dbPath = kDefaultDatabasePath,
  }) async {
    if (dbName.trim().isEmpty) {
      return const Left(InvalidDatabaseName('Database name cannot be empty'));
    }
    if (dbName == 'since_when.db') {
      return const Left(ReservedDatabaseName());
    }
    if (_fileInstance != null) {
      return const Left(DatabaseAlreadyInitialized('Already initialized.'));
    }
    try {
      final result = await DatabaseInitializer.openOrCreateDatabase(
        dbName: dbName,
        dbPath: dbPath,
      );
      _fileInstance = SinceWhenDatabase._(
        db: result.database,
        fullPath: result.fullPath,
        isInMemory: false,
      );
      return Right(_fileInstance!);
    } on Exception catch (e) {
      return Left(UnexpectedDatabaseError('Failed to open database', e));
    }
  }

  /// Creates an in-memory database for testing (non-singleton).
  static Future<SinceWhenDatabase> openInMemory() async {
    final result = await DatabaseInitializer.openInMemoryDatabase();
    return SinceWhenDatabase._(
      db: result.database,
      fullPath: kInMemoryPath,
      isInMemory: true,
    );
  }

  /// Closes the database connection and resets singleton if file-based.
  @override
  Future<void> close() async {
    await _db.close();
    if (!_isInMemory && _fileInstance == this) {
      _fileInstance = null;
    }
  }

  // ===========================================================================
  // SinceWhenRecordStore Implementation
  // ===========================================================================

  /// Creates a new record.
  @override
  Future<Either<DataStoreFailure, SinceWhenRecord>> create({
    required String metaData,
    required String dataString,
    required String category,
    required List<String> tagTimestamps,
    String? parentTimeStamp,
  }) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return CreateOperations.createRecord(
      _db,
      metaData: metaData,
      dataString: dataString,
      category: category,
      tagTimestamps: tagTimestamps,
      parentTimeStamp: parentTimeStamp,
    );
  }

  /// Gets a record and its direct children by createdTimeStamp.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  @override
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>>
      getByCreatedTimeStamp(String createdTimeStamp) async {
    throw UnimplementedError('getByCreatedTimeStamp not yet implemented');
  }

  /// Gets all records matching a specific tag by glossary timestamp.
  @override
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagTimestamp(
    String glossaryTimestamp,
  ) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadRecordOperations.getByTagTimestamp(_db, glossaryTimestamp);
  }

  /// Gets all records matching a specific tag by name.
  @override
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagName(
    String tagName,
  ) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadRecordOperations.getByTagName(_db, tagName);
  }

  /// Gets all records matching the specified tags based on [mode].
  @override
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagTimestamps(
    List<String> tagTimestamps, {
    TagMatchMode mode = TagMatchMode.any,
  }) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadRecordOperations.getByTagTimestamps(
      _db,
      tagTimestamps,
      mode: mode,
    );
  }

  /// Gets all records matching the specified tag names based on [mode].
  @override
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagNames(
    List<String> tagNames, {
    TagMatchMode mode = TagMatchMode.any,
  }) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadRecordOperations.getByTagNames(_db, tagNames, mode: mode);
  }

  /// Gets all records in a category.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  @override
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByCategory(
    String category,
  ) async {
    throw UnimplementedError('getByCategory not yet implemented');
  }

  /// Updates an existing record.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  @override
  Future<Either<DataStoreFailure, SinceWhenRecord>> update(
    SinceWhenRecord record,
  ) async {
    throw UnimplementedError('update not yet implemented');
  }

  /// Marks a record as reviewed.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  @override
  Future<Either<DataStoreFailure, SinceWhenRecord>> markReviewed(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('markReviewed not yet implemented');
  }

  /// Deletes a record by its createdTimeStamp.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  @override
  Future<Either<DataStoreFailure, bool>> delete(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('delete not yet implemented');
  }

  /// Deletes a record and all its descendants.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  @override
  Future<Either<DataStoreFailure, int>> deleteWithDescendants(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('deleteWithDescendants not yet implemented');
  }

  // ===========================================================================
  // SinceWhenTagStore Implementation
  // ===========================================================================

  /// Creates a new tag definition in the glossary.
  @override
  Future<Either<DataStoreFailure, TagDefinition>> createTag({
    required String tagName,
    required String tagDescription,
    required int color,
  }) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return CreateOperations.createTagDefinition(
      _db,
      tagName: tagName,
      tagDescription: tagDescription,
      color: color,
    );
  }

  /// Gets a tag definition by its createdTimeStamp.
  @override
  Future<Either<DataStoreFailure, TagDefinition>> getTagByTimestamp(
    String createdTimeStamp,
  ) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadTagOperations.getTagDefinitionByTimestamp(
      _db,
      createdTimeStamp,
    );
  }

  /// Gets a tag definition by its name.
  @override
  Future<Either<DataStoreFailure, TagDefinition>> getTagByName(
    String tagName,
  ) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadTagOperations.getTagDefinitionByName(_db, tagName);
  }

  /// Gets all tag definitions from the glossary.
  @override
  Future<Either<DataStoreFailure, List<TagDefinition>>> getAllTags() async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadTagOperations.getAllTagDefinitions(_db);
  }

  /// Updates a tag definition in the glossary.
  @override
  Future<Either<DataStoreFailure, TagDefinition>> updateTag({
    required String createdTimeStamp,
    required String tagName,
    required String tagDescription,
    required int color,
  }) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return UpdateOperations.updateTagDefinition(
      _db,
      createdTimeStamp: createdTimeStamp,
      tagName: tagName,
      tagDescription: tagDescription,
      color: color,
    );
  }

  /// Deletes a tag definition from the glossary.
  @override
  Future<Either<DataStoreFailure, bool>> deleteTag(
    String createdTimeStamp, {
    bool force = false,
  }) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return DeleteOperations.deleteTagDefinition(
      _db,
      createdTimeStamp,
      force: force,
    );
  }

  /// Adds a tag to a record.
  @override
  Future<Either<DataStoreFailure, bool>> addTagToRecord(
    String recordTimestamp,
    String glossaryTimestamp,
  ) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    try {
      await _db.rawInsert(
        SqlStatements.insertRecordTag,
        [recordTimestamp, glossaryTimestamp],
      );
      return const Right(true);
    } on Exception catch (e) {
      return Left(
        UnexpectedStoreError('Failed to add tag to record', e),
      );
    }
  }

  /// Removes a tag from a record.
  @override
  Future<Either<DataStoreFailure, bool>> removeTagFromRecord(
    String recordTimestamp,
    String glossaryTimestamp,
  ) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return DeleteOperations.removeTagFromRecord(
      _db,
      recordTimestamp,
      glossaryTimestamp,
    );
  }

  // ===========================================================================
  // SinceWhenDataTransferStore Implementation
  // ===========================================================================

  /// Exports all records and tags to a JSON string.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  @override
  Future<Either<DataStoreFailure, String>> exportToString() async {
    throw UnimplementedError('exportToString not yet implemented');
  }

  /// Exports all records and tags to a file at [path].
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  @override
  Future<Either<DataStoreFailure, String>> exportToFile({
    required String path,
  }) async {
    throw UnimplementedError('exportToFile not yet implemented');
  }

  /// Imports records and tags from a serialized string.
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  @override
  Future<Either<DataStoreFailure, int>> importFromString(
    String data, {
    SinceWhenImportMode mode = SinceWhenImportMode.merge,
  }) async {
    throw UnimplementedError('importFromString not yet implemented');
  }

  /// Imports records and tags from a file at [path].
  ///
  /// **Status: Not yet implemented in SQLite backend.**
  @override
  Future<Either<DataStoreFailure, int>> importFromFile({
    required String path,
    SinceWhenImportMode mode = SinceWhenImportMode.merge,
  }) async {
    throw UnimplementedError('importFromFile not yet implemented');
  }

  // ===========================================================================
  // SqliteViewerAbstract Implementation
  // ===========================================================================

  @override
  Future<Either<SqliteViewerFailure, String>> getFullPath() async {
    if (!_db.isOpen) return const Left(ViewerDatabaseNotOpen());
    return Right(_fullPath);
  }

  @override
  Future<Either<SqliteViewerFailure, String>> getSqliteVersion() async {
    if (!_db.isOpen) return const Left(ViewerDatabaseNotOpen());
    try {
      final r = await _db.rawQuery('SELECT sqlite_version() AS version');
      return Right(r.first['version']! as String);
    } on Exception catch (e) {
      return Left(ViewerMetadataFailed('sqlite_version', e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, int>> getDatabaseSize() async {
    if (!_db.isOpen) return const Left(ViewerDatabaseNotOpen());
    try {
      final pc = await _db.rawQuery('PRAGMA page_count');
      final ps = await _db.rawQuery('PRAGMA page_size');
      final count = pc.first['page_count']! as int;
      final size = ps.first['page_size']! as int;
      return Right(count * size);
    } on Exception catch (e) {
      return Left(ViewerMetadataFailed('database_size', e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getTableNames() async {
    if (!_db.isOpen) return const Left(ViewerDatabaseNotOpen());
    try {
      final r = await _db.rawQuery(
        'SELECT name FROM sqlite_master '
        "WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
      );
      return Right(r.map((row) => row['name']! as String).toList());
    } on Exception catch (e) {
      return Left(ViewerMetadataFailed('table_names', e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getColumnNames(
    String tableName,
  ) async {
    if (!_db.isOpen) return const Left(ViewerDatabaseNotOpen());
    try {
      final r = await _db.rawQuery('PRAGMA table_info("$tableName")');
      return Right(r.map((row) => row['name']! as String).toList());
    } on Exception catch (e) {
      return Left(ViewerMetadataFailed('column_names', e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, int>> getRowCount(String tableName) async {
    if (!_db.isOpen) return const Left(ViewerDatabaseNotOpen());
    try {
      final r = await _db.rawQuery(
        'SELECT COUNT(*) as count FROM "$tableName"',
      );
      return Right(r.first['count']! as int);
    } on Exception catch (e) {
      return Left(ViewerMetadataFailed('row_count', e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> executeSelect(
    String sql,
  ) async {
    if (!_db.isOpen) return const Left(ViewerDatabaseNotOpen());
    try {
      return Right(await _db.rawQuery(sql));
    } on Exception catch (e) {
      return Left(ViewerQueryFailed(sql, e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> getPragma({
    required String tableName,
    required PragmaKey key,
  }) async {
    if (!_db.isOpen) return const Left(ViewerDatabaseNotOpen());
    try {
      final name = switch (key) {
        PragmaKey.tableInfo => 'table_info',
        PragmaKey.indexList => 'index_list',
        PragmaKey.foreignKeyList => 'foreign_key_list',
      };
      return Right(await _db.rawQuery('PRAGMA $name("$tableName")'));
    } on Exception catch (e) {
      return Left(ViewerMetadataFailed('pragma_$key', e.toString()));
    }
  }
}
