// packages/sqlite_viewer/test/src/widgets/tablet_desktop_loading_states_test.dart
// Tests for tablet and desktop layout loading states to achieve 100% coverage.
// ignore_for_file: prefer_const_constructors

import 'dart:async';

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

  void setupFullyConnected() {
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

  void setupFullTableDetail() {
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

  Widget buildDesktop({double width = 1300, double height = 900}) {
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

  group('Tablet Layout Loading States', () {
    testWidgets('TableDetailLoading shows loading message', (tester) async {
      setupFullyConnected();
      // Pre-setup all table detail mocks
      when(
        () =>
            mockSource.getPragma(tableName: 'users', key: PragmaKey.tableInfo),
      ).thenAnswer(
        (_) async => Right([
          {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 1, 'pk': 1},
        ]),
      );
      when(
        () =>
            mockSource.getPragma(tableName: 'users', key: PragmaKey.indexList),
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

      await tester.pumpWidget(buildTablet());
      await tester.pumpAndSettle();

      // Slow down getColumnNames
      final completer = Completer<Either<SqliteViewerFailure, List<String>>>();
      when(
        () => mockSource.getColumnNames('users'),
      ).thenAnswer((_) => completer.future);

      await tester.tap(find.text('users'));
      await tester.pump();

      expect(find.text('Loading users...'), findsOneWidget);

      completer.complete(const Right(['id', 'name']));
      await tester.pumpAndSettle();
    });

    testWidgets('QueryExecuting shows executing message', (tester) async {
      setupFullyConnected();

      await tester.pumpWidget(buildTablet());
      await tester.pumpAndSettle();

      final completer =
          Completer<Either<SqliteViewerFailure, List<Map<String, Object?>>>>();
      when(
        () => mockSource.executeSelect('SELECT 1'),
      ).thenAnswer((_) => completer.future);

      await tester.enterText(find.byType(TextField).first, 'SELECT 1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      expect(find.text('Executing query...'), findsOneWidget);

      completer.complete(
        Right([
          {'1': 1},
        ]),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('table detail onRefresh triggers reload', (tester) async {
      setupFullyConnected();
      setupFullTableDetail();

      await tester.pumpWidget(buildTablet());
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
  });

  group('Desktop Layout Loading States', () {
    testWidgets('TableDetailLoading shows loading message', (tester) async {
      setupFullyConnected();
      when(
        () =>
            mockSource.getPragma(tableName: 'users', key: PragmaKey.tableInfo),
      ).thenAnswer(
        (_) async => Right([
          {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 1, 'pk': 1},
        ]),
      );
      when(
        () =>
            mockSource.getPragma(tableName: 'users', key: PragmaKey.indexList),
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

      await tester.pumpWidget(buildDesktop());
      await tester.pumpAndSettle();

      final completer = Completer<Either<SqliteViewerFailure, List<String>>>();
      when(
        () => mockSource.getColumnNames('users'),
      ).thenAnswer((_) => completer.future);

      await tester.tap(find.text('users'));
      await tester.pump();

      expect(find.text('Loading users...'), findsOneWidget);

      completer.complete(const Right(['id', 'name']));
      await tester.pumpAndSettle();
    });

    testWidgets('QueryExecuting shows executing message', (tester) async {
      setupFullyConnected();

      await tester.pumpWidget(buildDesktop());
      await tester.pumpAndSettle();

      final completer =
          Completer<Either<SqliteViewerFailure, List<Map<String, Object?>>>>();
      when(
        () => mockSource.executeSelect('SELECT 1'),
      ).thenAnswer((_) => completer.future);

      await tester.enterText(find.byType(TextField).first, 'SELECT 1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      expect(find.text('Executing query...'), findsOneWidget);

      completer.complete(
        Right([
          {'1': 1},
        ]),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('table detail onRefresh triggers reload', (tester) async {
      setupFullyConnected();
      setupFullTableDetail();

      await tester.pumpWidget(buildDesktop());
      await tester.pumpAndSettle();

      await tester.tap(find.text('users'));
      await tester.pumpAndSettle();

      final tableDetailRefresh = find.descendant(
        of: find.byType(SqliteViewerTableDetail),
        matching: find.byIcon(Icons.refresh),
      );

      expect(tableDetailRefresh, findsOneWidget);
      await tester.tap(tableDetailRefresh);
      await tester.pumpAndSettle();

      verify(() => mockSource.getColumnNames('users')).called(greaterThan(1));
    });
  });
}
