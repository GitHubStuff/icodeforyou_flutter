// lib/src/since_when_database.dart

import 'package:dartz/dartz.dart';
import 'package:since_when/src/constants/database_constants.dart';
import 'package:since_when/src/database/_database_initializer.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/domain/since_when_import_mode.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/domain/table_info.dart';
import 'package:since_when/src/domain/tag_definition.dart';
import 'package:since_when/src/domain/tag_match_mode.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:since_when/src/sql/create/_create_operations.dart';
import 'package:since_when/src/sql/delete/_delete_operations.dart';
import 'package:since_when/src/sql/read/_read_operations.dart';
import 'package:since_when/src/sql/update/_update_operations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

part '_db_viewer_impl.dart';
part '_db_record_ops.dart';
part '_db_tag_ops.dart';

/// Main entry point for SinceWhen database operations.
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

  static SinceWhenDatabase? _fileInstance;

  /// Returns true if a file-based singleton instance exists.
  static bool get hasFileInstance => _fileInstance != null;

  /// Returns true if the database connection is open.
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
  Future<void> close() async {
    await _db.close();
    if (!_isInMemory && _fileInstance == this) {
      _fileInstance = null;
    }
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
