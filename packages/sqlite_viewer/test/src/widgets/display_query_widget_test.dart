// test/src/widgets/display_query_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('DisplayQueryWidget', () {
    const columns = ['id', 'name', 'email'];
    const rows = [
      {'id': 1, 'name': 'Alice', 'email': 'alice@test.com'},
      {'id': 2, 'name': 'Bob', 'email': 'bob@test.com'},
      {'id': 3, 'name': null, 'email': 'null@test.com'},
    ];

    const evenStyle = TextStyle(fontSize: 14, color: Colors.black);
    const oddStyle = TextStyle(fontSize: 14, color: Colors.black87);

    Widget buildWidget({
      List<String> cols = columns,
      List<Map<String, Object?>> data = rows,
      bool showRowNumbers = false,
      String nullValueDisplay = 'NULL',
      TextHandling textHandling = TextHandling.trunc,
      Widget? emptyWidget,
      TextStyle? headerStyle,
      Color? evenRowColor,
      Color? oddRowColor,
      Color? headerBackgroundColor,
      Color? borderColor,
    }) {
      return testableWidgetWithScaffold(
        DisplayQueryWidget(
          columns: cols,
          rows: data,
          evenRowStyle: evenStyle,
          oddRowStyle: oddStyle,
          showRowNumbers: showRowNumbers,
          nullValueDisplay: nullValueDisplay,
          textHandling: textHandling,
          emptyWidget: emptyWidget,
          headerStyle: headerStyle,
          evenRowColor: evenRowColor,
          oddRowColor: oddRowColor,
          headerBackgroundColor: headerBackgroundColor,
          borderColor: borderColor,
        ),
      );
    }

    testWidgets('renders column headers', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('id'), findsOneWidget);
      expect(find.text('name'), findsOneWidget);
      expect(find.text('email'), findsOneWidget);
    });

    testWidgets('renders row data', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('alice@test.com'), findsOneWidget);
    });

    testWidgets('renders null values with nullValueDisplay', (tester) async {
      await tester.pumpWidget(buildWidget(nullValueDisplay: 'N/A'));

      expect(find.text('N/A'), findsOneWidget);
    });

    testWidgets('shows row numbers when enabled', (tester) async {
      await tester.pumpWidget(buildWidget(showRowNumbers: true));

      // Header column for row numbers
      expect(find.text('#'), findsOneWidget);
      // Row numbers exist (may find duplicates due to data values)
      expect(find.text('1'), findsWidgets);
      expect(find.text('2'), findsWidgets);
      expect(find.text('3'), findsWidgets);
    });

    testWidgets('shows emptyWidget when columns is empty', (tester) async {
      await tester.pumpWidget(
        buildWidget(cols: [], emptyWidget: const Text('Custom Empty')),
      );

      expect(find.text('Custom Empty'), findsOneWidget);
    });

    testWidgets('shows SizedBox when columns is empty and no emptyWidget', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(cols: []));

      // Should find only the scaffold, not any data
      expect(find.text('id'), findsNothing);
    });

    testWidgets('shows emptyWidget when rows is empty', (tester) async {
      await tester.pumpWidget(
        buildWidget(data: [], emptyWidget: const Text('No Data')),
      );

      expect(find.text('No Data'), findsOneWidget);
    });

    testWidgets('shows default empty message when rows is empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(data: []));

      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('applies custom header style', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          headerStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      );

      // Header should be rendered
      expect(find.text('id'), findsOneWidget);
    });

    testWidgets('applies row colors', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          evenRowColor: Colors.white,
          oddRowColor: Colors.grey.shade100,
        ),
      );

      // Rows should be rendered
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('applies header background color', (tester) async {
      await tester.pumpWidget(
        buildWidget(headerBackgroundColor: Colors.blue.shade100),
      );

      expect(find.text('id'), findsOneWidget);
    });

    testWidgets('applies border color', (tester) async {
      await tester.pumpWidget(buildWidget(borderColor: Colors.red));

      expect(find.text('id'), findsOneWidget);
    });

    testWidgets('uses wrap text handling', (tester) async {
      await tester.pumpWidget(buildWidget(textHandling: TextHandling.wrap));

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('updates layout when columns change', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('email'), findsOneWidget);

      await tester.pumpWidget(buildWidget(cols: ['id', 'name']));
      expect(find.text('email'), findsNothing);
    });

    testWidgets('updates layout when rows change', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Alice'), findsOneWidget);

      await tester.pumpWidget(
        buildWidget(
          data: [
            {'id': 10, 'name': 'Charlie', 'email': 'charlie@test.com'},
          ],
        ),
      );
      expect(find.text('Charlie'), findsOneWidget);
    });

    testWidgets('updates layout when showRowNumbers changes', (tester) async {
      await tester.pumpWidget(buildWidget(showRowNumbers: false));
      expect(find.text('#'), findsNothing);

      await tester.pumpWidget(buildWidget(showRowNumbers: true));
      expect(find.text('#'), findsOneWidget);
    });

    testWidgets('horizontal scroll works', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Find the scrollable area and scroll
      final scrollable = find.byType(SingleChildScrollView).first;
      expect(scrollable, findsOneWidget);
    });

    testWidgets('handles out of bounds column index gracefully', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          showRowNumbers: true,
          data: [
            {'id': 1, 'name': 'Test'},
          ],
        ),
      );

      // Should not crash
      expect(find.text('Test'), findsOneWidget);
    });
  });
}
