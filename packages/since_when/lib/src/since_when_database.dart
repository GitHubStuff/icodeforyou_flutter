// packages/since_when/lib/src/since_when_database.dart

// for doc files, best to ignore lines > 80 chars
// ignore_for_file: lines_longer_than_80_chars

import 'package:dartz/dartz.dart';
import 'package:since_when/src/constants/database_constants.dart';
import 'package:since_when/src/database/_database_initializer.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/domain/since_when_import_mode.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/domain/table_info.dart';
import 'package:since_when/src/domain/tag_match_mode.dart';
import 'package:since_when/src/sql/create/_create_operations.dart';
import 'package:since_when/src/sql/read/_read_operations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

/// Main entry point for SinceWhen database operations.
///
/// Implements [SqliteViewerAbstract] for integration with sqlite_viewer package.
///
/// **Singleton Pattern (file-based):**
/// Only one file-based database instance is allowed per app.
/// ```dart
/// final result = await SinceWhenDatabase.openOrCreate();
/// final db = result.getOrElse(() => throw Exception('Failed'));
/// ```
///
/// **Multiple Instances (in-memory):**
/// Unlimited in-memory instances are allowed for testing.
/// ```dart
/// final db1 = await SinceWhenDatabase.openInMemory();
/// final db2 = await SinceWhenDatabase.openInMemory(); // OK
/// ```
///
/// **Singleton Reset:**
/// Calling [close] on the file-based instance resets the singleton,
/// allowing a new instance with different parameters.
/// ```dart
/// final db1 = await SinceWhenDatabase.openOrCreate(dbName: 'first.db');
/// await db1.close();
/// final db2 = await SinceWhenDatabase.openOrCreate(dbName: 'second.db'); // OK
/// ```
class SinceWhenDatabase implements SqliteViewerAbstract {
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

  // ===========================================================================
  // Singleton Management
  // ===========================================================================

  static SinceWhenDatabase? _fileInstance;
  static String? _fileInstanceDbName;
  static String? _fileInstanceDbPath;

  /// Returns true if a file-based singleton instance exists.
  static bool get hasFileInstance => _fileInstance != null;

  // ===========================================================================
  // Factory: openOrCreate (file-based singleton)
  // ===========================================================================

  /// Opens or creates a file-based database.
  ///
  /// Parameters:
  /// - [dbName]: Database filename (default: 'since_when.sqlite')
  /// - [dbPath]: Subfolder within documents directory (default: 'db')
  ///
  /// The full path will be: `{documentsDirectory}/{dbPath}/{dbName}`
  ///
  /// **Singleton Behavior:**
  /// - First call creates the singleton instance
  /// - Subsequent calls with SAME parameters return existing instance
  /// - Subsequent calls with DIFFERENT parameters return [Left(DatabaseAlreadyInitialized)]
  /// - After [close], a new instance can be created with different parameters
  ///
  /// Returns [Right] with [SinceWhenDatabase] on success.
  /// Returns [Left] with [SinceWhenFailure] on error.
  static Future<Either<SinceWhenFailure, SinceWhenDatabase>> openOrCreate({
    String dbName = kDefaultDatabaseName,
    String dbPath = kDefaultDatabasePath,
  }) async {
    // Validate dbName
    if (dbName.trim().isEmpty) {
      return const Left(InvalidDatabaseName('Database name cannot be empty'));
    }

    // Check if singleton exists
    if (_fileInstance != null) {
      // Same params? Return existing instance error (per decision #29)
      if (_fileInstanceDbName == dbName && _fileInstanceDbPath == dbPath) {
        return const Left(
          DatabaseAlreadyInitialized(
            'Database already initialized with same parameters. '
            'Use SinceWhenDatabase.instance or close() first.',
          ),
        );
      }

      // Different params? Error
      return Left(
        DatabaseAlreadyInitialized(
          'Database already initialized with different parameters. '
          'Call close() before opening with new parameters. '
          'Current: $_fileInstanceDbPath/$_fileInstanceDbName, '
          'Requested: $dbPath/$dbName',
        ),
      );
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
      _fileInstanceDbName = dbName;
      _fileInstanceDbPath = dbPath;

      return Right(_fileInstance!);
    } on Exception catch (e) {
      return Left(UnexpectedDatabaseError('Failed to open database', e));
    }
  }

