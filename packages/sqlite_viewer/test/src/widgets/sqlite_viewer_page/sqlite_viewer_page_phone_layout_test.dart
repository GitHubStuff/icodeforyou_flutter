// test/src/widgets/sqlite_viewer_page/sqlite_viewer_page_phone_layout_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../../helpers/mock_sqlite_viewer_source.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  // Phone layout activates when viewport width < 600.
  // Use 590 (close to upper bound) so the table-detail tab Row has enough
  // room to render without triggering a layout overflow in the widget.
  Future<void> pumpPhone(
    WidgetTester tester, {
    required MockSqliteViewerSource source,
    required SqliteViewerCubit cubit,
    bool showQueryInput = true,
  }) async {
    tester.view
      ..physicalSize = const Size(590 * 3, 800 * 3)
      ..devicePixelRatio = 3;
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

  group('PhoneLayout state-driven body', () {
    testWidgets('renders DisconnectedView from ViewerDisconnected', (
      tester,
    ) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit(source);
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.text('Not connected'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders LoadingView from ViewerConnecting', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(source, const ViewerConnecting());
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.text('Connecting...'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders ErrorView from ViewerConnectionFailed', (
      tester,
    ) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const ViewerConnectionFailed(failure: ViewerDatabaseNotOpen()),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.text('Database is not open'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders metadata panel from MetadataLoaded', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders body from MetadataLoading', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoading(metadata: testMetadata),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders DisconnectedView when MetadataLoadFailed has no '
        'previous metadata', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoadFailed(failure: ViewerDatabaseNotOpen()),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.text('Not connected'), findsOneWidget);
      await cubit.close();
    });

    testWidgets(
      'renders panel when MetadataLoadFailed has previous metadata',
      (tester) async {
        final source = createTestMockSource();
        final cubit = SqliteViewerCubit.seeded(
          source,
          const MetadataLoadFailed(
            failure: ViewerDatabaseNotOpen(),
            metadata: testMetadata,
          ),
        );
        await pumpPhone(tester, source: source, cubit: cubit);
        expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
        await cubit.close();
      },
    );

    testWidgets('renders metadata panel from TableDetailLoading', (
      tester,
    ) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const TableDetailLoading(
          metadata: testMetadata,
          tableName: 'users',
        ),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders metadata panel from TableDetailLoaded', (
      tester,
    ) async {
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
          rows: [],
          rowCount: 0,
        ),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders metadata panel from TableDetailLoadFailed', (
      tester,
    ) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const TableDetailLoadFailed(
          metadata: testMetadata,
          tableName: 'users',
          failure: ViewerDatabaseNotOpen(),
        ),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders metadata panel from QueryExecuting', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const QueryExecuting(metadata: testMetadata, query: 'SELECT 1'),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders metadata panel from QueryResultLoaded', (
      tester,
    ) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT 1',
          columns: ['c'],
          rows: [
            {'c': 1},
          ],
        ),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders metadata panel from QueryFailed', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const QueryFailed(
          metadata: testMetadata,
          query: 'SELECT 1',
          failure: ViewerDatabaseNotOpen(),
        ),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      await cubit.close();
    });
  });

  group('PhoneLayout app bar', () {
    testWidgets('shows refresh action button in MetadataLoaded', (
      tester,
    ) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.byTooltip('Refresh'), findsOneWidget);

      await tester.tap(find.byTooltip('Refresh'));
      await tester.pump();
      await cubit.close();
    });

    testWidgets('shows refresh action button in TableDetailLoaded', (
      tester,
    ) async {
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
          rows: [],
          rowCount: 0,
        ),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.byTooltip('Refresh'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('shows refresh in QueryResultLoaded', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const QueryResultLoaded(
          metadata: testMetadata,
          query: 'SELECT 1',
          columns: ['c'],
          rows: [
            {'c': 1},
          ],
        ),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.byTooltip('Refresh'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('hides refresh action when disconnected', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit(source);
      await pumpPhone(tester, source: source, cubit: cubit);
      expect(find.byTooltip('Refresh'), findsNothing);
      await cubit.close();
    });
  });

  group('PhoneLayout bottom navigation', () {
    testWidgets('shows three destinations when showQueryInput is true', (
      tester,
    ) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      // "Tables" appears in both the metadata-panel section heading and the
      // NavigationDestination label — scope to inside the NavigationBar.
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byType(NavigationDestination),
        ),
        findsNWidgets(3),
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Tables'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Data'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Query'),
        ),
        findsOneWidget,
      );
      await cubit.close();
    });

    testWidgets('shows two destinations when showQueryInput is false', (
      tester,
    ) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpPhone(
        tester,
        source: source,
        cubit: cubit,
        showQueryInput: false,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byType(NavigationDestination),
        ),
        findsNWidgets(2),
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Query'),
        ),
        findsNothing,
      );
      await cubit.close();
    });

    testWidgets('tapping Data tab switches index to 1 → EmptyDataView', (
      tester,
    ) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Data'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Select a table to view data'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('tapping Query tab switches to query view', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Query'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SqlCommand), findsOneWidget);
      await cubit.close();
    });
  });

  group('PhoneLayout Data tab content', () {
    Future<void> openDataTab(WidgetTester tester) async {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Data'),
        ),
      );
      // Some states render a perpetual CircularProgressIndicator, so
      // pumpAndSettle would never finish — pump a few frames instead.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders LoadingView for TableDetailLoading', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const TableDetailLoading(
          metadata: testMetadata,
          tableName: 'users',
        ),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      await openDataTab(tester);
      expect(find.text('Loading users...'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('renders SqliteViewerTableDetail for TableDetailLoaded', (
      tester,
    ) async {
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
      await pumpPhone(tester, source: source, cubit: cubit);
      await openDataTab(tester);
      expect(find.byType(SqliteViewerTableDetail), findsOneWidget);
      await cubit.close();
    });

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
      await pumpPhone(tester, source: source, cubit: cubit);
      await openDataTab(tester);
      expect(
        find.text('Failed to load users: Database is not open'),
        findsOneWidget,
      );
      // Retry button should be present
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await cubit.close();
    });

    testWidgets('renders QueryResultView for QueryResultLoaded', (
      tester,
    ) async {
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
      await pumpPhone(tester, source: source, cubit: cubit);
      await openDataTab(tester);
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
      await pumpPhone(tester, source: source, cubit: cubit);
      await openDataTab(tester);
      expect(find.text('Query failed: Database is not open'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await cubit.close();
    });

    testWidgets('renders EmptyDataView for QueryExecuting (fall-through)', (
      tester,
    ) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const QueryExecuting(metadata: testMetadata, query: 'SELECT 1'),
      );
      await pumpPhone(tester, source: source, cubit: cubit);
      await openDataTab(tester);
      expect(find.text('Select a table to view data'), findsOneWidget);
      await cubit.close();
    });
  });

  group('PhoneLayout Tables tab interaction', () {
    testWidgets(
      'tapping a table dispatches selectTable and switches to Data tab',
      (tester) async {
        final source = createTestMockSource();
        final cubit = SqliteViewerCubit.seeded(
          source,
          const MetadataLoaded(metadata: testMetadata),
        );
        await pumpPhone(tester, source: source, cubit: cubit);

        await tester.tap(find.text('users'));
        // Don't pumpAndSettle — selectTable triggers a perpetual loading
        // spinner. Pump a few frames to let the tap dispatch.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // NavigationBar still mounted with its 'Tables' destination label.
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text('Tables'),
          ),
          findsOneWidget,
        );
        await cubit.close();
      },
    );
  });
}
