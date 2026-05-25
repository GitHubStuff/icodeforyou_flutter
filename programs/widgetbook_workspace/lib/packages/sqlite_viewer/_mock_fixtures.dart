// lib/packages/sqlite_viewer/_mock_fixtures.dart

part of 'sqlite_viewer.usecase.dart';

// ---------------------------------------------------------------------------
// Metadata
// ---------------------------------------------------------------------------

const DatabaseMetadata _mockMetadata = DatabaseMetadata(
  fullPath: '/data/app/widgetbook_workspace/mock.db',
  sqliteVersion: '3.43.2',
  databaseSize: 81920,
  tables: ['users', 'posts', 'tags'],
);

// ---------------------------------------------------------------------------
// users table — columns
// ---------------------------------------------------------------------------

const List<String> _usersColumns = ['id', 'name', 'email', 'active'];

// ---------------------------------------------------------------------------
// users table — PRAGMA table_info rows
// ---------------------------------------------------------------------------

const List<Map<String, Object?>> _usersTableInfo = [
  {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 1, 'pk': 1},
  {'cid': 1, 'name': 'name', 'type': 'TEXT', 'notnull': 1, 'pk': 0},
  {'cid': 2, 'name': 'email', 'type': 'TEXT', 'notnull': 1, 'pk': 0},
  {'cid': 3, 'name': 'active', 'type': 'INTEGER', 'notnull': 0, 'pk': 0},
];

// ---------------------------------------------------------------------------
// users table — PRAGMA index_list rows
// ---------------------------------------------------------------------------

const List<Map<String, Object?>> _usersIndexList = [
  {'seq': 0, 'name': 'idx_users_email', 'unique': 1, 'origin': 'c'},
];

// ---------------------------------------------------------------------------
// users table — data rows
// ---------------------------------------------------------------------------

const List<Map<String, Object?>> _usersRows = [
  {'id': 1, 'name': 'Alice Nguyen', 'email': 'alice@example.com', 'active': 1},
  {'id': 2, 'name': 'Bob Martínez', 'email': 'bob@example.com', 'active': 1},
  {'id': 3, 'name': 'Carol Smith', 'email': 'carol@example.com', 'active': 0},
  {'id': 4, 'name': 'David Kim', 'email': 'david@example.com', 'active': 1},
  {'id': 5, 'name': 'Eva Johansson', 'email': 'eva@example.com', 'active': 1},
  {'id': 6, 'name': 'Frank Okafor', 'email': 'frank@example.com', 'active': 0},
];
