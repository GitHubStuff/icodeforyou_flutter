// packages/sqlite_viewer/test/src/widgets/phone_layout_loading_states_test.dart
// Tests for loading/intermediate states to achieve 100% coverage.
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

class MockSource extends Mock implements SqliteViewerAbstract {}

void main() {
  late MockSource mockSource;

  setUp(() {
    mockSource = MockSource();
  });

  /// Full mock setup for connected state - all methods return immediately
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

  /// Full mock setup for table detail - all methods return immediately

  Widget buildPhone({double width = 500, double height = 800}) {
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

  group('Phone Layout Loading States', () {
    testWidgets('MetadataLoading shows tables during refresh', (tester) async {
      // First, fully connect
      setupFullyConnected();

      await tester.pumpWidget(buildPhone());
      await tester.pumpAndSettle();

      // Verify we're connected
      expect(find.text('users'), findsWidgets);

      // Now set up a slow refresh - use Completer for getTableNames
      final completer = Completer<Either<SqliteViewerFailure, List<String>>>();
      when(
        () => mockSource.getTableNames(),
      ).thenAnswer((_) => completer.future);

      // Trigger refresh via metadata panel (tooltip is 'Refresh metadata')
      final refreshButton = find.byTooltip('Refresh metadata');
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pump();

      // Should still show tables (MetadataLoading with cached metadata)
      expect(find.text('users'), findsWidgets);

      // Complete to clean up
      completer.complete(const Right(['users']));
      await tester.pumpAndSettle();
    });

    testWidgets('TableDetailLoading shows loading message', (tester) async {
      // Fully connect first
      setupFullyConnected();
      // Pre-setup table detail mocks (except getColumnNames)
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

      await tester.pumpWidget(buildPhone());
      await tester.pumpAndSettle();

      // Set up slow table load - Completer for getColumnNames
      final completer = Completer<Either<SqliteViewerFailure, List<String>>>();
      when(
        () => mockSource.getColumnNames('users'),
      ).thenAnswer((_) => completer.future);

      // Tap table to trigger load
      await tester.tap(find.text('users').first);
      await tester.pump();

      // Should show loading message
      expect(find.text('Loading users...'), findsOneWidget);

      // Complete to clean up
      completer.complete(const Right(['id', 'name']));
      await tester.pumpAndSettle();
    });

    testWidgets('QueryExecuting shows loading state in query input', (
      tester,
    ) async {
      // Fully connect
      setupFullyConnected();

      await tester.pumpWidget(buildPhone());
      await tester.pumpAndSettle();

      // Navigate to Query tab
      await tester.tap(find.text('Query').last);
      await tester.pumpAndSettle();

      // Set up slow query - Completer for executeSelect
      final completer =
          Completer<Either<SqliteViewerFailure, List<Map<String, Object?>>>>();
      when(
        () => mockSource.executeSelect('SELECT 1'),
      ).thenAnswer((_) => completer.future);

      // Enter and execute query
      await tester.enterText(find.byType(TextField).first, 'SELECT 1');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Phone layout shows "Running..." in query input during execution
      // (not "Executing query..." which is tablet only)
      expect(find.text('Running...'), findsOneWidget);

      // Complete to clean up
      completer.complete(
        Right([
          {'1': 1},
        ]),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('metadata panel onRefresh triggers refreshMetadata', (
      tester,
    ) async {
      setupFullyConnected();

      await tester.pumpWidget(buildPhone());
      await tester.pumpAndSettle();

      // Find metadata panel refresh button (tooltip is 'Refresh metadata')
      final refreshButton = find.byTooltip('Refresh metadata');
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      // Verify refresh was called (getFullPath called again)
      verify(() => mockSource.getFullPath()).called(greaterThan(1));
    });
  });
}
