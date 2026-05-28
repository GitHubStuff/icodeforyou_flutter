// test/src/widgets/sqlite_viewer_page/sqlite_viewer_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  Future<void> pumpAt(
    WidgetTester tester,
    Widget child, {
    required double width,
  }) async {
    tester.view
      ..physicalSize = Size(width * 2, 800 * 2)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(home: child));
    await tester.pump();
  }

  group('SqliteViewerPage constructors', () {
    testWidgets('default constructor creates its own cubit and calls connect',
        (tester) async {
      final source = createTestMockSource();
      await pumpAt(
        tester,
        SqliteViewerPage(source: source),
        width: 900,
      );
      // Connect dispatch returns the MetadataLoaded state — sidebar renders.
      await tester.pumpAndSettle();
      expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
    });

    testWidgets('withCubit constructor reuses provided cubit',
        (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpAt(
        tester,
        SqliteViewerPage.withCubit(source: source, cubit: cubit),
        width: 900,
      );
      expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      await cubit.close();
    });

    testWidgets('forWidgetbook constructor reuses provided cubit',
        (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpAt(
        tester,
        SqliteViewerPage.forWidgetbook(source: source, cubit: cubit),
        width: 900,
      );
      expect(find.byType(SqliteViewerMetadataPanel), findsOneWidget);
      await cubit.close();
    });
  });

  group('SqliteViewerPage responsive layout dispatch', () {
    testWidgets('width < 600 selects PhoneLayout', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpAt(
        tester,
        SqliteViewerPage.withCubit(source: source, cubit: cubit),
        width: 375,
      );
      // Phone layout uses NavigationBar with bottom tabs labeled "Tables"
      expect(find.byType(NavigationBar), findsOneWidget);
      await cubit.close();
    });

    testWidgets('600 ≤ width < 1200 selects tablet layout', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpAt(
        tester,
        SqliteViewerPage.withCubit(source: source, cubit: cubit),
        width: 800,
      );
      // Tablet does not show NavigationBar
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(VerticalDivider), findsOneWidget);
      await cubit.close();
    });

    testWidgets('width ≥ 1200 selects desktop layout', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpAt(
        tester,
        SqliteViewerPage.withCubit(source: source, cubit: cubit),
        width: 1400,
      );
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(VerticalDivider), findsOneWidget);
      await cubit.close();
    });
  });

  group('SqliteViewerPage app bar title', () {
    testWidgets('default title is "SQLite Viewer"', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpAt(
        tester,
        SqliteViewerPage.withCubit(source: source, cubit: cubit),
        width: 900,
      );
      expect(find.text('SQLite Viewer'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('custom title is honored', (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const MetadataLoaded(metadata: testMetadata),
      );
      await pumpAt(
        tester,
        SqliteViewerPage.withCubit(
          source: source,
          cubit: cubit,
          title: 'My Viewer',
        ),
        width: 900,
      );
      expect(find.text('My Viewer'), findsOneWidget);
      await cubit.close();
    });
  });

  group('SqliteViewerPage configuration pass-through', () {
    testWidgets('passes showRowNumbers/nullValueDisplay/textHandling down',
        (tester) async {
      final source = createTestMockSource();
      final cubit = SqliteViewerCubit.seeded(
        source,
        const TableDetailLoaded(
          metadata: testMetadata,
          tableName: 'users',
          columns: ['id', 'name'],
          tableInfo: [],
          indexList: [],
          foreignKeys: [],
          rows: [
            {'id': 1, 'name': null},
          ],
          rowCount: 1,
        ),
      );
      await pumpAt(
        tester,
        SqliteViewerPage.withCubit(
          source: source,
          cubit: cubit,
          showRowNumbers: true,
          nullValueDisplay: '<empty>',
          textHandling: TextHandling.wrap,
          sidebarWidth: 240,
        ),
        width: 900,
      );
      expect(find.text('<empty>'), findsAtLeastNWidgets(1));
      expect(find.text('#'), findsOneWidget);
      await cubit.close();
    });
  });
}