  // ===========================================================================
  // Factory: openInMemory (unlimited instances)
  // ===========================================================================

  /// Creates an in-memory database for testing.
  ///
  /// Unlike file-based databases, unlimited in-memory instances are allowed.
  /// Data is lost when [close] is called.
  ///
  /// Returns [SinceWhenDatabase] instance (never fails).
  static Future<SinceWhenDatabase> openInMemory() async {
    final result = await DatabaseInitializer.openInMemoryDatabase();

    return SinceWhenDatabase._(
      db: result.database,
      fullPath: kInMemoryPath,
      isInMemory: true,
    );
  }

  // ===========================================================================
  // Database Lifecycle
  // ===========================================================================

  /// Closes the database connection.
  ///
  /// For file-based instances, this resets the singleton state,
  /// allowing a new instance with different parameters.
  ///
  /// For in-memory instances, data is lost.
  Future<void> close() async {
    await _db.close();

    // Reset singleton if this is the file instance
    if (!_isInMemory && _fileInstance == this) {
      _fileInstance = null;
      _fileInstanceDbName = null;
      _fileInstanceDbPath = null;
    }
  }

  /// Returns true if the database is open.
  bool get isOpen => _db.isOpen;

  /// Returns true if this is an in-memory database.
  bool get isInMemory => _isInMemory;

  /// Exposes the underlying database for extensions.
  ///
  /// Use with caution — prefer typed methods when available.
  Database get database => _db;

  // ===========================================================================
  // SqliteViewerAbstract Implementation
  // ===========================================================================

  @override
  Future<Either<SqliteViewerFailure, String>> getFullPath() async {
    if (!_db.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }
    return Right(_fullPath);
  }

