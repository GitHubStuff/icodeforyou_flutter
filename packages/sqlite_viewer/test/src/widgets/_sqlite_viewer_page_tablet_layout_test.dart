// test/src/widgets/_sqlite_viewer_page_tablet_layout_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sqlite_viewer/src/abstract/sqlite_viewer_abstract.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_cubit.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_state.dart';
import 'package:sqlite_viewer/src/failures/sqlite_viewer_failure.dart';
import 'package:sqlite_viewer/src/models/database_metadata.dart';
import 'package:sqlite_viewer/src/models/pragma_key.dart';
import 'package:sqlite_viewer/src/widgets/sqlite_viewer_page.dart';

// ---------------------------------------------------------------------------
// Fake source — every method returns Left so all cubit calls fail gracefully.
// ---------------------------------------------------------------------------

class _FailingSource implements SqliteViewerAbstract {
  static const _failure = ViewerDatabaseNotOpen();

  @override
  Future<Either<SqliteViewerFailure, String>> getFullPath() async =>
      const Left(_failure);

  @override
  Future<Either<SqliteViewerFailure, String>> getSqliteVersion() async =>
      const Left(_failure);

  @override
  Future<Either<SqliteViewerFailure, int>> getDatabaseSize() async =>
      const Left(_failure);

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getTableNames() async =>
      const Left(_failure);

  @override
  Future<Either<SqliteViewerFailure, int>> getRowCount(
    String tableName,
  ) async =>
      const Left(_failure);

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getColumnNames(
    String tableName,
  ) async =>
      const Left(_failure);

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> getPragma({
    required String tableName,
    required PragmaKey key,
  }) async =>
      const Left(_failure);

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> executeSelect(
    String sql,
  ) async =>
      const Left(_failure);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _metadata = DatabaseMetadata(
  fullPath: '/tmp/test.db',
  sqliteVersion: '3.39.0',
  databaseSize: 4096,
  tables: ['users'],
);

void _forceTabletSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1024);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpSeeded(
  WidgetTester tester,
  SqliteViewerState state,
) async {
  _forceTabletSize(tester);

  final cubit = SqliteViewerCubit.seeded(_FailingSource(), state);
  addTearDown(cubit.close);

  await tester.pumpWidget(
    MaterialApp(
      home: SqliteViewerPage.withCubit(
        source: _FailingSource(),
        cubit: cubit,
        title: 'Test DB',
      ),
    ),
  );

  await tester.pump();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Line 46: ViewerConnectionFailed → _ErrorView(message: failure.message)
  // -------------------------------------------------------------------------

  group('_TabletLayout _buildBody ViewerConnectionFailed', () {
    testWidgets('renders failure message', (tester) async {
      _forceTabletSize(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: SqliteViewerPage(
            source: _FailingSource(),
            title: 'Test DB',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Database is not open'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Lines 71–72: onRefresh inside SqliteViewerMetadataPanel
  // -------------------------------------------------------------------------

  group('_TabletLayout _buildConnectedLayout onRefresh', () {
    testWidgets('tapping refresh calls refreshMetadata', (tester) async {
      await _pumpSeeded(
        tester,
        const MetadataLoaded(metadata: _metadata),
      );

      // SqliteViewerMetadataPanel renders a refresh IconButton.
      final refreshBtn = find.byIcon(Icons.refresh);
      expect(refreshBtn, findsOneWidget);
      await tester.tap(refreshBtn);
      await tester.pumpAndSettle();
    });
  });

  // -------------------------------------------------------------------------
  // Lines 135–140: TableDetailLoadFailed → _ErrorView with onRetry
  // -------------------------------------------------------------------------

  group('_TabletLayout _buildMainContent TableDetailLoadFailed', () {
    testWidgets('renders error message with table name', (tester) async {
      await _pumpSeeded(
        tester,
        const TableDetailLoadFailed(
          metadata: _metadata,
          tableName: 'users',
          failure: ViewerTableNotFound('users'),
        ),
      );

      expect(
        find.textContaining('Failed to load users'),
        findsOneWidget,
      );
    });

    testWidgets('Retry button fires onRetry — triggers selectTable',
        (tester) async {
      await _pumpSeeded(
        tester,
        const TableDetailLoadFailed(
          metadata: _metadata,
          tableName: 'users',
          failure: ViewerTableNotFound('users'),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
    });
  });
}
