// test/src/widgets/sqlite_viewer_table_detail/sqlite_viewer_table_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  Widget wrap(Widget child) {
    return testableWidgetWithScaffold(
      SizedBox(width: 800, height: 600, child: child),
    );
  }

  SqliteViewerTableDetail buildDetail({
    String tableName = 'users',
    List<String> columns = const ['id', 'name', 'email'],
    List<Map<String, Object?>> tableInfo = testTableInfo,
    List<Map<String, Object?>> indexList = testIndexList,
    List<Map<String, Object?>> foreignKeys = testForeignKeys,
    List<Map<String, Object?>> rows = testRows,
    int rowCount = 3,
    VoidCallback? onRefresh,
    bool isLoading = false,
    bool showRowNumbers = true,
    TextStyle? headerStyle,
    TextStyle? evenRowStyle,
    TextStyle? oddRowStyle,
    Color? evenRowColor,
    Color? oddRowColor,
    Color? headerBackgroundColor,
    String nullValueDisplay = 'NULL',
    TextHandling textHandling = TextHandling.trunc,
  }) {
    return SqliteViewerTableDetail(
      tableName: tableName,
      columns: columns,
      tableInfo: tableInfo,
      indexList: indexList,
      foreignKeys: foreignKeys,
      rows: rows,
      rowCount: rowCount,
      onRefresh: onRefresh,
      isLoading: isLoading,
      showRowNumbers: showRowNumbers,
      headerStyle: headerStyle,
      evenRowStyle: evenRowStyle,
      oddRowStyle: oddRowStyle,
      evenRowColor: evenRowColor,
      oddRowColor: oddRowColor,
      headerBackgroundColor: headerBackgroundColor,
      nullValueDisplay: nullValueDisplay,
      textHandling: textHandling,
    );
  }

  group('SqliteViewerTableDetail header', () {
    testWidgets('renders table_chart icon and table name', (tester) async {
      await tester.pumpWidget(wrap(buildDetail()));
      expect(find.byIcon(Icons.table_chart), findsOneWidget);
      expect(find.text('users'), findsOneWidget);
    });

    testWidgets('shows column-and-row summary line', (tester) async {
      await tester.pumpWidget(wrap(buildDetail(rowCount: 42)));
      expect(find.text('3 columns • 42 rows'), findsOneWidget);
    });

    testWidgets('hides refresh icon when onRefresh is null', (tester) async {
      await tester.pumpWidget(wrap(buildDetail()));
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('shows refresh icon when onRefresh is provided',
        (tester) async {
      await tester.pumpWidget(wrap(buildDetail(onRefresh: () {})));
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('tapping refresh invokes callback', (tester) async {
      var refreshed = 0;
      await tester.pumpWidget(
        wrap(buildDetail(onRefresh: () => refreshed++)),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(refreshed, 1);
    });

    testWidgets('shows progress spinner when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        wrap(buildDetail(onRefresh: () {}, isLoading: true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('disables refresh button when isLoading', (tester) async {
      var refreshed = 0;
      await tester.pumpWidget(
        wrap(
          buildDetail(
            onRefresh: () => refreshed++,
            isLoading: true,
          ),
        ),
      );
      // The IconButton with the spinner has onPressed = null.
      final button = tester.widget<IconButton>(find.byType(IconButton));
      expect(button.onPressed, isNull);
      expect(refreshed, 0);
    });
  });

  group('SqliteViewerTableDetail tabs', () {
    testWidgets('renders Data and Schema tab labels with counts',
        (tester) async {
      await tester.pumpWidget(wrap(buildDetail(rowCount: 100)));
      expect(find.text('Data (100)'), findsOneWidget);
      // testTableInfo has 3 entries
      expect(find.text('Schema (3)'), findsOneWidget);
    });

    testWidgets('switches to Schema tab on tap', (tester) async {
      await tester.pumpWidget(wrap(buildDetail()));
      await tester.tap(find.text('Schema (3)'));
      await tester.pumpAndSettle();
      // Schema view shows Columns/Indexes/Foreign Keys section headers
      expect(find.text('Columns'), findsOneWidget);
      expect(find.text('Indexes'), findsOneWidget);
      expect(find.text('Foreign Keys'), findsOneWidget);
    });
  });

  group('SqliteViewerTableDetail data tab', () {
    testWidgets('renders DisplayQueryWidget when rows present', (tester) async {
      await tester.pumpWidget(wrap(buildDetail()));
      expect(find.byType(DisplayQueryWidget), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('renders empty placeholder when rows empty', (tester) async {
      await tester.pumpWidget(
        wrap(buildDetail(rows: const [], rowCount: 0)),
      );
      expect(find.text('No data in table'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('honors custom styles and colors', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            headerStyle: const TextStyle(fontSize: 18),
            evenRowStyle: const TextStyle(fontSize: 14, color: Colors.blue),
            oddRowStyle:
                const TextStyle(fontSize: 14, color: Colors.indigo),
            evenRowColor: Colors.cyan,
            oddRowColor: Colors.teal,
            headerBackgroundColor: Colors.amber,
            nullValueDisplay: '∅',
            textHandling: TextHandling.wrap,
          ),
        ),
      );
      expect(find.byType(DisplayQueryWidget), findsOneWidget);
      expect(find.text('∅'), findsAtLeastNWidgets(1));
    });

    testWidgets('falls back to defaults when no style overrides given',
        (tester) async {
      // No evenRowStyle / oddRowStyle — fallback to bodyMedium then
      // const TextStyle(fontSize: 14).
      await tester.pumpWidget(wrap(buildDetail()));
      expect(find.byType(DisplayQueryWidget), findsOneWidget);
    });
  });

  group('SqliteViewerTableDetail lifecycle', () {
    testWidgets('disposes TabController without throwing', (tester) async {
      await tester.pumpWidget(wrap(buildDetail()));
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(find.byType(SqliteViewerTableDetail), findsNothing);
    });
  });
}