  @override
  Future<Either<SqliteViewerFailure, String>> getSqliteVersion() async {
    if (!_db.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }

    try {
      final result = await _db.rawQuery('SELECT sqlite_version() AS version');
      final version = result.first['version']! as String;
      return Right(version);
    } on Exception catch (e) {
      return Left(ViewerMetadataFailed('sqlite_version', e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, int>> getDatabaseSize() async {
    if (!_db.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }

    try {
      // Works for both file and in-memory databases
      final pageCountResult = await _db.rawQuery('PRAGMA page_count');
      final pageSizeResult = await _db.rawQuery('PRAGMA page_size');

      final pageCount = pageCountResult.first['page_count']! as int;
      final pageSize = pageSizeResult.first['page_size']! as int;

      return Right(pageCount * pageSize);
    } on Exception catch (e) {
      return Left(ViewerMetadataFailed('database_size', e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getTableNames() async {
    if (!_db.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }

    try {
      final result = await _db.rawQuery(
        'SELECT name FROM sqlite_master '
        "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' "
        'ORDER BY name',
      );

      final tables = result.map((row) => row['name']! as String).toList();
      return Right(tables);
    } on Exception catch (e) {
      return Left(ViewerMetadataFailed('table_names', e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, int>> getRowCount(String tableName) async {
    if (!_db.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }

    try {
      final result = await _db.rawQuery(
        'SELECT COUNT(*) AS count FROM "$tableName"',
      );
      final count = result.first['count']! as int;
      return Right(count);
    } on Exception catch (e) {
      if (e.toString().contains('no such table')) {
        return Left(ViewerTableNotFound(tableName));
      }
      return Left(ViewerQueryFailed('SELECT COUNT(*)', e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getColumnNames(
    String tableName,
  ) async {
    if (!_db.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }

    try {
      final result = await _db.rawQuery('PRAGMA table_info("$tableName")');

      if (result.isEmpty) {
        return Left(ViewerTableNotFound(tableName));
      }

      final columns = result.map((row) => row['name']! as String).toList();
      return Right(columns);
    } on Exception catch (e) {
      return Left(ViewerPragmaFailed(tableName, 'table_info', e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> getPragma({
    required String tableName,
    required PragmaKey key,
  }) async {
    if (!_db.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }

    final pragmaCommand = switch (key) {
      PragmaKey.tableInfo => 'PRAGMA table_info("$tableName")',
      PragmaKey.indexList => 'PRAGMA index_list("$tableName")',
      PragmaKey.foreignKeyList => 'PRAGMA foreign_key_list("$tableName")',
    };

    try {
      final result = await _db.rawQuery(pragmaCommand);
      return Right(result);
    } on Exception catch (e) {
      return Left(ViewerPragmaFailed(tableName, key.name, e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> executeSelect(
    String sql,
  ) async {
    if (!_db.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }

    if (sql.trim().isEmpty) {
      return const Left(ViewerQueryFailed('', 'Query cannot be empty'));
    }

    try {
      final result = await _db.rawQuery(sql);
      return Right(result);
    } on Exception catch (e) {
      return Left(ViewerQueryFailed(sql, e.toString()));
    }
  }
  // ===========================================================================
  // Database Metadata (SinceWhen-specific)
  // ===========================================================================

  /// Returns metadata for all application tables in the database.
  ///
  /// Excludes SQLite internal tables (sqlite_*).
  ///
  /// Returns a list of [TableInfo] containing table names and row counts.
  Future<Either<SinceWhenFailure, List<TableInfo>>> getTableListInfo() async {
    if (!_db.isOpen) {
      return const Left(DatabaseNotInitialized());
    }

    try {
      final tableResults = await _db.rawQuery(
        'SELECT name FROM sqlite_master '
        "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' "
        'ORDER BY name',
      );

      final tableInfoList = <TableInfo>[];

      for (final row in tableResults) {
        final tableName = row['name']! as String;

        final countResult = await _db.rawQuery(
          'SELECT COUNT(*) as count FROM "$tableName"',
        );
        final rowCount = countResult.first['count']! as int;

        tableInfoList.add(
          TableInfo(
            tableName: tableName,
            rowCount: rowCount,
          ),
        );
      }

      return Right(tableInfoList);
    } on Exception catch (e) {
      return Left(UnexpectedDatabaseError('Failed to get table info', e));
    }
  }

  // ===========================================================================
  // CRUD: Create
  // ===========================================================================

  /// Creates a new record.
  ///
  /// Required parameters:
  /// - [metaData]: Metadata string (guideline: ~100 characters)
  /// - [dataString]: Primary data content
  /// - [category]: Free-form category classification
  /// - [tags]: List of tags (can be empty)
  ///
  /// Optional parameters:
  /// - [parentTimeStamp]: Creates a child record under this parent.
  ///   If provided and parent exists, sequenceNumber is auto-calculated.
  ///   If parent doesn't exist, parentTimeStamp is set to null.
  ///
  /// On creation:
  /// - `createdTimeStamp` is set to current UTC time (unique)
  /// - `reviewedTimeStamp` is set to same as createdTimeStamp
  /// - `editedTimeStamp` is set to same as createdTimeStamp
  /// - `metaTimeStamp` is null
  /// - `sequenceNumber` is 0 for root records, auto-calculated for children
  ///
  /// Returns [Right] with created [SinceWhenRecord] on success.
  /// Returns [Left] with [SinceWhenFailure] on error.
  Future<Either<SinceWhenFailure, SinceWhenRecord>> create({
    required String metaData,
    required String dataString,
    required String category,
    required List<String> tags,
    String? parentTimeStamp,
  }) async {
    if (!_db.isOpen) {
      return const Left(DatabaseNotInitialized());
    }

    return CreateOperations.createRecord(
      _db,
      metaData: metaData,
      dataString: dataString,
      category: category,
      tags: tags,
      parentTimeStamp: parentTimeStamp,
    );
  }

  // ===========================================================================
  // CRUD: Read (stubs)
  // ===========================================================================

  /// Gets a record and its direct children by createdTimeStamp.
  ///
  // TODO(steven): Implement in ReadOperations.
  Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByCreatedTimeStamp(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('getByCreatedTimeStamp not yet implemented');
  }

  /// Gets all records matching a specific tag.
  ///
  /// This is a convenience method that calls [getByTags] with a single tag.
  Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByTag(
    String tag,
  ) async {
    if (!_db.isOpen) {
      return const Left(DatabaseNotInitialized());
    }

    return ReadOperations.getByTag(_db, tag);
  }

  /// Gets all records matching the specified tags based on [mode].
  ///
  /// Parameters:
  /// - [tags]: List of tags to match against.
  /// - [mode]: How to match tags (default: [TagMatchMode.any]).
  ///
  /// Match modes:
  /// - [TagMatchMode.any]: Returns records with **at least one** matching tag.
  /// - [TagMatchMode.all]: Returns records with **all** specified tags.
  ///
  /// Returns empty list if [tags] is empty.
  ///
  /// Example:
  /// ```dart
  /// // Get records with 'flutter' OR 'dart'
  /// final anyResult = await db.getByTags(
  ///   ['flutter', 'dart'],
  ///   mode: TagMatchMode.any,
  /// );
  ///
  /// // Get records with 'flutter' AND 'dart'
  /// final allResult = await db.getByTags(
  ///   ['flutter', 'dart'],
  ///   mode: TagMatchMode.all,
  /// );
  /// ```
  Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByTags(
    List<String> tags, {
    TagMatchMode mode = TagMatchMode.any,
  }) async {
    if (!_db.isOpen) {
      return const Left(DatabaseNotInitialized());
    }

    return ReadOperations.getByTags(_db, tags, mode: mode);
  }

  /// Gets all records in a category.
  ///
  // TODO(steven): Implement in ReadOperations.
  Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByCategory(
    String category,
  ) async {
    throw UnimplementedError('getByCategory not yet implemented');
  }

  // ===========================================================================
  // CRUD: Update (stubs)
  // ===========================================================================

  /// Updates an existing record.
  ///
  // TODO(steven): Implement in UpdateOperations.
  Future<Either<SinceWhenFailure, SinceWhenRecord>> update(
    SinceWhenRecord record,
  ) async {
    throw UnimplementedError('update not yet implemented');
  }

  /// Marks a record as reviewed (updates reviewedTimeStamp).
  ///
  // TODO(steven): Implement in UpdateOperations.
  Future<Either<SinceWhenFailure, SinceWhenRecord>> markReviewed(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('markReviewed not yet implemented');
  }

  // ===========================================================================
  // CRUD: Delete (stubs)
  // ===========================================================================

  /// Deletes a record by its createdTimeStamp.
  ///
  // TODO(steven): Implement in DeleteOperations.
  Future<Either<SinceWhenFailure, bool>> delete(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('delete not yet implemented');
  }

  /// Deletes a record and all its descendants.
  ///
  // TODO(steven): Implement in DeleteOperations.
  Future<Either<SinceWhenFailure, int>> deleteWithDescendants(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('deleteWithDescendants not yet implemented');
  }

  // ===========================================================================
  // Import / Export: String-based
  // ===========================================================================

  /// Exports all records to a JSON string.
  ///
  // TODO(steven): Implement in ExportToString.
  Future<Either<SinceWhenFailure, String>> exportToString() async {
    throw UnimplementedError('exportToString not yet implemented');
  }

  /// Imports records from a JSON string.
  ///
  // TODO(steven): Implement in ImportFromString.
  Future<Either<SinceWhenFailure, int>> importFromString(
    String jsonString, {
    SinceWhenImportMode mode = SinceWhenImportMode.merge,
  }) async {
    throw UnimplementedError('importFromString not yet implemented');
  }

  // ===========================================================================
  // Import / Export: File-based
  // ===========================================================================

  /// Exports all records to a JSON file.
  ///
  // TODO(steven): Implement in ExportToJson.
  Future<Either<SinceWhenFailure, String>> exportToFile({
    required String path,
  }) async {
    throw UnimplementedError('exportToFile not yet implemented');
  }

  /// Imports records from a JSON file.
  ///
  // TODO(steven): Implement in ImportFromJson.
  Future<Either<SinceWhenFailure, int>> importFromFile({
    required String path,
    SinceWhenImportMode mode = SinceWhenImportMode.merge,
  }) async {
    throw UnimplementedError('importFromFile not yet implemented');
  }
}
