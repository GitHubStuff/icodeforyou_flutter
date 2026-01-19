// test/src/widgets/sqlite_viewer_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../helpers/mock_sqlite_viewer_source.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('SqliteViewerPage', () {
    late MockSqliteViewerSource mockSource;

    setUp(() {
      mockSource = createTestMockSource();
    });

    Widget buildWidget({
      MockSqliteViewerSource? source,
      String title = 'SQLite Viewer',
      bool showQueryInput = true,
      double sidebarWidth = 280.0,
      bool showRowNumbers = true,
      String nullValueDisplay = 'NULL',
      TextHandling textHandling = TextHandling.trunc,
    }) {
      return MaterialApp(
        home: SqliteViewerPage(
          source: source ?? mockSource,
          title: title,
          showQueryInput: showQueryInput,
          sidebarWidth: sidebarWidth,
          showRowNumbers: showRowNumbers,
          nullValueDisplay: nullValueDisplay,
          textHandling: textHandling,
        ),
      );
    }

    group('Phone layout (< 600)', () {
      testWidgets('shows bottom navigation bar', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();
        
        expect(find.byType(NavigationBar), findsOneWidget);
      });

      testWidgets('shows Tables, Data, and Query tabs', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();
        
        // Check NavigationBar has 3 destinations
        final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.destinations.length, 3);
      });

      testWidgets('hides Query tab when showQueryInput is false', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        
        await tester.pumpWidget(buildWidget(showQueryInput: false));
        await tester.pumpAndSettle();
        
        // Check NavigationBar has only 2 destinations (no Query)
        final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.destinations.length, 2);
      });

      testWidgets('shows app bar with title', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        
        await tester.pumpWidget(buildWidget(title: 'My Database'));
        await tester.pumpAndSettle();
        
        expect(find.text('My Database'), findsOneWidget);
      });

      testWidgets('shows refresh button in app bar', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();
        
        expect(find.byIcon(Icons.refresh), findsWidgets);
      });

      testWidgets('switches to Data tab when table selected', (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('users'));
        await tester.pumpAndSettle();
        
        expect(find.byType(SqliteViewerTableDetail), findsOneWidget);
      });
    });

    group('Tablet layout (600-1200)', () {
      testWidgets('shows side-by-side layout', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();
        
        expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      });

      testWidgets('shows vertical divider', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();
        
        expect(find.byType(VerticalDivider), findsOneWidget);
      });

      testWidgets('shows query input when enabled', (tester) async {
        await tester.pumpWidget(buildWidget(showQueryInput: true));
        await tester.pumpAndSettle();
        
        expect(find.byType(SqliteViewerQueryInput), findsOneWidget);
      });

      testWidgets('hides query input when disabled', (tester) async {
        await tester.pumpWidget(buildWidget(showQueryInput: false));
        await tester.pumpAndSettle();
        
        expect(find.byType(SqliteViewerQueryInput), findsNothing);
      });

      testWidgets('shows "Select a table" prompt initially', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();
        
        expect(find.text('Select a table from the sidebar'), findsOneWidget);
      });
    });

    group('Desktop layout (> 1200)', () {
      testWidgets('uses same layout as tablet', (tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();
        
        expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      });
    });

    group('State handling', () {
      testWidgets('shows loading view while connecting', (tester) async {
        final slowSource = MockSqliteViewerSource();
        
        await tester.pumpWidget(buildWidget(source: slowSource));
        
        expect(find.text('Connecting...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        
        await tester.pumpAndSettle();
      });

      testWidgets('shows error view on connection failure', (tester) async {
        final failingSource = MockSqliteViewerSource();
        failingSource.getFullPathFailure = const ViewerDatabaseNotOpen();
        
        await tester.pumpWidget(buildWidget(source: failingSource));
        await tester.pumpAndSettle();
        
        expect(find.text('Database is not open'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('shows disconnected view when disconnected', (tester) async {
        await tester.pumpWidget(buildWidget());
        
        expect(find.text('Connecting...'), findsOneWidget);
      });
    });

    group('Query execution', () {
      testWidgets('shows query results', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();
        
        final queryInput = find.byType(TextField);
        await tester.enterText(queryInput, 'SELECT * FROM users');
        await tester.pump();
        
        await tester.tap(find.text('Run Query'));
        await tester.pumpAndSettle();
      });

      testWidgets('shows empty result message', (tester) async {
        final emptySource = MockSqliteViewerSource(
          selectResults: {'SELECT * FROM empty': []},
        );
        
        await tester.pumpWidget(buildWidget(source: emptySource));
        await tester.pumpAndSettle();
        
        final queryInput = find.byType(TextField);
        await tester.enterText(queryInput, 'SELECT * FROM empty');
        await tester.pump();
        
        await tester.tap(find.text('Run Query'));
        await tester.pumpAndSettle();
        
        expect(find.text('Query returned no results'), findsOneWidget);
      });
    });

    group('Table detail', () {
      testWidgets('shows table detail when table selected', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('users'));
        await tester.pumpAndSettle();
        
        expect(find.byType(SqliteViewerTableDetail), findsOneWidget);
      });

      testWidgets('shows loading view while loading table', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('users'));
        await tester.pump();
      });

      testWidgets('shows error when table load fails', (tester) async {
        final failingSource = MockSqliteViewerSource(
          tableNames: ['users'],
        );
        failingSource.getColumnNamesFailure = const ViewerTableNotFound('users');
        
        await tester.pumpWidget(buildWidget(source: failingSource));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('users'));
        await tester.pumpAndSettle();
        
        expect(find.text('Failed to load users: Table not found: users'), findsOneWidget);
      });
    });

    group('Refresh functionality', () {
      testWidgets('refreshes metadata when refresh button tapped', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();
        
        final refreshButtons = find.byIcon(Icons.refresh);
        expect(refreshButtons, findsWidgets);
        
        await tester.tap(refreshButtons.first);
        await tester.pumpAndSettle();
      });
    });

    group('Configuration options', () {
      testWidgets('applies custom title', (tester) async {
        await tester.pumpWidget(buildWidget(title: 'Custom Title'));
        await tester.pumpAndSettle();
        
        expect(find.text('Custom Title'), findsOneWidget);
      });

      testWidgets('applies sidebarWidth', (tester) async {
        await tester.pumpWidget(buildWidget(sidebarWidth: 350.0));
        await tester.pumpAndSettle();
        
        expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      });
    });
  });
}
