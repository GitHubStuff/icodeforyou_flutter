// lib/src/_db_viewer_impl.dart

part of 'since_when_database.dart';

mixin _DatabaseViewerMixin implements SqliteViewerAbstract {
  Database get _db;
  String get _fullPath;

  /// Gets detailed table info including row counts.
  Future<Either<SinceWhenFailure, List<TableInfo>>> getTableInfo() async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    try {
      final tables = await _db.rawQuery(
        'SELECT name FROM sqlite_master '
        "WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
      );
      final list = <TableInfo>[];
      for (final row in tables) {
        final name = row['name']! as String;
        final countResult = await _db.rawQuery(
          'SELECT COUNT(*) as count FROM "$name"',
        );
        list.add(TableInfo(
          tableName: name,
          rowCount: countResult.first['count']! as int,
        ));
      }
      return Right(list);
    } on Exception catch (e) {
      return Left(UnexpectedDatabaseError('Failed to get table info', e));
    }
  }

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
  Future<Either<SqliteViewerFailure, int>> getRowCount(
    String tableName,
  ) async {
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
