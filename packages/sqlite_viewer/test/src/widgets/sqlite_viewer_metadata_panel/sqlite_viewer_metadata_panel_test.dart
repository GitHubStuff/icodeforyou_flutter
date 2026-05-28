// test/src/widgets/sqlite_viewer_metadata_panel/sqlite_viewer_metadata_panel_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  Widget wrap(Widget child) {
    return testableWidgetWithScaffold(
      SizedBox(width: 320, height: 600, child: child),
    );
  }

  group('SqliteViewerMetadataPanel header', () {
    testWidgets('shows storage icon for file-based DB', (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: testMetadata)),
      );
      expect(find.byIcon(Icons.storage), findsOneWidget);
      expect(find.byIcon(Icons.memory), findsNothing);
    });

    testWidgets('shows memory icon for in-memory DB', (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: inMemoryMetadata)),
      );
      expect(find.byIcon(Icons.memory), findsOneWidget);
      expect(find.byIcon(Icons.storage), findsNothing);
    });

    testWidgets('renders filename in header', (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: testMetadata)),
      );
      expect(find.text('test.db'), findsOneWidget);
    });

    testWidgets('renders ":memory:" filename for in-memory DB',
        (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: inMemoryMetadata)),
      );
      expect(find.text(':memory:'), findsOneWidget);
    });

    testWidgets('hides refresh button when onRefresh is null', (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: testMetadata)),
      );
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('shows refresh button when onRefresh provided', (tester) async {
      await tester.pumpWidget(
        wrap(
          SqliteViewerMetadataPanel(
            metadata: testMetadata,
            onRefresh: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('tapping refresh button invokes onRefresh callback',
        (tester) async {
      var refreshed = 0;
      await tester.pumpWidget(
        wrap(
          SqliteViewerMetadataPanel(
            metadata: testMetadata,
            onRefresh: () => refreshed++,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(refreshed, 1);
    });

    testWidgets('shows CircularProgressIndicator instead of refresh icon '
        'when isLoading', (tester) async {
      await tester.pumpWidget(
        wrap(
          SqliteViewerMetadataPanel(
            metadata: testMetadata,
            onRefresh: () {},
            isLoading: true,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('disables refresh button when isLoading', (tester) async {
      var refreshed = 0;
      await tester.pumpWidget(
        wrap(
          SqliteViewerMetadataPanel(
            metadata: testMetadata,
            onRefresh: () => refreshed++,
            isLoading: true,
          ),
        ),
      );

      // IconButton is disabled (onPressed null), so tapping does nothing.
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);
      expect(refreshed, 0);
    });
  });

  group('SqliteViewerMetadataPanel database info', () {
    testWidgets('renders Path label and full path for file db',
        (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: testMetadata)),
      );
      expect(find.text('Path'), findsOneWidget);
      expect(find.text('/path/test.db'), findsOneWidget);
    });

    testWidgets('renders "In-memory database" for in-memory db',
        (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: inMemoryMetadata)),
      );
      expect(find.text('In-memory database'), findsOneWidget);
    });

    testWidgets('renders SQLite version', (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: testMetadata)),
      );
      expect(find.text('SQLite'), findsOneWidget);
      expect(find.text('3.39.0'), findsOneWidget);
    });

    testWidgets('renders formatted database size', (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: testMetadata)),
      );
      expect(find.text('Size'), findsOneWidget);
      expect(find.text('1.00 KB'), findsOneWidget);
    });
  });

  group('SqliteViewerMetadataPanel tables section', () {
    testWidgets('renders Tables heading with count', (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: testMetadata)),
      );
      expect(find.text('Tables'), findsOneWidget);
      // testMetadata has 2 tables
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders table list items', (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: testMetadata)),
      );
      expect(find.text('users'), findsOneWidget);
      expect(find.text('posts'), findsOneWidget);
    });

    testWidgets('renders "No tables found" when tables empty', (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: emptyMetadata)),
      );
      expect(find.text('No tables found'), findsOneWidget);
    });

    testWidgets('highlights selected table and shows chevron', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SqliteViewerMetadataPanel(
            metadata: testMetadata,
            selectedTable: 'users',
          ),
        ),
      );
      expect(find.text('users'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('no chevron when nothing selected', (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: testMetadata)),
      );
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('tapping a table item invokes onTableSelected', (tester) async {
      String? selected;
      await tester.pumpWidget(
        wrap(
          SqliteViewerMetadataPanel(
            metadata: testMetadata,
            onTableSelected: (name) => selected = name,
          ),
        ),
      );

      await tester.tap(find.text('users'));
      await tester.pump();
      expect(selected, 'users');
    });

    testWidgets('table item is non-tappable when onTableSelected is null',
        (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: testMetadata)),
      );
      final inkwells = tester.widgetList<InkWell>(find.byType(InkWell));
      // Every InkWell rendered for tables should have onTap == null.
      expect(inkwells.every((w) => w.onTap == null), isTrue);
    });
  });

  group('SqliteViewerMetadataPanel custom styling', () {
    testWidgets('uses custom header/label/value/tableItem styles',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const SqliteViewerMetadataPanel(
            metadata: testMetadata,
            headerStyle: TextStyle(fontSize: 20, color: Colors.purple),
            labelStyle: TextStyle(fontSize: 10, color: Colors.green),
            valueStyle: TextStyle(fontSize: 12, color: Colors.orange),
            tableItemStyle: TextStyle(fontSize: 13, color: Colors.brown),
            selectedTableColor: Colors.yellow,
            backgroundColor: Colors.pink,
            dividerColor: Colors.cyan,
            selectedTable: 'users',
          ),
        ),
      );
      expect(find.text('users'), findsOneWidget);
    });
  });
}
