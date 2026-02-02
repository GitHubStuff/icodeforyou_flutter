// packages/sqlite_viewer/test/src/widgets/desktop_layout_test.dart
// Tests for desktop layout (width >= 1200) to achieve 100% coverage.
// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  void setupFullyConnected() {
    when(() => mockSource.getFullPath())
        .thenAnswer((_) async => const Right('/test.db'));
    when(() => mockSource.getSqliteVersion())
        .thenAnswer((_) async => const Right('3.39.0'));
    when(() => mockSource.getDatabaseSize())
        .thenAnswer((_) async => const Right(4096));
    when(() => mockSource.getTableNames())
        .thenAnswer((_) async => const Right(['users']));
  }

  void setupFullTableDetail() {
    when(() => mockSource.getColumnNames('users'))
        .thenAnswer((_) async => const Right(['id', 'name']));
    when(() => mockSource.getPragma(tableName: 'users', key: PragmaKey.tableInfo))
        .thenAnswer((_) async => Right([
              {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 1, 'pk': 1},
            ]));
    when(() => mockSource.getPragma(tableName: 'users', key: PragmaKey.indexList))
        .thenAnswer((_) async => const Right(<Map<String, Object?>>[]));
    when(() => mockSource.getPragma(
            tableName: 'users', key: PragmaKey.foreignKeyList))
        .thenAnswer((_) async => const Right(<Map<String, Object?>>[]));
    when(() => mockSource.getRowCount('users'))
        .thenAnswer((_) async => const Right(1));
    when(() => mockSource.executeSelect('SELECT * FROM "users"'))
        .thenAnswer((_) async => Right([
              {'id': 1, 'name': 'Test'}
            ]));
  }

  group('Desktop Layout Coverage (_DesktopLayout)', () {
    // Desktop layout requires width >= 1200
    // Must set tester.view.physicalSize to make LayoutBuilder receive large constraints

    testWidgets('renders desktop layout with proper view size', (tester) async {
      // Set the physical size large enough for desktop
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      setupFullyConnected();

      await tester.pumpWidget(
        MaterialApp(
          home: SqliteViewerPage(source: mockSource),
        ),
      );
      await tester.pumpAndSettle();

      // Desktop layout has NO NavigationBar (uses _TabletLayout internally)
      expect(find.byType(NavigationBar), findsNothing);
      // Has sidebar with tables
      expect(find.text('users'), findsOneWidget);
    });

    testWidgets('desktop table selection works', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      setupFullyConnected();
      setupFullTableDetail();

      await tester.pumpWidget(
        MaterialApp(
          home: SqliteViewerPage(source: mockSource),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('users'));
      await tester.pumpAndSettle();

      expect(find.byType(SqliteViewerTableDetail), findsOneWidget);
    });

    testWidgets('desktop query execution works', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      setupFullyConnected();
      when(() => mockSource.executeSelect('SELECT 1'))
          .thenAnswer((_) async => Right([
                {'1': 1}
              ]));

      await tester.pumpWidget(
        MaterialApp(
          home: SqliteViewerPage(source: mockSource),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'SELECT 1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      expect(find.text('1 rows'), findsOneWidget);
    });

    testWidgets('desktop QueryFailed with retry', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      setupFullyConnected();
      when(() => mockSource.executeSelect('SELECT bad'))
          .thenAnswer((_) async => Left(ViewerQueryFailed('q', 'error')));

      await tester.pumpWidget(
        MaterialApp(
          home: SqliteViewerPage(source: mockSource),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'SELECT bad');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      expect(find.textContaining('Query failed'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockSource.executeSelect('SELECT bad')).called(2);
    });

    testWidgets('desktop table detail refresh', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      setupFullyConnected();
      setupFullTableDetail();

      await tester.pumpWidget(
        MaterialApp(
          home: SqliteViewerPage(source: mockSource),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('users'));
      await tester.pumpAndSettle();

      // Find refresh in SqliteViewerTableDetail
      final tableDetailRefresh = find.descendant(
        of: find.byType(SqliteViewerTableDetail),
        matching: find.byIcon(Icons.refresh),
      );

      expect(tableDetailRefresh, findsOneWidget);
      await tester.tap(tableDetailRefresh);
      await tester.pumpAndSettle();

      verify(() => mockSource.getColumnNames('users')).called(greaterThan(1));
    });

    testWidgets('desktop TableDetailLoading shows loading', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      setupFullyConnected();
      // Pre-setup all table detail mocks
      when(() => mockSource.getPragma(tableName: 'users', key: PragmaKey.tableInfo))
          .thenAnswer((_) async => Right([
                {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 1, 'pk': 1},
              ]));
      when(() => mockSource.getPragma(tableName: 'users', key: PragmaKey.indexList))
          .thenAnswer((_) async => const Right(<Map<String, Object?>>[]));
      when(() => mockSource.getPragma(
              tableName: 'users', key: PragmaKey.foreignKeyList))
          .thenAnswer((_) async => const Right(<Map<String, Object?>>[]));
      when(() => mockSource.getRowCount('users'))
          .thenAnswer((_) async => const Right(1));
      when(() => mockSource.executeSelect('SELECT * FROM "users"'))
          .thenAnswer((_) async => Right([
                {'id': 1, 'name': 'Test'}
              ]));

      await tester.pumpWidget(
        MaterialApp(
          home: SqliteViewerPage(source: mockSource),
        ),
      );
      await tester.pumpAndSettle();

      // Use Completer to stay in loading state
      final completer = Completer<Either<SqliteViewerFailure, List<String>>>();
      when(() => mockSource.getColumnNames('users'))
          .thenAnswer((_) => completer.future);

      await tester.tap(find.text('users'));
      await tester.pump();

      expect(find.text('Loading users...'), findsOneWidget);

      completer.complete(const Right(['id', 'name']));
      await tester.pumpAndSettle();
    });

    testWidgets('desktop QueryExecuting shows executing', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      setupFullyConnected();

      await tester.pumpWidget(
        MaterialApp(
          home: SqliteViewerPage(source: mockSource),
        ),
      );
      await tester.pumpAndSettle();

      final completer =
          Completer<Either<SqliteViewerFailure, List<Map<String, Object?>>>>();
      when(() => mockSource.executeSelect('SELECT 1'))
          .thenAnswer((_) => completer.future);

      await tester.enterText(find.byType(TextField).first, 'SELECT 1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      expect(find.text('Executing query...'), findsOneWidget);

      completer.complete(Right([{'1': 1}]));
      await tester.pumpAndSettle();
    });
  });
}
