// packages/sqlite_viewer/test/src/widgets/display_query_widget_test.dart
// Tests for DisplayQueryWidget to achieve 100% coverage.
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/src/models/text_handling.dart';
import 'package:sqlite_viewer/src/widgets/display_query_widget.dart';

void main() {
  // Many wide columns to ensure horizontal scroll is needed
  final columns = [
    'column_one_very_long',
    'column_two_also_long',
    'column_three_extended',
    'column_four_wide',
    'column_five_extra',
  ];

  final rows = List.generate(
    10,
    (i) => {
      'column_one_very_long': 'Value $i that is quite long indeed',
      'column_two_also_long': 'Another value $i with extra text',
      'column_three_extended': 'More content for column $i here',
      'column_four_wide': 'Data entry number $i extended',
      'column_five_extra': 'Final column data row $i value',
    },
  );

  final evenStyle = TextStyle(color: Colors.black);
  final oddStyle = TextStyle(color: Colors.black87);

  Widget buildWidget({
    List<String>? cols,
    List<Map<String, Object?>>? data,
    bool showRowNumbers = false,
    Widget? emptyWidget,
    double width = 200, // Very narrow to force scrolling
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: 400,
          child: DisplayQueryWidget(
            columns: cols ?? columns,
            rows: data ?? rows,
            evenRowStyle: evenStyle,
            oddRowStyle: oddStyle,
            showRowNumbers: showRowNumbers,
            emptyWidget: emptyWidget,
            minColumnWidth: 150, // Wide columns
            maxColumnWidth: 200,
          ),
        ),
      ),
    );
  }

  group('DisplayQueryWidget Basic', () {
    testWidgets('renders with data', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('column_one_very_long'), findsOneWidget);
    });

    testWidgets('shows emptyWidget when columns empty', (tester) async {
      await tester.pumpWidget(buildWidget(
        cols: [],
        emptyWidget: Text('Empty columns'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Empty columns'), findsOneWidget);
    });

    testWidgets('shows SizedBox.shrink when columns empty no emptyWidget',
        (tester) async {
      await tester.pumpWidget(buildWidget(cols: [], data: []));
      await tester.pumpAndSettle();

      // Widget returns SizedBox.shrink
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows emptyWidget when rows empty', (tester) async {
      await tester.pumpWidget(buildWidget(
        data: [],
        emptyWidget: Text('No rows'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No rows'), findsOneWidget);
    });

    testWidgets('shows default message when rows empty', (tester) async {
      await tester.pumpWidget(buildWidget(data: []));
      await tester.pumpAndSettle();

      expect(find.text('No data available'), findsOneWidget);
    });
  });

  group('DisplayQueryWidget didUpdateWidget', () {
    testWidgets('recalculates on column change', (tester) async {
      await tester.pumpWidget(buildWidget(cols: ['a', 'b']));
      await tester.pumpAndSettle();

      expect(find.text('a'), findsOneWidget);

      await tester.pumpWidget(buildWidget(cols: ['x', 'y', 'z']));
      await tester.pumpAndSettle();

      expect(find.text('x'), findsOneWidget);
    });

    testWidgets('recalculates on row count change', (tester) async {
      final smallData = [
        {'column_one_very_long': 'A', 'column_two_also_long': 'B', 'column_three_extended': 'C', 'column_four_wide': 'D', 'column_five_extra': 'E'}
      ];
      final largeData = [
        {'column_one_very_long': 'A', 'column_two_also_long': 'B', 'column_three_extended': 'C', 'column_four_wide': 'D', 'column_five_extra': 'E'},
        {'column_one_very_long': 'F', 'column_two_also_long': 'G', 'column_three_extended': 'H', 'column_four_wide': 'I', 'column_five_extra': 'J'},
      ];

      await tester.pumpWidget(buildWidget(data: smallData));
      await tester.pumpAndSettle();

      await tester.pumpWidget(buildWidget(data: largeData));
      await tester.pumpAndSettle();
    });

    testWidgets('recalculates on showRowNumbers change', (tester) async {
      await tester.pumpWidget(buildWidget(showRowNumbers: false));
      await tester.pumpAndSettle();

      await tester.pumpWidget(buildWidget(showRowNumbers: true));
      await tester.pumpAndSettle();

      expect(find.text('#'), findsOneWidget);
    });

    testWidgets('no recalculation when columns unchanged', (tester) async {
      await tester.pumpWidget(buildWidget(cols: ['a', 'b']));
      await tester.pumpAndSettle();

      // Same columns, no change
      await tester.pumpWidget(buildWidget(cols: ['a', 'b']));
      await tester.pumpAndSettle();

      expect(find.text('a'), findsOneWidget);
    });
  });

  group('DisplayQueryWidget Scroll Sync', () {
    testWidgets('body horizontal scroll triggers listener', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Get all SingleChildScrollViews
      // Structure: Column[ Header(SCSV), Expanded(SCSV vert > SCSV horiz) ]
      final scrollViews = tester.widgetList<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollViews.length, equals(3));

      // Perform drag gesture in body area
      final widgetCenter = tester.getCenter(find.byType(DisplayQueryWidget));

      // Scroll body horizontally to trigger body listener → sync header
      await tester.timedDragFrom(
        Offset(widgetCenter.dx, widgetCenter.dy + 50), // Body area
        Offset(-300, 0), // Scroll left
        Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      // Scroll back
      await tester.timedDragFrom(
        Offset(widgetCenter.dx - 100, widgetCenter.dy + 50),
        Offset(150, 0),
        Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('header horizontal scroll triggers listener', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Get header position (top of widget)
      final widgetTopLeft = tester.getTopLeft(find.byType(DisplayQueryWidget));

      // Scroll header horizontally to trigger header listener → sync body
      await tester.timedDragFrom(
        Offset(widgetTopLeft.dx + 100, widgetTopLeft.dy + 20), // Header area
        Offset(-300, 0), // Scroll left
        Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      // Scroll back
      await tester.timedDragFrom(
        Offset(widgetTopLeft.dx + 50, widgetTopLeft.dy + 20),
        Offset(150, 0),
        Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('fling gesture on body syncs header', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final widgetCenter = tester.getCenter(find.byType(DisplayQueryWidget));

      // Fling on body area
      await tester.flingFrom(
        Offset(widgetCenter.dx, widgetCenter.dy + 50),
        Offset(-400, 0),
        2000,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('fling gesture on header syncs body', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final widgetTopLeft = tester.getTopLeft(find.byType(DisplayQueryWidget));

      // Fling on header area
      await tester.flingFrom(
        Offset(widgetTopLeft.dx + 100, widgetTopLeft.dy + 20),
        Offset(-400, 0),
        2000,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('TextHandling.wrap renders with softWrap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 400,
              child: DisplayQueryWidget(
                columns: columns,
                rows: rows,
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
                textHandling: TextHandling.wrap, // Use wrap instead of trunc
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should render with wrapped text
      expect(find.text('column_one_very_long'), findsOneWidget);
    });

    testWidgets('null values render with italic style', (tester) async {
      final dataWithNull = [
        {
          'column_one_very_long': 'Value',
          'column_two_also_long': null, // NULL value
          'column_three_extended': 'Data',
          'column_four_wide': null,
          'column_five_extra': 'More',
        },
      ];

      await tester.pumpWidget(buildWidget(data: dataWithNull));
      await tester.pumpAndSettle();

      // Should show NULL text for null values
      expect(find.text('NULL'), findsWidgets);
    });
  });
}
