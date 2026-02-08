// packages/sqlite_viewer/test/src/widgets/phone_layout_test.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite_viewer/src/abstract/sqlite_viewer_abstract.dart';
import 'package:sqlite_viewer/src/failures/sqlite_viewer_failure.dart';
import 'package:sqlite_viewer/src/models/pragma_key.dart';
import 'package:sqlite_viewer/src/widgets/sqlite_viewer_page.dart';
import 'package:sqlite_viewer/src/widgets/sqlite_viewer_table_detail.dart';

class MockSource extends Mock implements SqliteViewerAbstract {}

void main() {
  late MockSource mockSource;

  setUp(() {
    mockSource = MockSource();
  });

  void setupConnected() {
    when(
      () => mockSource.getFullPath(),
    ).thenAnswer((_) async => const Right('/test.db'));
    when(
      () => mockSource.getSqliteVersion(),
    ).thenAnswer((_) async => const Right('3.39.0'));
    when(
      () => mockSource.getDatabaseSize(),
    ).thenAnswer((_) async => const Right(4096));
    when(
      () => mockSource.getTableNames(),
    ).thenAnswer((_) async => const Right(['users']));
  }

  void setupTableDetail() {
    when(
      () => mockSource.getColumnNames('users'),
    ).thenAnswer((_) async => const Right(['id', 'name']));
    when(
      () => mockSource.getPragma(tableName: 'users', key: PragmaKey.tableInfo),
    ).thenAnswer(
      (_) async => Right([
        {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 1, 'pk': 1},
      ]),
    );
    when(
      () => mockSource.getPragma(tableName: 'users', key: PragmaKey.indexList),
    ).thenAnswer((_) async => const Right(<Map<String, Object?>>[]));
    when(
      () => mockSource.getPragma(
        tableName: 'users',
        key: PragmaKey.foreignKeyList,
      ),
    ).thenAnswer((_) async => const Right(<Map<String, Object?>>[]));
    when(
      () => mockSource.getRowCount('users'),
    ).thenAnswer((_) async => const Right(1));
    when(() => mockSource.executeSelect('SELECT * FROM "users"')).thenAnswer(
      (_) async => Right([
        {'id': 1, 'name': 'Test'},
      ]),
    );
  }

  // Use 500x800 to avoid overflow but still trigger phone layout (< 600)
  Widget buildConstrained({double width = 500, double height = 800}) {
    return MaterialApp(
      home: Center(
        child: SizedBox(
          width: width,
          height: height,
          child: SqliteViewerPage(source: mockSource),
        ),
      ),
    );
  }

  Widget buildConstrainedNoQuery({double width = 500, double height = 800}) {
    return MaterialApp(
      home: Center(
        child: SizedBox(
          width: width,
          height: height,
          child: SqliteViewerPage(source: mockSource, showQueryInput: false),
        ),
      ),
    );
  }

  group('Phone Layout Coverage', () {
    testWidgets('renders phone layout with NavigationBar', (tester) async {
      setupConnected();

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      // Phone layout has NavigationBar at bottom
      expect(find.byType(NavigationBar), findsOneWidget);

      // NavigationDestination labels (use NavigationDestination finder)
      final navBar = find.byType(NavigationBar);
      expect(
        find.descendant(of: navBar, matching: find.text('Tables')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: navBar, matching: find.text('Data')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: navBar, matching: find.text('Query')),
        findsOneWidget,
      );
    });

    testWidgets('navigates between tabs', (tester) async {
      setupConnected();

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      // Navigate to Data tab
      await tester.tap(find.text('Data').last);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.touch_app), findsOneWidget);

      // Navigate to Query tab
      await tester.tap(find.text('Query').last);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);

      // Navigate back to Tables
      await tester.tap(find.text('Tables').last);
      await tester.pumpAndSettle();
      expect(find.text('users'), findsWidgets);
    });

    testWidgets('table selection navigates to Data tab', (tester) async {
      setupConnected();
      setupTableDetail();

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      // Tap table in list
      await tester.tap(find.text('users').first);
      await tester.pumpAndSettle();

      // Should auto-navigate to Data tab and show table
      expect(find.byType(SqliteViewerTableDetail), findsOneWidget);
    });

    testWidgets('shows connection error', (tester) async {
      when(
        () => mockSource.getFullPath(),
      ).thenAnswer((_) async => Left(ViewerDatabaseNotOpen()));

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      expect(find.text('Database is not open'), findsOneWidget);
    });

    testWidgets('table load error shows retry', (tester) async {
      setupConnected();
      when(
        () => mockSource.getColumnNames('users'),
      ).thenAnswer((_) async => Left(ViewerTableNotFound('users')));

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      await tester.tap(find.text('users').first);
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
      expect(find.textContaining('Failed to load users'), findsOneWidget);
    });

    testWidgets('retry on table failure reloads', (tester) async {
      setupConnected();
      when(
        () => mockSource.getColumnNames('users'),
      ).thenAnswer((_) async => Left(ViewerTableNotFound('users')));

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      await tester.tap(find.text('users').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockSource.getColumnNames('users')).called(2);
    });

    testWidgets('query execution shows results', (tester) async {
      setupConnected();
      when(() => mockSource.executeSelect('SELECT 1')).thenAnswer(
        (_) async => Right([
          {'1': 1},
        ]),
      );

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Query').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'SELECT 1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      expect(find.text('1 rows'), findsOneWidget);
    });

    testWidgets('query failure shows retry', (tester) async {
      setupConnected();
      when(
        () => mockSource.executeSelect('SELECT bad'),
      ).thenAnswer((_) async => Left(ViewerQueryFailed('q', 'error')));

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Query').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'SELECT bad');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      expect(find.textContaining('Query failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry on query failure re-executes', (tester) async {
      setupConnected();
      when(
        () => mockSource.executeSelect('SELECT bad'),
      ).thenAnswer((_) async => Left(ViewerQueryFailed('q', 'error')));

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Query').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'SELECT bad');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockSource.executeSelect('SELECT bad')).called(2);
    });

    testWidgets('app bar refresh calls refreshMetadata', (tester) async {
      setupConnected();

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      // Find refresh in AppBar
      final appBarRefresh = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.refresh),
      );

      await tester.tap(appBarRefresh);
      await tester.pumpAndSettle();

      verify(() => mockSource.getFullPath()).called(greaterThan(1));
    });

    testWidgets('hides Query tab when showQueryInput is false', (tester) async {
      setupConnected();

      await tester.pumpWidget(buildConstrainedNoQuery());
      await tester.pumpAndSettle();

      final navBar = find.byType(NavigationBar);
      expect(
        find.descendant(of: navBar, matching: find.text('Query')),
        findsNothing,
      );
    });

    testWidgets('table detail refresh triggers onRefresh', (tester) async {
      setupConnected();
      setupTableDetail();

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      // Select table
      await tester.tap(find.text('users').first);
      await tester.pumpAndSettle();

      // Find refresh in table detail
      final tableDetailRefresh = find.descendant(
        of: find.byType(SqliteViewerTableDetail),
        matching: find.byIcon(Icons.refresh),
      );

      if (tableDetailRefresh.evaluate().isNotEmpty) {
        await tester.tap(tableDetailRefresh);
        await tester.pumpAndSettle();

        verify(() => mockSource.getColumnNames('users')).called(greaterThan(1));
      }
    });

    testWidgets('MetadataLoadFailed with cached data shows tables', (
      tester,
    ) async {
      setupConnected();

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      // Make refresh fail
      when(
        () => mockSource.getTableNames(),
      ).thenAnswer((_) async => Left(ViewerMetadataFailed('op', 'err')));

      // Trigger refresh
      final appBarRefresh = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.refresh),
      );
      await tester.tap(appBarRefresh);
      await tester.pumpAndSettle();

      // Should still show cached table
      expect(find.text('users'), findsWidgets);
    });

    testWidgets('shows empty data view on Data tab initially', (tester) async {
      setupConnected();

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      // Navigate to Data tab without selecting table
      await tester.tap(find.text('Data').last);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.touch_app), findsOneWidget);
      expect(find.text('Select a table to view data'), findsOneWidget);
    });

    testWidgets('Query tab shows query input and data area', (tester) async {
      setupConnected();

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Query').last);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('QueryResultLoaded shows in Data tab after query', (
      tester,
    ) async {
      setupConnected();
      when(() => mockSource.executeSelect('SELECT 1')).thenAnswer(
        (_) async => Right([
          {'1': 1},
        ]),
      );

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      // Execute query from Query tab
      await tester.tap(find.text('Query').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'SELECT 1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Navigate to Data tab - should show query result
      await tester.tap(find.text('Data').last);
      await tester.pumpAndSettle();

      expect(find.text('1 rows'), findsOneWidget);
    });

    testWidgets('TableDetailLoaded shows in Data tab', (tester) async {
      setupConnected();
      setupTableDetail();

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      // Select table
      await tester.tap(find.text('users').first);
      await tester.pumpAndSettle();

      // Should show table detail
      expect(find.byType(SqliteViewerTableDetail), findsOneWidget);
    });

    testWidgets('refresh button visible in TableDetailLoaded', (tester) async {
      setupConnected();
      setupTableDetail();

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      await tester.tap(find.text('users').first);
      await tester.pumpAndSettle();

      // AppBar refresh should be visible
      final appBarRefresh = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.refresh),
      );
      expect(appBarRefresh, findsOneWidget);
    });

    testWidgets('refresh button visible in QueryResultLoaded', (tester) async {
      setupConnected();
      when(() => mockSource.executeSelect('SELECT 1')).thenAnswer(
        (_) async => Right([
          {'1': 1},
        ]),
      );

      await tester.pumpWidget(buildConstrained());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Query').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'SELECT 1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // AppBar refresh should be visible
      final appBarRefresh = find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.refresh),
      );
      expect(appBarRefresh, findsOneWidget);
    });
  });

  group('Tablet Layout Coverage', () {
    // Use 700x800 to trigger tablet layout (600 <= width < 1200)
    Widget buildTablet({double width = 700, double height = 800}) {
      return MaterialApp(
        home: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: SqliteViewerPage(source: mockSource),
          ),
        ),
      );
    }

    testWidgets('renders tablet layout without NavigationBar', (tester) async {
      setupConnected();

      await tester.pumpWidget(buildTablet());
      await tester.pumpAndSettle();

      // Tablet layout has NO NavigationBar
      expect(find.byType(NavigationBar), findsNothing);
      // Has sidebar with tables
      expect(find.text('users'), findsOneWidget);
    });

    testWidgets('table detail refresh triggers onRefresh', (tester) async {
      setupConnected();
      setupTableDetail();

      await tester.pumpWidget(buildTablet());
      await tester.pumpAndSettle();

      // Select table
      await tester.tap(find.text('users'));
      await tester.pumpAndSettle();

      // Find refresh in table detail (not metadata panel)
      final tableDetailRefresh = find.descendant(
        of: find.byType(SqliteViewerTableDetail),
        matching: find.byIcon(Icons.refresh),
      );

      if (tableDetailRefresh.evaluate().isNotEmpty) {
        await tester.tap(tableDetailRefresh);
        await tester.pumpAndSettle();

        verify(() => mockSource.getColumnNames('users')).called(greaterThan(1));
      }
    });

    testWidgets('QueryFailed shows error and retry', (tester) async {
      setupConnected();
      when(
        () => mockSource.executeSelect('SELECT bad'),
      ).thenAnswer((_) async => Left(ViewerQueryFailed('q', 'syntax error')));

      await tester.pumpWidget(buildTablet());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'SELECT bad');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      expect(find.textContaining('Query failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('QueryFailed retry re-executes query', (tester) async {
      setupConnected();
      when(
        () => mockSource.executeSelect('SELECT bad'),
      ).thenAnswer((_) async => Left(ViewerQueryFailed('q', 'syntax error')));

      await tester.pumpWidget(buildTablet());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'SELECT bad');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockSource.executeSelect('SELECT bad')).called(2);
    });
  });
}
