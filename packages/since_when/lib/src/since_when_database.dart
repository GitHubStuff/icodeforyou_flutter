// icodeforyou_flutter/packages/since_when/lib/src/since_when_database.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/database/_database_initializer.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/domain/since_when_import_mode.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/domain/table_info.dart';
import 'package:since_when/src/sql/create/_create_operations.dart';
import 'package:sqflite/sqflite.dart';

/// Reserved database name for singleton instance.
const String _singletonDbName = 'since_when.db';

/// Main entry point for SinceWhen database operations.
///
/// Supports two usage patterns:
///
/// **Singleton** (uses 'since_when.db'):
/// ```dart
/// await SinceWhenDatabase.initializeSingleton();
/// final db = SinceWhenDatabase.instance;
/// await db.create(...);
/// ```
///
/// **Named Instance** (custom database name):
/// ```dart
/// final result = await SinceWhenDatabase.openOrCreate(dbName: 'my_data.db');
/// result.fold(
///   (failure) => handleError(failure),
///   (db) async {
///     await db.create(...);
///     await db.close();
///   },
/// );
/// ```
///
/// Note: 'since_when.db' is reserved for singleton and cannot be used
/// with [openOrCreate].
class SinceWhenDatabase {
  SinceWhenDatabase._(this._db);

  final Database _db;

  // ---------------------------------------------------------------------------
  // Singleton Pattern
  // ---------------------------------------------------------------------------

  static SinceWhenDatabase? _singleton;

  /// Returns the singleton instance.
  ///
  /// Throws [StateError] if [initializeSingleton] has not been called.
  static SinceWhenDatabase get instance {
    if (_singleton == null) {
      throw StateError(
        'SinceWhenDatabase not initialized. '
        'Call SinceWhenDatabase.initializeSingleton() first.',
      );
    }
    return _singleton!;
  }

  /// Initializes the singleton database instance.
  ///
  /// Creates or opens 'since_when.db' in the documents directory.
  /// Safe to call multiple times — subsequent calls are no-ops.
  static Future<void> initializeSingleton() async {
    if (_singleton != null) return;

    final db = await DatabaseInitializer.openOrCreateDatabase(_singletonDbName);
    _singleton = SinceWhenDatabase._(db);
  }

  /// Returns `true` if the singleton has been initialized.
  static bool get isInitialized => _singleton != null;

  // ---------------------------------------------------------------------------
  // Named Instance Factory
  // ---------------------------------------------------------------------------

  /// Creates or opens a named database instance.
  ///
  /// The [dbName] must NOT be 'since_when.db' (reserved for singleton).
  ///
  /// Returns [Right] with [SinceWhenDatabase] instance on success.
  /// Returns [Left] with [ReservedDatabaseName] if dbName is reserved.
  static Future<Either<SinceWhenFailure, SinceWhenDatabase>> openOrCreate({
    required String dbName,
  }) async {
    if (dbName == _singletonDbName) {
      return const Left(ReservedDatabaseName());
    }

    try {
      final db = await DatabaseInitializer.openOrCreateDatabase(dbName);
      return Right(SinceWhenDatabase._(db));
    } on Exception catch (e) {
      return Left(UnexpectedDatabaseError('Failed to open database', e));
    }
  }

  /// Creates an in-memory database for testing.
  ///
  /// Data is lost when [close] is called.
  static Future<SinceWhenDatabase> openInMemory() async {
    final db = await DatabaseInitializer.openInMemoryDatabase();
    return SinceWhenDatabase._(db);
  }

  // ---------------------------------------------------------------------------
  // Database Lifecycle
  // ---------------------------------------------------------------------------

  /// Closes the database connection.
  ///
  /// For named instances, this releases resources.
  /// For singleton, this also resets the singleton state.
  Future<void> close() async {
    await _db.close();

    // Reset singleton if this is the singleton instance
    if (_singleton?._db == _db) {
      _singleton = null;
    }
  }

  /// Returns `true` if the database is open.
  bool get isOpen => _db.isOpen;

  // ---------------------------------------------------------------------------
  // Database Metadata
  // ---------------------------------------------------------------------------

  /// Returns metadata for all application tables in the database.
  ///
  /// Excludes SQLite internal tables (sqlite_*).
  ///
  /// Returns a list of [TableInfo] containing table names and row counts.
  Future<List<TableInfo>> getTableListInfo() async {
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

    return tableInfoList;
  }

  // ---------------------------------------------------------------------------
  // CRUD: Create
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // CRUD: Read (stubs)
  // ---------------------------------------------------------------------------

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
  // TODO(steven): Implement in ReadOperations.
  Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByTag(
    String tag,
  ) async {
    throw UnimplementedError('getByTag not yet implemented');
  }

  /// Gets all records in a category.
  ///
  // TODO(steven): Implement in ReadOperations.
  Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByCategory(
    String category,
  ) async {
    throw UnimplementedError('getByCategory not yet implemented');
  }

  // ---------------------------------------------------------------------------
  // CRUD: Update (stubs)
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // CRUD: Delete (stubs)
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Import / Export: String-based
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Import / Export: File-based
  // ---------------------------------------------------------------------------

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
