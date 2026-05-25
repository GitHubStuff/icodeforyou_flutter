// startup_demo/lib/src/pages/database_pages/handle_viewer_source.dart

// ignore_for_file: public_member_api_docs

import 'package:fpdart/fpdart.dart';
import 'package:since_when_framework/database.dart' show DatabaseHandle;
import 'package:sqlite_viewer/sqlite_viewer.dart';

/// Adapts a [DatabaseHandle] to [SqliteViewerAbstract] so the
/// `sqlite_viewer` package can introspect any backend that speaks the
/// framework's handle contract.
///
/// The handle is the single seam between the framework and a database
/// backend (sqflite today, others tomorrow). This adapter speaks only
/// to the handle — swapping the backend underneath does not require
/// changes here.
///
/// All viewer reads are routed through [DatabaseHandle.query]. Failures
/// are translated into the viewer's sealed [SqliteViewerFailure]
/// hierarchy so the viewer UI can render errors uniformly.
class HandleViewerSource implements SqliteViewerAbstract {
  /// Wraps [handle]. [fullPath] is reported to the viewer's metadata
  /// panel — defaults to sqflite's in-memory sentinel.
  const HandleViewerSource({
    required DatabaseHandle handle,
    String fullPath = ':memory:',
  })  : _handle = handle,
        _fullPath = fullPath;

  final DatabaseHandle _handle;
  final String _fullPath;

  // ─── Database-level metadata ──────────────────────────────────────────────

  @override
  Future<Either<SqliteViewerFailure, String>> getFullPath() async {
    if (!_handle.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }
    return Right(_fullPath);
  }

  @override
  Future<Either<SqliteViewerFailure, String>> getSqliteVersion() async {
    if (!_handle.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }
    try {
      final rows = await _handle.query('SELECT sqlite_version() AS v');
      return Right(rows.first['v']?.toString() ?? '');
    } on Object catch (e) {
      return Left(ViewerMetadataFailed('sqlite_version', e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, int>> getDatabaseSize() async {
    if (!_handle.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }
    try {
      final countRows = await _handle.query('PRAGMA page_count');
      final sizeRows = await _handle.query('PRAGMA page_size');
      final pageCount = (countRows.first.values.first as num?)?.toInt() ?? 0;
      final pageSize = (sizeRows.first.values.first as num?)?.toInt() ?? 0;
      return Right(pageCount * pageSize);
    } on Object catch (e) {
      return Left(ViewerMetadataFailed('database_size', e.toString()));
    }
  }

  // ─── Table discovery ──────────────────────────────────────────────────────

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getTableNames() async {
    if (!_handle.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }
    try {
      final rows = await _handle.query(
        'SELECT name FROM sqlite_master '
        "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' "
        'ORDER BY name',
      );
      final names = rows
          .map((row) => row['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      return Right(names);
    } on Object catch (e) {
      return Left(ViewerMetadataFailed('table_names', e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, int>> getRowCount(
    String tableName,
  ) async {
    if (!_handle.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }
    if (!await _tableExists(tableName)) {
      return Left(ViewerTableNotFound(tableName));
    }
    try {
      final rows = await _handle.query(
        'SELECT COUNT(*) AS c FROM "$tableName"',
      );
      final count = (rows.first['c'] as num?)?.toInt() ?? 0;
      return Right(count);
    } on Object catch (e) {
      return Left(ViewerQueryFailed(tableName, e.toString()));
    }
  }

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getColumnNames(
    String tableName,
  ) async {
    if (!_handle.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }
    if (!await _tableExists(tableName)) {
      return Left(ViewerTableNotFound(tableName));
    }
    try {
      final rows = await _handle.query('PRAGMA table_info("$tableName")');
      final names = rows
          .map((row) => row['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      return Right(names);
    } on Object catch (e) {
      return Left(
        ViewerPragmaFailed(tableName, 'table_info', e.toString()),
      );
    }
  }

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> getPragma({
    required String tableName,
    required PragmaKey key,
  }) async {
    if (!_handle.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }
    if (!await _tableExists(tableName)) {
      return Left(ViewerTableNotFound(tableName));
    }
    final pragmaName = _pragmaName(key);
    try {
      final rows = await _handle.query('PRAGMA $pragmaName("$tableName")');
      return Right(rows);
    } on Object catch (e) {
      return Left(ViewerPragmaFailed(tableName, pragmaName, e.toString()));
    }
  }

  // ─── Query execution ──────────────────────────────────────────────────────

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>>
      executeSelect(String sql) async {
    if (!_handle.isOpen) {
      return const Left(ViewerDatabaseNotOpen());
    }
    if (!_isReadOnly(sql)) {
      return Left(ViewerInvalidQuery(sql));
    }
    try {
      final rows = await _handle.query(sql);
      return Right(rows);
    } on Object catch (e) {
      return Left(ViewerQueryFailed(sql, e.toString()));
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<bool> _tableExists(String tableName) async {
    final rows = await _handle.query(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
      [tableName],
    );
    return rows.isNotEmpty;
  }

  static String _pragmaName(PragmaKey key) => switch (key) {
        PragmaKey.tableInfo => 'table_info',
        PragmaKey.indexList => 'index_list',
        PragmaKey.foreignKeyList => 'foreign_key_list',
      };

  static bool _isReadOnly(String sql) {
    final trimmed = sql.trimLeft().toUpperCase();
    return trimmed.startsWith('SELECT') || trimmed.startsWith('WITH');
  }
}
