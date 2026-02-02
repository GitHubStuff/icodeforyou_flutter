// packages/sqlite_viewer/test/src/widgets/sqlite_viewer_page_test.dart
// ignore_for_file: prefer_const_constructors

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite_viewer/src/abstract/sqlite_viewer_abstract.dart';
import 'package:sqlite_viewer/src/failures/sqlite_viewer_failure.dart';
import 'package:sqlite_viewer/src/models/database_metadata.dart';
import 'package:sqlite_viewer/src/models/pragma_key.dart';
import 'package:sqlite_viewer/src/widgets/sqlite_viewer_page.dart';

class MockSqliteViewerAbstract extends Mock implements SqliteViewerAbstract {}

void main() {
  late MockSqliteViewerAbstract mockSource;

  const testMetadata = DatabaseMetadata(
    fullPath: '/test/path/database.db',
    sqliteVersion: '3.39.0',
    databaseSize: 4096,
    tables: ['users', 'posts'],
  );

  setUp(() {
    mockSource = MockSqliteViewerAbstract();
  });

  void setupSuccessfulMetadata() {
    when(() => mockSource.getFullPath())
        .thenAnswer((_) async => Right(testMetadata.fullPath));
    when(() => mockSource.getSqliteVersion())
        .thenAnswer((_) async => Right(testMetadata.sqliteVersion));
    when(() => mockSource.getDatabaseSize())
        .thenAnswer((_) async => Right(testMetadata.databaseSize));
    when(() => mockSource.getTableNames())
        .thenAnswer((_) async => Right(testMetadata.tables));
  }

  void setupFailedConnection() {
    when(() => mockSource.getFullPath())
        .thenAnswer((_) async => Left(ViewerDatabaseNotOpen()));
  }

  void setupSuccessfulTableDetail(String tableName) {
    when(() => mockSource.getColumnNames(tableName))
        .thenAnswer((_) async => Right(['id', 'name']));
    when(() => mockSource.getPragma(
          tableName: tableName,
          key: PragmaKey.tableInfo,
        )).thenAnswer((_) async => Right([
          {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 1, 'pk': 1},
          {'cid': 1, 'name': 'name', 'type': 'TEXT', 'notnull': 0, 'pk': 0},
        ]));
    when(() => mockSource.getPragma(
          tableName: tableName,
          key: PragmaKey.indexList,
        )).thenAnswer((_) async => Right(<Map<String, Object?>>[]));
    when(() => mockSource.getPragma(
          tableName: tableName,
          key: PragmaKey.foreignKeyList,
        )).thenAnswer((_) async => Right(<Map<String, Object?>>[]));
    when(() => mockSource.getRowCount(tableName))
        .thenAnswer((_) async => Right(2));
    when(() => mockSource.executeSelect('SELECT * FROM "$tableName"'))
        .thenAnswer((_) async => Right([
              {'id': 1, 'name': 'Alice'},
              {'id': 2, 'name': 'Bob'},
            ]));
  }

  Widget buildPage({
    bool showQueryInput = true,
    bool showRowNumbers = true,
    String nullValueDisplay = 'NULL',
    Size size = const Size(400, 800), // Phone size by default
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: SqliteViewerPage(
            source: mockSource,
            showQueryInput: showQueryInput,
            showRowNumbers: showRowNumbers,
            nullValueDisplay: nullValueDisplay,
          ),
        ),
      ),
    );
  }

  Widget buildPhonePage({
    bool showQueryInput = true,
    bool showRowNumbers = true,
    String nullValueDisplay = 'NULL',
  }) {
    return buildPage(
      showQueryInput: showQueryInput,
      showRowNumbers: showRowNumbers,
      nullValueDisplay: nullValueDisplay,
      size: const Size(400, 800),
    );
  }

  Widget buildTabletPage() {
    return buildPage(size: const Size(900, 700));
  }

  Widget wrapWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('Helper Widgets Direct Tests', () {
    group('_DisconnectedView', () {
      testWidgets('renders icon and message', (tester) async {
        await tester.pumpWidget(
          wrapWidget(buildDisconnectedViewForTesting()),
        );

        expect(find.byIcon(Icons.link_off), findsOneWidget);
        expect(find.text('Not connected'), findsOneWidget);
      });
    });

    group('_LoadingView', () {
      testWidgets('renders spinner and message', (tester) async {
        await tester.pumpWidget(
          wrapWidget(buildLoadingViewForTesting(message: 'Loading...')),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading...'), findsOneWidget);
      });
    });

    group('_ErrorView', () {
      testWidgets('renders error icon and message', (tester) async {
        await tester.pumpWidget(
          wrapWidget(buildErrorViewForTesting(message: 'An error occurred')),
        );

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('An error occurred'), findsOneWidget);
      });

      testWidgets('shows retry button when callback provided', (tester) async {
        var retryPressed = false;
        await tester.pumpWidget(
          wrapWidget(
            buildErrorViewForTesting(
              message: 'Error',
              onRetry: () => retryPressed = true,
            ),
          ),
        );

        expect(find.text('Retry'), findsOneWidget);
        await tester.tap(find.text('Retry'));
        expect(retryPressed, isTrue);
      });

      testWidgets('hides retry button when callback is null', (tester) async {
        await tester.pumpWidget(
          wrapWidget(buildErrorViewForTesting(message: 'Error')),
        );

        expect(find.text('Retry'), findsNothing);
      });
    });

    group('_EmptyDataView', () {
      testWidgets('renders touch icon and message', (tester) async {
        await tester.pumpWidget(
          wrapWidget(buildEmptyDataViewForTesting()),
        );

        expect(find.byIcon(Icons.touch_app), findsOneWidget);
        expect(find.text('Select a table to view data'), findsOneWidget);
      });
    });

    group('_SelectTablePrompt', () {
      testWidgets('renders prompt messages', (tester) async {
        await tester.pumpWidget(
          wrapWidget(buildSelectTablePromptForTesting()),
        );

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.text('Select a table from the sidebar'), findsOneWidget);
        expect(find.text('or enter a custom query below'), findsOneWidget);
      });
    });

    group('_QueryResultView', () {
      testWidgets('renders empty state when no rows', (tester) async {
        await tester.pumpWidget(
          wrapWidget(
            buildQueryResultViewForTesting(
              query: 'SELECT * FROM empty',
              columns: <String>[],
              rows: <Map<String, Object?>>[],
            ),
          ),
        );

        expect(find.byIcon(Icons.search_off), findsOneWidget);
        expect(find.text('Query returned no results'), findsOneWidget);
      });

      testWidgets('renders query header and row count with data',
          (tester) async {
        await tester.pumpWidget(
          wrapWidget(
            SizedBox(
              width: 800,
              height: 600,
              child: buildQueryResultViewForTesting(
                query: 'SELECT * FROM users',
                columns: ['id', 'name'],
                rows: [
                  {'id': 1, 'name': 'Alice'},
                  {'id': 2, 'name': 'Bob'},
                ],
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.code), findsOneWidget);
        expect(find.text('SELECT * FROM users'), findsOneWidget);
        expect(find.text('2 rows'), findsOneWidget);
      });
    });
  });

  group('Phone Layout (_PhoneLayout)', () {
    group('Initial states', () {
      testWidgets('shows connecting state', (tester) async {
        when(() => mockSource.getFullPath()).thenAnswer(
          (_) => Future.delayed(Duration(seconds: 30), () => Right('/path')),
        );

        await tester.pumpWidget(buildPhonePage());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Connecting...'), findsOneWidget);
      });

      testWidgets('shows connection error', (tester) async {
        setupFailedConnection();

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Database is not open'), findsOneWidget);
      });
    });

    group('Navigation bar', () {
      testWidgets('shows all tabs when showQueryInput is true', (tester) async {
        setupSuccessfulMetadata();

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.text('Tables'), findsOneWidget);
        expect(find.text('Data'), findsOneWidget);
        expect(find.text('Query'), findsOneWidget);
      });

      testWidgets('hides Query tab when showQueryInput is false',
          (tester) async {
        setupSuccessfulMetadata();

        await tester.pumpWidget(buildPhonePage(showQueryInput: false));
        await tester.pumpAndSettle();

        expect(find.text('Tables'), findsOneWidget);
        expect(find.text('Data'), findsOneWidget);
        expect(find.text('Query'), findsNothing);
      });

      testWidgets('navigates between tabs', (tester) async {
        setupSuccessfulMetadata();

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        // Initially on Tables tab - shows table list
        expect(find.text('users'), findsOneWidget);

        // Navigate to Data tab
        await tester.tap(find.text('Data'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.touch_app), findsOneWidget);

        // Navigate to Query tab
        await tester.tap(find.text('Query'));
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOneWidget);

        // Navigate back to Tables
        await tester.tap(find.text('Tables'));
        await tester.pumpAndSettle();
        expect(find.text('users'), findsOneWidget);
      });
    });

    group('Tables tab', () {
      testWidgets('shows metadata panel with tables', (tester) async {
        setupSuccessfulMetadata();

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        expect(find.text('users'), findsOneWidget);
        expect(find.text('posts'), findsOneWidget);
      });

      testWidgets('selecting table navigates to Data tab and loads',
          (tester) async {
        setupSuccessfulMetadata();
        setupSuccessfulTableDetail('users');

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('users'));
        await tester.pumpAndSettle();

        // Should have navigated to Data tab and show table
        expect(find.text('users'), findsWidgets);
      });

      testWidgets('shows loading state when table selected', (tester) async {
        setupSuccessfulMetadata();
        when(() => mockSource.getColumnNames('users')).thenAnswer(
          (_) => Future.delayed(Duration(seconds: 30), () => Right(['id'])),
        );

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('users'));
        await tester.pump();

        expect(find.text('Loading users...'), findsOneWidget);
      });

      testWidgets('shows selected table when TableDetailLoaded', (tester) async {
        setupSuccessfulMetadata();
        setupSuccessfulTableDetail('users');

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('users'));
        await tester.pumpAndSettle();

        // Go back to Tables to verify selection
        await tester.tap(find.text('Tables'));
        await tester.pumpAndSettle();

        expect(find.text('users'), findsWidgets);
      });

      testWidgets('shows selected table when TableDetailLoadFailed',
          (tester) async {
        setupSuccessfulMetadata();
        when(() => mockSource.getColumnNames('users'))
            .thenAnswer((_) async => Left(ViewerTableNotFound('users')));

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('users'));
        await tester.pumpAndSettle();

        // Go back to Tables
        await tester.tap(find.text('Tables'));
        await tester.pumpAndSettle();

        expect(find.text('users'), findsWidgets);
      });

      testWidgets('metadata panel refresh triggers refreshMetadata',
          (tester) async {
        setupSuccessfulMetadata();

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        // Tap app bar refresh
        await tester.tap(find.byIcon(Icons.refresh).first);
        await tester.pump();

        verify(() => mockSource.getFullPath()).called(greaterThan(1));
      });

      testWidgets('shows loading indicator in MetadataLoading state',
          (tester) async {
        setupSuccessfulMetadata();

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        // Setup slow refresh
        when(() => mockSource.getFullPath()).thenAnswer(
          (_) => Future.delayed(Duration(seconds: 30), () => Right('/path')),
        );

        await tester.tap(find.byIcon(Icons.refresh).first);
        await tester.pump();

        expect(find.text('Refreshing...'), findsOneWidget);
      });
    });

    group('Data tab', () {
      testWidgets('shows EmptyDataView when no table selected', (tester) async {
        setupSuccessfulMetadata();

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Data'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.touch_app), findsOneWidget);
        expect(find.text('Select a table to view data'), findsOneWidget);
      });

      testWidgets('shows loading when TableDetailLoading', (tester) async {
        setupSuccessfulMetadata();
        when(() => mockSource.getColumnNames('users')).thenAnswer(
          (_) => Future.delayed(Duration(seconds: 30), () => Right(['id'])),
        );

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('users'));
        await tester.pump();

        expect(find.text('Loading users...'), findsOneWidget);
      });

      testWidgets('shows table detail when TableDetailLoaded', (tester) async {
        setupSuccessfulMetadata();
        setupSuccessfulTableDetail('users');

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('users'));
        await tester.pumpAndSettle();

        expect(find.text('users'), findsWidgets);
      });

      testWidgets('shows error when TableDetailLoadFailed with retry',
          (tester) async {
        setupSuccessfulMetadata();
        when(() => mockSource.getColumnNames('users'))
            .thenAnswer((_) async => Left(ViewerTableNotFound('users')));

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('users'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.textContaining('Failed to load users'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('retry on TableDetailLoadFailed reloads table',
          (tester) async {
        setupSuccessfulMetadata();
        when(() => mockSource.getColumnNames('users'))
            .thenAnswer((_) async => Left(ViewerTableNotFound('users')));

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('users'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Retry'));
        await tester.pump();

        verify(() => mockSource.getColumnNames('users')).called(2);
      });

      testWidgets('shows QueryResultView when QueryResultLoaded',
          (tester) async {
        setupSuccessfulMetadata();
        when(() => mockSource.executeSelect('SELECT 1'))
            .thenAnswer((_) async => Right([
                  {'1': 1}
                ]));

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Query'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'SELECT 1');
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.play_arrow).first);
        await tester.pumpAndSettle();

        expect(find.text('SELECT 1'), findsWidgets);
        expect(find.text('1 rows'), findsOneWidget);
      });

      testWidgets('shows error when QueryFailed with retry', (tester) async {
        setupSuccessfulMetadata();
        when(() => mockSource.executeSelect('SELECT bad'))
            .thenAnswer((_) async => Left(ViewerQueryFailed('q', 'error')));

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Query'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'SELECT bad');
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.play_arrow).first);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.textContaining('Query failed'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('retry on QueryFailed re-executes query', (tester) async {
        setupSuccessfulMetadata();
        when(() => mockSource.executeSelect('SELECT bad'))
            .thenAnswer((_) async => Left(ViewerQueryFailed('q', 'error')));

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Query'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'SELECT bad');
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.play_arrow).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Retry'));
        await tester.pump();

        verify(() => mockSource.executeSelect('SELECT bad')).called(2);
      });
    });

    group('Query tab', () {
      testWidgets('shows query input', (tester) async {
        setupSuccessfulMetadata();

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Query'));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });

      testWidgets('shows executing state during query', (tester) async {
        setupSuccessfulMetadata();
        when(() => mockSource.executeSelect(any())).thenAnswer(
          (_) => Future.delayed(
            Duration(seconds: 30),
            () => Right(<Map<String, Object?>>[]),
          ),
        );

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Query'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'SELECT 1');
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.play_arrow).first);
        await tester.pump();

        expect(find.text('Executing query...'), findsOneWidget);
      });

      testWidgets('shows results after query execution', (tester) async {
        setupSuccessfulMetadata();
        when(() => mockSource.executeSelect('SELECT 1'))
            .thenAnswer((_) async => Right([
                  {'1': 1}
                ]));

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Query'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'SELECT 1');
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.play_arrow).first);
        await tester.pumpAndSettle();

        expect(find.text('SELECT 1'), findsWidgets);
      });

      testWidgets('shows last query from QueryFailed', (tester) async {
        setupSuccessfulMetadata();
        when(() => mockSource.executeSelect('SELECT bad'))
            .thenAnswer((_) async => Left(ViewerQueryFailed('q', 'error')));

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Query'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'SELECT bad');
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.play_arrow).first);
        await tester.pumpAndSettle();

        expect(find.textContaining('Query failed'), findsOneWidget);
      });
    });

    group('App bar refresh button', () {
      testWidgets('shows refresh when MetadataLoaded', (tester) async {
        setupSuccessfulMetadata();

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.refresh), findsWidgets);
      });

      testWidgets('shows refresh when TableDetailLoaded', (tester) async {
        setupSuccessfulMetadata();
        setupSuccessfulTableDetail('users');

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('users'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.refresh), findsWidgets);
      });

      testWidgets('shows refresh when QueryResultLoaded', (tester) async {
        setupSuccessfulMetadata();
        when(() => mockSource.executeSelect('SELECT 1'))
            .thenAnswer((_) async => Right([
                  {'1': 1}
                ]));

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Query'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'SELECT 1');
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.play_arrow).first);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.refresh), findsWidgets);
      });

      testWidgets('refresh button triggers metadata refresh', (tester) async {
        setupSuccessfulMetadata();

        await tester.pumpWidget(buildPhonePage());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.refresh).first);
        await tester.pump();

        verify(() => mockSource.getFullPath()).called(greaterThan(1));
      });
    });
  });

  group('Tablet Layout (_TabletLayout)', () {
    testWidgets('shows sidebar and main content', (tester) async {
      setupSuccessfulMetadata();

      await tester.pumpWidget(buildTabletPage());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('users'), findsOneWidget);
      expect(find.text('posts'), findsOneWidget);
      expect(find.text('Select a table from the sidebar'), findsOneWidget);
    });

    testWidgets('shows query input area', (tester) async {
      setupSuccessfulMetadata();

      await tester.pumpWidget(buildTabletPage());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('selecting table shows detail', (tester) async {
      setupSuccessfulMetadata();
      setupSuccessfulTableDetail('users');

      await tester.pumpWidget(buildTabletPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('users'));
      await tester.pumpAndSettle();

      expect(find.text('users'), findsWidgets);
    });

    testWidgets('executing query shows results', (tester) async {
      setupSuccessfulMetadata();
      when(() => mockSource.executeSelect('SELECT 1'))
          .thenAnswer((_) async => Right([
                {'1': 1}
              ]));

      await tester.pumpWidget(buildTabletPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'SELECT 1');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.play_arrow).first);
      await tester.pumpAndSettle();

      expect(find.text('SELECT 1'), findsWidgets);
      expect(find.text('1 rows'), findsOneWidget);
    });
  });
}
