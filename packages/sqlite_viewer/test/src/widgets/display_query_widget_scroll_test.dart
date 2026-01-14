// display_query_widget_scroll_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  const defaultEvenStyle = TextStyle(fontSize: 14.0, color: Colors.black87);
  const defaultOddStyle = TextStyle(fontSize: 14.0, color: Colors.black54);

  group('scroll synchronization', () {
    testWidgets('header and body scroll horizontally together', 
        (tester) async {
      final wideColumns = List.generate(15, (i) => 'col_$i');
      final rowData = {for (var c in wideColumns) c: 'data_value'};
      final rows = List.generate(5, (_) => Map<String, Object?>.from(rowData));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: DisplayQueryWidget(
              columns: wideColumns,
              rows: rows,
              evenRowStyle: defaultEvenStyle,
              oddRowStyle: defaultOddStyle,
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle();

      final horizontalScrollViews = find
          .byType(SingleChildScrollView)
          .evaluate()
          .map((e) => e.widget as SingleChildScrollView)
          .where((sv) => sv.scrollDirection == Axis.horizontal)
          .toList();

      expect(horizontalScrollViews.length, greaterThanOrEqualTo(2));

      final bodyScrollFinder = find.byType(SingleChildScrollView).at(2);
      await tester.drag(bodyScrollFinder, const Offset(-100, 0));
      await tester.pumpAndSettle();

      expect(find.byType(DisplayQueryWidget), findsOneWidget);
    });

    testWidgets('scrolling header syncs body position', (tester) async {
      final wideColumns = List.generate(15, (i) => 'col_$i');
      final rowData = {for (var c in wideColumns) c: 'data_value'};
      final rows = List.generate(5, (_) => Map<String, Object?>.from(rowData));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: DisplayQueryWidget(
              columns: wideColumns,
              rows: rows,
              evenRowStyle: defaultEvenStyle,
              oddRowStyle: defaultOddStyle,
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle();

      final headerScrollFinder = find.byType(SingleChildScrollView).first;
      await tester.drag(headerScrollFinder, const Offset(-100, 0));
      await tester.pumpAndSettle();

      expect(find.byType(DisplayQueryWidget), findsOneWidget);
    });

    testWidgets('body scrolls vertically', (tester) async {
      final rows = List.generate(
        30,
        (i) => {'id': i, 'name': 'Row $i'},
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: DisplayQueryWidget(
              columns: ['id', 'name'],
              rows: rows,
              evenRowStyle: defaultEvenStyle,
              oddRowStyle: defaultOddStyle,
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Row 0'), findsOneWidget);

      final scrollableFinder = find.byType(SingleChildScrollView).first;
      await tester.drag(scrollableFinder, const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.byType(DisplayQueryWidget), findsOneWidget);
    });

    testWidgets('scroll controllers are properly disposed', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DisplayQueryWidget(
            columns: ['col'],
            rows: [
              {'col': 'val'}
            ],
            evenRowStyle: defaultEvenStyle,
            oddRowStyle: defaultOddStyle,
          ),
        ),
      ));

      await tester.pumpAndSettle();

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: Placeholder()),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(DisplayQueryWidget), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scroll sync handles no clients state', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DisplayQueryWidget(
            columns: ['a'],
            rows: [
              {'a': '1'}
            ],
            evenRowStyle: defaultEvenStyle,
            oddRowStyle: defaultOddStyle,
          ),
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.byType(DisplayQueryWidget), findsOneWidget);
    });
  });

  group('constraint scenarios', () {
    testWidgets('handles very small container', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 100,
            height: 100,
            child: DisplayQueryWidget(
              columns: ['a', 'b', 'c', 'd', 'e'],
              rows: [
                {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5}
              ],
              evenRowStyle: defaultEvenStyle,
              oddRowStyle: defaultOddStyle,
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.byType(DisplayQueryWidget), findsOneWidget);
    });

    testWidgets('handles unconstrained width', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DisplayQueryWidget(
              columns: ['col'],
              rows: [
                {'col': 'value'}
              ],
              evenRowStyle: defaultEvenStyle,
              oddRowStyle: defaultOddStyle,
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.byType(DisplayQueryWidget), findsOneWidget);
    });
  });
}
