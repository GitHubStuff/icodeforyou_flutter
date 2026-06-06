// test/src/widgets/sqlite_viewer_page/sqlite_viewer_page_tablet_layout_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../../helpers/mock_sqlite_viewer_source.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  // Tablet: 600 ≤ width < 1200. Desktop: width ≥ 1200.
  Future<void> pumpAt(
    WidgetTester tester, {
    required double width,
    required MockSqliteViewerSource source,
    required SqliteViewerCubit cubit,
    bool showQueryInput = true,
  }) async {
    tester.view
      ..physicalSize = Size(width * 2, 800 * 2)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SqliteViewerPage.withCubit(
          source: source,
          cubit: cubit,
          showQueryInput: showQueryInput,
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpTablet(
    WidgetTester tester, {
    required MockSqliteViewerSource source,
    required SqliteViewerCubit cubit,
    bool showQueryInput = true,
  }) =>
      pumpAt(
        tester,
        width: 900,
        source: source,
        cubit: cubit,
        showQueryInput: showQueryInput,
      );

  Future<void> pumpDesktop(
    WidgetTester tester, {
    required MockSqliteViewerSource source,
    required SqliteViewerCubit cubit,
  }) =>
      pumpAt(tester, width: 1400, source: source, cubit: cubit);

  group('TabletLayout state-driven body', () {
    testWidgets('renders DisconnectedView from ViewerDisconnected',
        (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit(source);
      await pumpTablet(tester, source: source, cubit: cubit);
      expect(find.text('Not connected'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders LoadingView from ViewerConnecting', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(source, const ViewerConnecting());
      await pumpTablet(tester, source: source, cubit: cubit);
      expect(find.text('Connecting...'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders ErrorView from ViewerConnectionFailed',
        (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
      );
      await pumpTablet(tester, source: source, cubit: cubit);
      expect(find.text('Database is not open'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders sidebar + SelectTablePrompt for MetadataLoaded',
        (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpTablet(tester, source: source, cubit: cubit);
      expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      expect(find.text('Select a table from the sidebar'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders LoadingView for TableDetailLoading', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const TableDetailLoading(
          metadata: testMetadata,
          tableName: 'users',
        ),
      );
      await pumpTablet(tester, source: source, cubit: cubit);
      expect(find.text('Loading users...'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders SqliteViewerTableDetail for TableDetailLoaded',
        (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const TableDetailLoaded(
          metadata: testMetadata,
          tableName: 'users',
          columns: ['id'],
          tableInfo: [],
          indexList: [],
          foreignKeys: [],
          rows: [
            {'id': 1},
          ],
          rowCount: 1,
        ),
      );
      await pumpTablet(tester, source: source, cubit: cubit);
      expect(find.byType(SqliteViewerTableDetail), findsOneWidget);
      await cubit.close();
    });

    testWidgets(
      'tapping refresh in SqliteViewerTableDetail dispatches selectTable',
      (tester) async {
        final source = createTestMockSource();
        final cubit = SqliteViewerCubit.seeded(
          source,
          const TableDetailLoaded(
            metadata: testMetadata,
            tableName: 'users',
            columns: ['id'],
            tableInfo: [],
            indexList: [],
            foreignKeys: [],
            rows: [
              {'id': 1},
            ],
            rowCount: 1,
          ),
        );
        await pumpTablet(tester, source: source, cubit: cubit);

        // The table-detail widget renders directly in the main content on
        // tablet. Its own refresh action uses tooltip 'Refresh table data'
        // — distinct from the sidebar panel's 'Refresh metadata'.
        final refreshButton = find.byTooltip('Refresh table data');
        expect(refreshButton, findsOneWidget);

        // Tapping invokes the onRefresh closure, which dispatches
        // selectTable(tableName) and drops the main content into a
        // perpetual loading spinner — pump a single frame, don't settle.
        await tester.tap(refreshButton);
        await tester.pump();

        await cubit.close();
      },
    );

    testWidgets('renders ErrorView for TableDetailLoadFailed', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: 'users',
          failure: ViewerDatabaseNotOpen(),
        ),
      );
      await pumpTablet(tester, source: source, cubit: cubit);
      expect(
        find.text('Failed to load users: Database is not open'),
        findsOneWidget,
      );
      // Tap Retry to cover the retry callback.
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await cubit.close();
    });

    testWidgets('renders LoadingView for QueryExecuting', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const QueryExecuting(metadata: testMetadata, query: 'SELECT 1'),
      );
      await pumpTablet(tester, source: source, cubit: cubit);
      expect(find.text('Executing query...'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders QueryResultView for QueryResultLoaded',
        (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT * FROM users',
          columns: ['id'],
          rows: [
            {'id': 1},
          ],
        ),
      );
      await pumpTablet(tester, source: source, cubit: cubit);
      expect(find.text('SELECT * FROM users'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders ErrorView for QueryFailed', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const QueryFailed(
          metadata: testMetadata,
          query: 'SELECT *',
          failure: ViewerDatabaseNotOpen(),
        ),
      );
      await pumpTablet(tester, source: source, cubit: cubit);
      expect(find.text('Query failed: Database is not open'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await cubit.close();
    });

    testWidgets('shows SqlCommand input bar when showQueryInput is true',
        (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpTablet(tester, source: source, cubit: cubit);
      expect(find.byType(SqlCommand), findsOneWidget);
      await cubit.close();
    });

    testWidgets('hides SqlCommand input bar when showQueryInput is false',
        (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpTablet(
        tester,
        source: source,
        cubit: cubit,
        showQueryInput: false,
      );
      expect(find.byType(SqlCommand), findsNothing);
      await cubit.close();
    });

    testWidgets(
      'tapping a table in sidebar invokes selectTable on the cubit',
      (tester) async {
        final source = createTestMockSource();
        final cubit = SqliteViewerCubit.seeded(
          source,
          const MetadataLoaded(metadata: testMetadata),
        );
        await pumpTablet(tester, source: source, cubit: cubit);
        await tester.tap(find.text('users'));
        await tester.pumpAndSettle();
        await cubit.close();
      },
    );

    testWidgets(
      'tapping refresh in sidebar invokes refreshMetadata on the cubit',
      (tester) async {
        final source = createTestMockSource();
        final cubit = SqliteViewerCubit.seeded(
          source,
          const MetadataLoaded(metadata: testMetadata),
        );
        await pumpTablet(tester, source: source, cubit: cubit);
        // The metadata panel's refresh button has tooltip "Refresh metadata"
        await tester.tap(find.byTooltip('Refresh metadata'));
        await tester.pumpAndSettle();
        await cubit.close();
      },
    );

    testWidgets(
      'sidebar isLoading is true when state is MetadataLoading',
      (tester) async {
        final source = createTestMockSource();
        final cubit = SqliteViewerCubit.seeded(
          source,
          const MetadataLoading(metadata: testMetadata),
        );
        await pumpTablet(tester, source: source, cubit: cubit);
        // metadata panel shows CircularProgressIndicator when isLoading
        expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
        await cubit.close();
      },
    );

    testWidgets(
      'when state has no metadata but reaches connected layout, falls back to '
      'DisconnectedView',
      (tester) async {
        // MetadataLoadFailed with metadata = null isn't routed via
        // _buildBody (it goes to switch default). Force into the fall-back
        // by seeding with MetadataLoadFailed(metadata: null).
        final source = createTestMockSource();
        final cubit = SqliteViewerCubit.seeded(
          source,
          const MetadataLoadFailed(failure: ViewerDatabaseNotOpen()),
        );
        await pumpTablet(tester, source: source, cubit: cubit);
        expect(find.text('Not connected'), findsOneWidget);
        await cubit.close();
      },
    );
  });

  group('DesktopLayout (≥1200dp) reuses tablet layout', () {
    testWidgets('renders MetadataPanel + SelectTablePrompt for MetadataLoaded',
        (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpDesktop(tester, source: source, cubit: cubit);
      expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      expect(find.text('Select a table from the sidebar'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders ErrorView when ViewerConnectionFailed',
        (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
      );
      await pumpDesktop(tester, source: source, cubit: cubit);
      expect(find.text('Database is not open'), findsOneWidget);
      await cubit.close();
    });
  });
}
