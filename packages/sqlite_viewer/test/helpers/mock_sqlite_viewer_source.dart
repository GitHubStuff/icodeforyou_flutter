// test/helpers/mock_sqlite_viewer_source.dart

import 'package:fpdart/fpdart.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

/// Mock implementation of [SqliteViewerAbstract] for testing.
class MockSqliteViewerSource implements SqliteViewerAbstract {
  MockSqliteViewerSource({
    this.fullPath = '/path/test.db',
    this.sqliteVersion = '3.39.0',
    this.databaseSize = 1024,
    this.tableNames = const ['users', 'posts'],
    this.rowCounts = const {'users': 10, 'posts': 5},
    this.columnNamesMap = const {
      'users': ['id', 'name', 'email'],
      'posts': ['id', 'title', 'user_id'],
    },
    this.pragmaResults = const {},
    this.selectResults = const {},
  });

  final String fullPath;
  final String sqliteVersion;
  final int databaseSize;
  final List<String> tableNames;
  final Map<String, int> rowCounts;
  final Map<String, List<String>> columnNamesMap;
  final Map<String, List<Map<String, Object?>>> pragmaResults;
  final Map<String, List<Map<String, Object?>>> selectResults;

  SqliteViewerFailure? getFullPathFailure;
  SqliteViewerFailure? getSqliteVersionFailure;
  SqliteViewerFailure? getDatabaseSizeFailure;
  SqliteViewerFailure? getTableNamesFailure;
  SqliteViewerFailure? getRowCountFailure;
  SqliteViewerFailure? getColumnNamesFailure;
  SqliteViewerFailure? getPragmaFailure;
  SqliteViewerFailure? executeSelectFailure;

  /// Per-[PragmaKey] failure injection.
  ///
  /// Lets a single PRAGMA call fail while the others succeed — required to
  /// reach the `indexList` and `foreignKeyList` failure branches in
  /// `SqliteViewerCubit.selectTable`, which a global [getPragmaFailure] can
  /// never hit because `tableInfo` is queried first and returns early.
  Map<PragmaKey, SqliteViewerFailure> pragmaKeyFailures =
      const <PragmaKey, SqliteViewerFailure>{};

  @override
  Future<Either<SqliteViewerFailure, String>> getFullPath() async {
    if (getFullPathFailure != null) {
      return Left(getFullPathFailure!);
    }
    return Right(fullPath);
  }

  @override
  Future<Either<SqliteViewerFailure, String>> getSqliteVersion() async {
    if (getSqliteVersionFailure != null) {
      return Left(getSqliteVersionFailure!);
    }
    return Right(sqliteVersion);
  }

  @override
  Future<Either<SqliteViewerFailure, int>> getDatabaseSize() async {
    if (getDatabaseSizeFailure != null) {
      return Left(getDatabaseSizeFailure!);
    }
    return Right(databaseSize);
  }

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getTableNames() async {
    if (getTableNamesFailure != null) {
      return Left(getTableNamesFailure!);
    }
    return Right(tableNames);
  }

  @override
  Future<Either<SqliteViewerFailure, int>> getRowCount(String tableName) async {
    if (getRowCountFailure != null) {
      return Left(getRowCountFailure!);
    }
    final count = rowCounts[tableName];
    if (count == null) {
      return Left(ViewerTableNotFound(tableName));
    }
    return Right(count);
  }

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getColumnNames(
    String tableName,
  ) async {
    if (getColumnNamesFailure != null) {
      return Left(getColumnNamesFailure!);
    }
    final columns = columnNamesMap[tableName];
    if (columns == null) {
      return Left(ViewerTableNotFound(tableName));
    }
    return Right(columns);
  }

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> getPragma({
    required String tableName,
    required PragmaKey key,
  }) async {
    if (getPragmaFailure != null) {
      return Left(getPragmaFailure!);
    }
    final keyFailure = pragmaKeyFailures[key];
    if (keyFailure != null) {
      return Left(keyFailure);
    }
    final keyStr = '${tableName}_${key.name}';
    return Right(pragmaResults[keyStr] ?? []);
  }

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> executeSelect(
    String sql,
  ) async {
    if (executeSelectFailure != null) {
      return Left(executeSelectFailure!);
    }
    return Right(selectResults[sql] ?? []);
  }
}
