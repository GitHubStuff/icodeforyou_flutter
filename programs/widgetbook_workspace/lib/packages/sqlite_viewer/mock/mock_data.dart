// widgetbook_workspace/lib/packages/sqlite_viewer/mock/mock_data.dart
//
// Inline copy of MockSqliteViewerSource (the test helper at
// test/helpers/mock_sqlite_viewer_source.dart isn't importable from the
// widgetbook workspace) plus shared fixture data used by every state usecase.
//
// ignore_for_file: public_member_api_docs

import 'package:fpdart/fpdart.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

// ────────────────────────────────────────────────────────────────────────────
// Fixtures
// ────────────────────────────────────────────────────────────────────────────

const DatabaseMetadata kMockMetadata = DatabaseMetadata(
  fullPath: '/data/app/widgetbook_workspace/mock.db',
  sqliteVersion: '3.43.2',
  databaseSize: 81920,
  tables: ['users', 'posts', 'tags'],
);

const List<String> kUsersColumns = ['id', 'name', 'email', 'active'];

const List<Map<String, Object?>> kUsersTableInfo = [
  {
    'cid': 0,
    'name': 'id',
    'type': 'INTEGER',
    'notnull': 1,
    'dflt_value': null,
    'pk': 1,
  },
  {
    'cid': 1,
    'name': 'name',
    'type': 'TEXT',
    'notnull': 1,
    'dflt_value': null,
    'pk': 0,
  },
  {
    'cid': 2,
    'name': 'email',
    'type': 'TEXT',
    'notnull': 1,
    'dflt_value': null,
    'pk': 0,
  },
  {
    'cid': 3,
    'name': 'active',
    'type': 'INTEGER',
    'notnull': 0,
    'dflt_value': '1',
    'pk': 0,
  },
];

const List<Map<String, Object?>> kUsersIndexList = [
  {
    'seq': 0,
    'name': 'idx_users_email',
    'unique': 1,
    'origin': 'c',
    'partial': 0,
  },
];

const List<Map<String, Object?>> kUsersForeignKeys = [];

const List<Map<String, Object?>> kUsersRows = [
  {'id': 1, 'name': 'Alice Nguyen', 'email': 'alice@example.com', 'active': 1},
  {'id': 2, 'name': 'Bob Martínez', 'email': 'bob@example.com', 'active': 1},
  {'id': 3, 'name': 'Carol Smith', 'email': 'carol@example.com', 'active': 0},
  {'id': 4, 'name': 'David Kim', 'email': 'david@example.com', 'active': 1},
  {'id': 5, 'name': 'Eva Johansson', 'email': 'eva@example.com', 'active': 1},
  {'id': 6, 'name': 'Frank Okafor', 'email': 'frank@example.com', 'active': 0},
];

// ────────────────────────────────────────────────────────────────────────────
// Mock source
// ────────────────────────────────────────────────────────────────────────────

/// In-package equivalent of `test/helpers/mock_sqlite_viewer_source.dart`.
/// Returns Right values from the fixture data above; no real database opened.
class MockSqliteViewerSource implements SqliteViewerAbstract {
  const MockSqliteViewerSource();

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
  Future<Either<SqliteViewerFailure, int>> getRowCount(String tableName) async {
    const counts = {'users': 6, 'posts': 12, 'tags': 4};
    return Right(counts[tableName] ?? 0);
  }

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getColumnNames(
    String tableName,
  ) async {
    if (tableName == 'users') return const Right(kUsersColumns);
    if (tableName == 'posts') return const Right(['id', 'title', 'user_id']);
    if (tableName == 'tags') return const Right(['id', 'label']);
    return Left(ViewerTableNotFound(tableName));
  }

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> getPragma({
    required String tableName,
    required PragmaKey key,
  }) async {
    return switch (key) {
      PragmaKey.tableInfo => const Right(kUsersTableInfo),
      PragmaKey.indexList => const Right(kUsersIndexList),
      PragmaKey.foreignKeyList => const Right(kUsersForeignKeys),
    };
  }

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> executeSelect(
    String sql,
  ) async =>
      const Right(kUsersRows);
}
