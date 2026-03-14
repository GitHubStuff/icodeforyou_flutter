// packages/sqlite_viewer/test/src/widgets/sqlite_viewer_page_for_widgetbook_test.dart

// ignore_for_file: document_ignores, prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_cubit.dart';
import 'package:sqlite_viewer/src/cubit/sqlite_viewer_state.dart';
import 'package:sqlite_viewer/src/models/database_metadata.dart';
import 'package:sqlite_viewer/src/models/text_handling.dart';
import 'package:sqlite_viewer/src/widgets/sqlite_viewer_page.dart';

import '../../helpers/mock_sqlite_viewer_source.dart' show MockSqliteViewerSource;


void main() {
  const testMetadata = DatabaseMetadata(
    fullPath: '/test/path/database.db',
    sqliteVersion: '3.39.0',
    databaseSize: 4096,
    tables: ['users', 'posts'],
  );

  group('SqliteViewerPage.forWidgetbook', () {
    testWidgets('uses provided cubit without calling connect', (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final source = MockSqliteViewerSource();
      final cubit = SqliteViewerCubit.withState(
        source,
        MetadataLoaded(metadata: testMetadata),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 900,
            height: 700,
            child: SqliteViewerPage.forWidgetbook(
              source: source,
              cubit: cubit,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('users'), findsOneWidget);
      expect(find.text('posts'), findsOneWidget);

      unawaited(cubit.close());
    });

    testWidgets('forwards all optional parameters', (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final source = MockSqliteViewerSource();
      final cubit = SqliteViewerCubit.withState(
        source,
        MetadataLoaded(metadata: testMetadata),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 900,
            height: 700,
            child: SqliteViewerPage.forWidgetbook(
              source: source,
              cubit: cubit,
              title: 'My Viewer',
              showQueryInput: false,
              sidebarWidth: 320,
              showRowNumbers: false,
              nullValueDisplay: '—',
              textHandling: TextHandling.wrap,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Viewer'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      unawaited(cubit.close());
    });
  });
}
