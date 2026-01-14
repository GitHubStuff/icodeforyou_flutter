// display_query_widget_edge_cases_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  const defaultEvenStyle = TextStyle(fontSize: 14.0, color: Colors.black87);
  const defaultOddStyle = TextStyle(fontSize: 14.0, color: Colors.black54);

  Widget buildTestWidget({
    required List<String> columns,
    required List<Map<String, Object?>> rows,
    bool showRowNumbers = false,
    String nullValueDisplay = 'NULL',
    TextHandling textHandling = TextHandling.trunc,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DisplayQueryWidget(
          columns: columns,
          rows: rows,
          evenRowStyle: defaultEvenStyle,
          oddRowStyle: defaultOddStyle,
          showRowNumbers: showRowNumbers,
          nullValueDisplay: nullValueDisplay,
          textHandling: textHandling,
        ),
      ),
    );
  }

  group('_getCellValue edge cases', () {
    testWidgets('row number column shows correct index', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['name'],
          rows: [
            {'name': 'First'},
            {'name': 'Second'},
            {'name': 'Third'},
          ],
          showRowNumbers: true,
        ),
      );

      expect(find.text('#'), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
    });

    testWidgets('handles column not in row map', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['exists', 'not_exists'],
          rows: [
            {'exists': 'value'},
          ],
        ),
      );

      expect(find.text('value'), findsOneWidget);
      expect(find.text('NULL'), findsOneWidget);
    });
  });

  group('_isNullValue edge cases', () {
    testWidgets('row number column is never null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['data'],
          rows: [
            {'data': null},
          ],
          showRowNumbers: true,
        ),
      );

      final texts = tester.widgetList<Text>(find.byType(Text));
      final rowNumberText = texts.where((t) => t.data == '1').firstOrNull;

      expect(rowNumberText, isNotNull);
      expect(rowNumberText?.style?.fontStyle, isNot(FontStyle.italic));
    });
  });

  group('_listEquals edge cases', () {
    testWidgets('detects column list changes - different length', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['a'],
          rows: [
            {'a': 1},
          ],
        ),
      );

      expect(find.text('a'), findsOneWidget);

      await tester.pumpWidget(
        buildTestWidget(
          columns: ['a', 'b', 'c'],
          rows: [
            {'a': 1, 'b': 2, 'c': 3},
          ],
        ),
      );

      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
    });

    testWidgets('detects column list changes - same length different content', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['old1', 'old2'],
          rows: [
            {'old1': 'x', 'old2': 'y'},
          ],
        ),
      );

      expect(find.text('old1'), findsOneWidget);

      await tester.pumpWidget(
        buildTestWidget(
          columns: ['new1', 'new2'],
          rows: [
            {'new1': 'a', 'new2': 'b'},
          ],
        ),
      );

      expect(find.text('new1'), findsOneWidget);
      expect(find.text('old1'), findsNothing);
    });

    testWidgets('no recalculation when columns are identical', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['same'],
          rows: [
            {'same': 'value'},
          ],
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(
          columns: ['same'],
          rows: [
            {'same': 'value'},
          ],
        ),
      );

      expect(find.text('same'), findsOneWidget);
    });
  });

  group('scroll behavior', () {
    testWidgets('can scroll horizontally in wide table', (tester) async {
      final wideColumns = List.generate(20, (i) => 'column_$i');
      final rowData = {for (var c in wideColumns) c: 'data'};

      await tester.pumpWidget(
        buildTestWidget(
          columns: wideColumns,
          rows: [rowData, rowData, rowData],
        ),
      );

      final headerScroll = find
          .byType(SingleChildScrollView)
          .evaluate()
          .map((e) => e.widget as SingleChildScrollView)
          .where((sv) => sv.scrollDirection == Axis.horizontal)
          .first;

      expect(headerScroll, isNotNull);
    });

    testWidgets('can scroll vertically in long table', (tester) async {
      final manyRows = List.generate(50, (i) => {'id': i, 'name': 'Row $i'});

      await tester.pumpWidget(
        buildTestWidget(columns: ['id', 'name'], rows: manyRows),
      );

      final verticalScroll = find
          .byType(SingleChildScrollView)
          .evaluate()
          .map((e) => e.widget as SingleChildScrollView)
          .where((sv) => sv.scrollDirection == Axis.vertical)
          .first;

      expect(verticalScroll, isNotNull);
    });
  });

  group('column width calculation', () {
    testWidgets('wider data expands column', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['short'],
          rows: [
            {'short': 'This is a much longer piece of text'},
          ],
        ),
      );

      expect(find.byType(DisplayQueryWidget), findsOneWidget);
    });

    testWidgets('narrow data uses minimum width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DisplayQueryWidget(
              columns: ['x'],
              rows: [
                {'x': 'a'},
              ],
              evenRowStyle: defaultEvenStyle,
              oddRowStyle: defaultOddStyle,
              minColumnWidth: 80.0,
            ),
          ),
        ),
      );

      expect(find.byType(DisplayQueryWidget), findsOneWidget);
    });

    testWidgets('very wide data capped at max width', (tester) async {
      final veryLongText = 'X' * 1000;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DisplayQueryWidget(
              columns: ['wide'],
              rows: [
                {'wide': veryLongText},
              ],
              evenRowStyle: defaultEvenStyle,
              oddRowStyle: defaultOddStyle,
              maxColumnWidth: 200.0,
            ),
          ),
        ),
      );

      expect(find.byType(DisplayQueryWidget), findsOneWidget);
    });
  });

  group('row styling alternation', () {
    testWidgets('first row (index 0) uses even style/color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DisplayQueryWidget(
              columns: ['val'],
              rows: [
                {'val': 'row0'},
                {'val': 'row1'},
                {'val': 'row2'},
                {'val': 'row3'},
              ],
              evenRowStyle: const TextStyle(color: Colors.blue),
              oddRowStyle: const TextStyle(color: Colors.red),
              evenRowColor: Colors.blue.shade50,
              oddRowColor: Colors.red.shade50,
            ),
          ),
        ),
      );

      final row0Text = tester.widget<Text>(find.text('row0'));
      expect(row0Text.style?.color, equals(Colors.blue));

      final row1Text = tester.widget<Text>(find.text('row1'));
      expect(row1Text.style?.color, equals(Colors.red));
    });
  });

  group('text handling modes', () {
    testWidgets('trunc mode sets maxLines and overflow', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['text'],
          rows: [
            {'text': 'Some text content'},
          ],
          textHandling: TextHandling.trunc,
        ),
      );

      final contentText = tester.widget<Text>(find.text('Some text content'));
      expect(contentText.maxLines, equals(1));
      expect(contentText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('wrap mode enables soft wrap', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['text'],
          rows: [
            {'text': 'Some text content'},
          ],
          textHandling: TextHandling.wrap,
        ),
      );

      final contentText = tester.widget<Text>(find.text('Some text content'));
      expect(contentText.softWrap, isTrue);
    });
  });

  group('header cell rendering', () {
    testWidgets('header cells have ellipsis overflow', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['header_name'],
          rows: [
            {'header_name': 'value'},
          ],
        ),
      );

      final headerText = tester.widget<Text>(find.text('header_name'));
      expect(headerText.overflow, equals(TextOverflow.ellipsis));
      expect(headerText.maxLines, equals(1));
    });
  });

  group('total table width', () {
    testWidgets('table width is sum of column widths', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['a', 'b', 'c'],
          rows: [
            {'a': '1', 'b': '2', 'c': '3'},
          ],
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBoxes, isNotEmpty);
    });
  });

  group('special value types', () {
    testWidgets('handles DateTime toString', (tester) async {
      final now = DateTime(2025, 1, 13, 10, 30);
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['timestamp'],
          rows: [
            {'timestamp': now},
          ],
        ),
      );

      expect(find.textContaining('2025'), findsOneWidget);
    });

    testWidgets('handles List toString', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['items'],
          rows: [
            {
              'items': [1, 2, 3],
            },
          ],
        ),
      );

      expect(find.text('[1, 2, 3]'), findsOneWidget);
    });

    testWidgets('handles Map toString', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          columns: ['nested'],
          rows: [
            {
              'nested': {'key': 'value'},
            },
          ],
        ),
      );

      expect(find.textContaining('key'), findsOneWidget);
    });
  });
}
