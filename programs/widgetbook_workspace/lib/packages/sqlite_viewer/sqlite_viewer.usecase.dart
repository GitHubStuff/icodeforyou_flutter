// lib/packages/sqlite_viewer/sqlite_viewer.usecase.dart

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

part '_mock_source.dart';
part '_mock_fixtures.dart';

// ---------------------------------------------------------------------------
// Shared builder
// ---------------------------------------------------------------------------

Widget _page(SqliteViewerState state) {
  const source = _MockSource();
  final cubit = SqliteViewerCubit.withState(source, state);
  return SqliteViewerPage.forWidgetbook(source: source, cubit: cubit);
}

// ---------------------------------------------------------------------------
// Metadata loaded — home state
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Metadata Loaded', type: SqliteViewerPage)
Widget sqliteViewerMetadataLoaded(BuildContext context) {
  return _page(const MetadataLoaded(metadata: _mockMetadata));
}

// ---------------------------------------------------------------------------
// Connecting — spinner state
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Connecting', type: SqliteViewerPage)
Widget sqliteViewerConnecting(BuildContext context) {
  return _page(const ViewerConnecting());
}

// ---------------------------------------------------------------------------
// Connection failed
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Connection Failed', type: SqliteViewerPage)
Widget sqliteViewerConnectionFailed(BuildContext context) {
  return _page(
    const ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
  );
}

// ---------------------------------------------------------------------------
// Table detail loaded
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Table Detail', type: SqliteViewerPage)
Widget sqliteViewerTableDetail(BuildContext context) {
  return _page(
    TableDetailLoaded(
      metadata: _mockMetadata,
      tableName: 'users',
      columns: _usersColumns,
      tableInfo: _usersTableInfo,
      indexList: _usersIndexList,
      foreignKeys: const [],
      rows: _usersRows,
      rowCount: _usersRows.length,
    ),
  );
}

// ---------------------------------------------------------------------------
// Query result loaded
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Query Result', type: SqliteViewerPage)
Widget sqliteViewerQueryResult(BuildContext context) {
  return _page(
    const QueryResultLoaded(
      metadata: _mockMetadata,
      query: 'SELECT id, name, email FROM users WHERE active = 1',
      columns: _usersColumns,
      rows: _usersRows,
    ),
  );
}

// ---------------------------------------------------------------------------
// Query failed
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Query Failed', type: SqliteViewerPage)
Widget sqliteViewerQueryFailed(BuildContext context) {
  return _page(
    const QueryFailed(
      metadata: _mockMetadata,
      query: 'SELECT * FROM nonexistent_table',
      failure: ViewerQueryFailed(
        'SELECT * FROM nonexistent_table',
        'no such table: nonexistent_table',
      ),
    ),
  );
}
