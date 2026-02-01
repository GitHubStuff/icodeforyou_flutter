// test/helpers/test_helpers.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import 'mock_sqlite_viewer_source.dart';

/// Wraps a widget with MaterialApp for testing.
Widget testableWidget(Widget widget) {
  return MaterialApp(
    home: widget,
  );
}

/// Wraps a widget with MaterialApp and Scaffold for testing.
Widget testableWidgetWithScaffold(Widget widget) {
  return MaterialApp(
    home: Scaffold(body: widget),
  );
}

/// Creates a widget wrapped with BlocProvider for cubit testing.
Widget testableWidgetWithCubit(
  Widget widget,
  SqliteViewerCubit cubit,
) {
  return MaterialApp(
    home: BlocProvider<SqliteViewerCubit>.value(
      value: cubit,
      child: widget,
    ),
  );
}

/// Creates a widget wrapped with BlocProvider and Scaffold.
Widget testableWidgetWithCubitAndScaffold(
  Widget widget,
  SqliteViewerCubit cubit,
) {
  return MaterialApp(
    home: BlocProvider<SqliteViewerCubit>.value(
      value: cubit,
      child: Scaffold(body: widget),
    ),
  );
}

/// Standard test metadata for widget tests.
const testMetadata = DatabaseMetadata(
  fullPath: '/path/test.db',
  sqliteVersion: '3.39.0',
  databaseSize: 1024,
  tables: ['users', 'posts'],
);

/// Standard in-memory test metadata.
const inMemoryMetadata = DatabaseMetadata(
  fullPath: ':memory:',
  sqliteVersion: '3.39.0',
  databaseSize: 512,
  tables: ['test_table'],
);

/// Standard empty test metadata.
const emptyMetadata = DatabaseMetadata(
  fullPath: '/path/empty.db',
  sqliteVersion: '3.39.0',
  databaseSize: 0,
  tables: [],
);

/// Standard test table info.
const List<Map<String, Object?>> testTableInfo = [
  {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 1, 'dflt_value': null, 'pk': 1},
  {'cid': 1, 'name': 'name', 'type': 'TEXT', 'notnull': 0, 'dflt_value': null, 'pk': 0},
  {'cid': 2, 'name': 'email', 'type': 'TEXT', 'notnull': 1, 'dflt_value': "'default@test.com'", 'pk': 0},
];

/// Standard test index list.
const List<Map<String, Object>> testIndexList = [
  {'seq': 0, 'name': 'idx_users_email', 'unique': 1, 'origin': 'c', 'partial': 0},
  {'seq': 1, 'name': 'sqlite_autoindex_users_1', 'unique': 1, 'origin': 'pk', 'partial': 0},
  {'seq': 2, 'name': 'idx_users_name', 'unique': 0, 'origin': 'u', 'partial': 0},
];

/// Standard test foreign keys.
const List<Map<String, Object>> testForeignKeys = [
  {
    'id': 0,
    'seq': 0,
    'table': 'users',
    'from': 'user_id',
    'to': 'id',
    'on_update': 'NO ACTION',
    'on_delete': 'CASCADE',
  },
];

/// Standard test rows.
const List<Map<String, Object?>> testRows = [
  {'id': 1, 'name': 'Alice', 'email': 'alice@test.com'},
  {'id': 2, 'name': 'Bob', 'email': 'bob@test.com'},
  {'id': 3, 'name': null, 'email': 'null@test.com'},
];

/// Creates a standard mock source for testing.
MockSqliteViewerSource createTestMockSource() {
  return MockSqliteViewerSource(
    fullPath: '/path/test.db',
    sqliteVersion: '3.39.0',
    databaseSize: 1024,
    tableNames: ['users', 'posts'],
    rowCounts: {'users': 10, 'posts': 5},
    columnNamesMap: {
      'users': ['id', 'name', 'email'],
      'posts': ['id', 'title', 'user_id'],
    },
    pragmaResults: {
      'users_tableInfo': testTableInfo,
      'users_indexList': testIndexList,
      'users_foreignKeyList': testForeignKeys,
    },
    selectResults: {
      'SELECT * FROM "users"': testRows,
      'SELECT * FROM users': testRows,
    },
  );
}
