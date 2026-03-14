// lib/packages/sqlite_viewer/_mock_source.dart

part of 'sqlite_viewer.usecase.dart';

// ---------------------------------------------------------------------------
// _MockSource — satisfies SqliteViewerAbstract with hardcoded data.
// No real database is opened; all methods return Right values.
// ---------------------------------------------------------------------------

class _MockSource implements SqliteViewerAbstract {
  const _MockSource();

  @override
  Future<Either<SqliteViewerFailure, String>> getFullPath() async =>
      const Right('/data/app/widgetbook_workspace/mock.db');

  @override
  Future<Either<SqliteViewerFailure, String>> getSqliteVersion() async =>
      const Right('3.43.2');

  @override
  Future<Either<SqliteViewerFailure, int>> getDatabaseSize() async =>
      const Right(81920);

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getTableNames() async =>
      const Right(['users', 'posts', 'tags']);

  @override
  Future<Either<SqliteViewerFailure, int>> getRowCount(
    String tableName,
  ) async {
    final counts = {'users': 6, 'posts': 12, 'tags': 4};
    return Right(counts[tableName] ?? 0);
  }

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getColumnNames(
    String tableName,
  ) async {
    if (tableName == 'users') return const Right(_usersColumns);
    return const Right(['id', 'title', 'body']);
  }

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> getPragma({
    required String tableName,
    required PragmaKey key,
  }) async {
    return switch (key) {
      PragmaKey.tableInfo => const Right(_usersTableInfo),
      PragmaKey.indexList => const Right(_usersIndexList),
      PragmaKey.foreignKeyList => const Right([]),
    };
  }

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> executeSelect(
    String sql,
  ) async =>
      const Right(_usersRows);
}
