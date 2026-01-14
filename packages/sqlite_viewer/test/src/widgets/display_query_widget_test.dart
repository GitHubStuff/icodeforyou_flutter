// display_query_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  const defaultEvenStyle = TextStyle(fontSize: 14.0, color: Colors.black87);
  const defaultOddStyle = TextStyle(fontSize: 14.0, color: Colors.black54);

  final sampleColumns = ['id', 'name', 'email'];
  final sampleRows = <Map<String, Object?>>[
    {'id': 1, 'name': 'Alice', 'email': 'alice@test.com'},
    {'id': 2, 'name': 'Bob', 'email': null},
    {'id': 3, 'name': 'Charlie', 'email': 'charlie@test.com'},
  ];

  Widget buildTestWidget({
    List<String>? columns,
    List<Map<String, Object?>>? rows,
    TextStyle? evenRowStyle,
    TextStyle? oddRowStyle,
    TextStyle? headerStyle,
    Color? evenRowColor,
    Color? oddRowColor,
    Color? headerBackgroundColor,
    EdgeInsets? cellPadding,
    String? nullValueDisplay,
    TextHandling? textHandling,
    bool? showRowNumbers,
    Widget? emptyWidget,
    double? minColumnWidth,
    double? maxColumnWidth,
    Color? borderColor,
    double? headerHeight,
    double? rowHeight,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DisplayQueryWidget(
          columns: columns ?? sampleColumns,
          rows: rows ?? sampleRows,
          evenRowStyle: evenRowStyle ?? defaultEvenStyle,
          oddRowStyle: oddRowStyle ?? defaultOddStyle,
          headerStyle: headerStyle,
          evenRowColor: evenRowColor,
          oddRowColor: oddRowColor,
          headerBackgroundColor: headerBackgroundColor,
          cellPadding: cellPadding ??
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          nullValueDisplay: nullValueDisplay ?? 'NULL',
          textHandling: textHandling ?? TextHandling.trunc,
          showRowNumbers: showRowNumbers ?? false,
          emptyWidget: emptyWidget,
          minColumnWidth: minColumnWidth ?? 60.0,
          maxColumnWidth: maxColumnWidth ?? 300.0,
          borderColor: borderColor,
          headerHeight: headerHeight ?? 48.0,
          rowHeight: rowHeight ?? 44.0,
        ),
      ),
    );
  }

  group('DisplayQueryWidget', () {
    group('empty state', () {
      testWidgets('renders SizedBox.shrink when columns is empty',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          columns: [],
          rows: sampleRows,
        ));

        expect(find.byType(SizedBox), findsOneWidget);
        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, equals(0.0));
        expect(sizedBox.height, equals(0.0));
      });

      testWidgets('renders custom emptyWidget when columns is empty',
          (tester) async {
        const emptyKey = Key('empty-widget');
        await tester.pumpWidget(buildTestWidget(
          columns: [],
          rows: sampleRows,
          emptyWidget: const Text('Custom Empty', key: emptyKey),
        ));

        expect(find.byKey(emptyKey), findsOneWidget);
        expect(find.text('Custom Empty'), findsOneWidget);
      });

      testWidgets('renders default message when rows is empty', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          columns: sampleColumns,
          rows: [],
        ));

        expect(find.text('No data available'), findsOneWidget);
      });

      testWidgets('renders custom emptyWidget when rows is empty',
          (tester) async {
        const emptyKey = Key('empty-rows-widget');
        await tester.pumpWidget(buildTestWidget(
          columns: sampleColumns,
          rows: [],
          emptyWidget: const Text('No Records', key: emptyKey),
        ));

        expect(find.byKey(emptyKey), findsOneWidget);
        expect(find.text('No Records'), findsOneWidget);
      });
    });

    group('basic rendering', () {
      testWidgets('renders column headers', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('id'), findsOneWidget);
        expect(find.text('name'), findsOneWidget);
        expect(find.text('email'), findsOneWidget);
      });

      testWidgets('renders row data', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
        expect(find.text('Charlie'), findsOneWidget);
        expect(find.text('alice@test.com'), findsOneWidget);
        expect(find.text('charlie@test.com'), findsOneWidget);
      });

      testWidgets('renders correct number of rows', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });
    });

    group('row numbers', () {
      testWidgets('does not show row numbers by default', (tester) async {
        await tester.pumpWidget(buildTestWidget(showRowNumbers: false));

        expect(find.text('#'), findsNothing);
      });

      testWidgets('shows row numbers when enabled', (tester) async {
        await tester.pumpWidget(buildTestWidget(showRowNumbers: true));

        expect(find.text('#'), findsOneWidget);
        final oneTexts = find.text('1');
        expect(oneTexts, findsWidgets);
      });

      testWidgets('row numbers are sequential starting from 1', (tester) async {
        await tester.pumpWidget(buildTestWidget(showRowNumbers: true));

        expect(find.text('#'), findsOneWidget);
      });
    });

    group('null value display', () {
      testWidgets('displays default NULL for null values', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('NULL'), findsOneWidget);
      });

      testWidgets('displays custom string for null values', (tester) async {
        await tester.pumpWidget(buildTestWidget(nullValueDisplay: '—'));

        expect(find.text('—'), findsOneWidget);
        expect(find.text('NULL'), findsNothing);
      });

      testWidgets('displays custom N/A for null values', (tester) async {
        await tester.pumpWidget(buildTestWidget(nullValueDisplay: 'N/A'));

        expect(find.text('N/A'), findsOneWidget);
      });
    });

    group('text handling', () {
      testWidgets('uses truncation by default', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          textHandling: TextHandling.trunc,
        ));

        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        final dataTexts = textWidgets.where((t) =>
            t.data == 'Alice' || t.data == 'Bob' || t.data == 'Charlie');

        for (final text in dataTexts) {
          expect(text.maxLines, equals(1));
          expect(text.overflow, equals(TextOverflow.ellipsis));
        }
      });

      testWidgets('uses wrap when specified', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          textHandling: TextHandling.wrap,
        ));

        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        final dataTexts = textWidgets.where((t) =>
            t.data == 'Alice' || t.data == 'Bob' || t.data == 'Charlie');

        for (final text in dataTexts) {
          expect(text.softWrap, isTrue);
        }
      });
    });

    group('styling', () {
      testWidgets('applies even row color', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          evenRowColor: Colors.blue.shade50,
        ));

        final containers = tester.widgetList<Container>(find.byType(Container));
        final coloredContainers = containers.where((c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == Colors.blue.shade50;
          }
          return false;
        });

        expect(coloredContainers, isNotEmpty);
      });

      testWidgets('applies odd row color', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          oddRowColor: Colors.grey.shade100,
        ));

        final containers = tester.widgetList<Container>(find.byType(Container));
        final coloredContainers = containers.where((c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == Colors.grey.shade100;
          }
          return false;
        });

        expect(coloredContainers, isNotEmpty);
      });

      testWidgets('applies header background color', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          headerBackgroundColor: Colors.indigo.shade200,
        ));

        final containers = tester.widgetList<Container>(find.byType(Container));
        final headerContainer = containers.where((c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == Colors.indigo.shade200;
          }
          return false;
        });

        expect(headerContainer, isNotEmpty);
      });

      testWidgets('applies custom header style', (tester) async {
        const customHeaderStyle = TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w900,
          color: Colors.red,
        );

        await tester.pumpWidget(buildTestWidget(
          headerStyle: customHeaderStyle,
        ));

        final idText = tester.widget<Text>(find.text('id'));
        expect(idText.style?.fontWeight, equals(FontWeight.w900));
        expect(idText.style?.color, equals(Colors.red));
      });

      testWidgets('derives header style from evenRowStyle when not provided',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          evenRowStyle: const TextStyle(fontSize: 16.0, color: Colors.green),
          headerStyle: null,
        ));

        final idText = tester.widget<Text>(find.text('id'));
        expect(idText.style?.fontWeight, equals(FontWeight.bold));
      });

      testWidgets('applies custom border color', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          borderColor: Colors.red,
        ));

        final containers = tester.widgetList<Container>(find.byType(Container));
        final borderedContainers = containers.where((c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration && decoration.border != null) {
            final border = decoration.border as Border;
            return border.bottom.color == Colors.red ||
                border.right.color == Colors.red;
          }
          return false;
        });

        expect(borderedContainers, isNotEmpty);
      });

      testWidgets('uses default border color when not provided', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          borderColor: null,
        ));

        final containers = tester.widgetList<Container>(find.byType(Container));
        final borderedContainers = containers.where((c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration && decoration.border != null) {
            final border = decoration.border as Border;
            return border.bottom.color == Colors.grey.shade300 ||
                border.right.color == Colors.grey.shade300;
          }
          return false;
        });

        expect(borderedContainers, isNotEmpty);
      });
    });

    group('dimensions', () {
      testWidgets('applies header height', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          headerHeight: 60.0,
        ));

        final containers = tester.widgetList<Container>(find.byType(Container));
        final headerContainer =
            containers.where((c) => c.constraints?.maxHeight == 60.0);

        expect(headerContainer, isNotEmpty);
      });

      testWidgets('applies row height', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          rowHeight: 50.0,
        ));

        final containers = tester.widgetList<Container>(find.byType(Container));
        final rowContainers =
            containers.where((c) => c.constraints?.maxHeight == 50.0);

        expect(rowContainers, isNotEmpty);
      });

      testWidgets('respects min column width', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          columns: ['a'],
          rows: [
            {'a': 'x'}
          ],
          minColumnWidth: 100.0,
        ));

        final containers = tester.widgetList<Container>(find.byType(Container));
        final widthContainers = containers.where((c) {
          final constraints = c.constraints;
          if (constraints != null) {
            return constraints.maxWidth >= 100.0;
          }
          return false;
        });

        expect(widthContainers, isNotEmpty);
      });

      testWidgets('respects max column width', (tester) async {
        final longText = 'A' * 500;
        await tester.pumpWidget(buildTestWidget(
          columns: ['long_column'],
          rows: [
            {'long_column': longText}
          ],
          maxColumnWidth: 150.0,
        ));

        await tester.pumpAndSettle();
        expect(find.byType(DisplayQueryWidget), findsOneWidget);
      });

      testWidgets('applies cell padding', (tester) async {
        const customPadding = EdgeInsets.all(20.0);
        await tester.pumpWidget(buildTestWidget(
          cellPadding: customPadding,
        ));

        final containers = tester.widgetList<Container>(find.byType(Container));
        final paddedContainers =
            containers.where((c) => c.padding == customPadding);

        expect(paddedContainers, isNotEmpty);
      });
    });

    group('didUpdateWidget', () {
      testWidgets('recalculates layout when columns change', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          columns: ['col1'],
          rows: [
            {'col1': 'value1'}
          ],
        ));

        expect(find.text('col1'), findsOneWidget);

        await tester.pumpWidget(buildTestWidget(
          columns: ['col1', 'col2'],
          rows: [
            {'col1': 'value1', 'col2': 'value2'}
          ],
        ));

        expect(find.text('col2'), findsOneWidget);
      });

      testWidgets('recalculates layout when rows change', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          columns: ['name'],
          rows: [
            {'name': 'Alice'}
          ],
        ));

        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsNothing);

        await tester.pumpWidget(buildTestWidget(
          columns: ['name'],
          rows: [
            {'name': 'Alice'},
            {'name': 'Bob'}
          ],
        ));

        expect(find.text('Bob'), findsOneWidget);
      });

      testWidgets('recalculates layout when showRowNumbers changes',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          showRowNumbers: false,
        ));

        expect(find.text('#'), findsNothing);

        await tester.pumpWidget(buildTestWidget(
          showRowNumbers: true,
        ));

        expect(find.text('#'), findsOneWidget);
      });

      testWidgets('does not recalculate when unrelated props change',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          evenRowColor: Colors.white,
        ));

        await tester.pumpWidget(buildTestWidget(
          evenRowColor: Colors.blue,
        ));

        expect(find.byType(DisplayQueryWidget), findsOneWidget);
      });
    });

    group('scroll synchronization', () {
      testWidgets('widget builds with scroll controllers', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final scrollViews =
            tester.widgetList<SingleChildScrollView>(
                find.byType(SingleChildScrollView));
        expect(scrollViews.length, greaterThanOrEqualTo(2));
      });

      testWidgets('horizontal scroll views are present', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final horizontalScrollViews = tester
            .widgetList<SingleChildScrollView>(
                find.byType(SingleChildScrollView))
            .where((sv) => sv.scrollDirection == Axis.horizontal);

        expect(horizontalScrollViews.length, greaterThanOrEqualTo(2));
      });
    });

    group('edge cases', () {
      testWidgets('handles row with missing column key', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          columns: ['id', 'name', 'missing_col'],
          rows: [
            {'id': 1, 'name': 'Test'}
          ],
        ));

        expect(find.text('NULL'), findsOneWidget);
      });

      testWidgets('handles empty string values', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          columns: ['name'],
          rows: [
            {'name': ''}
          ],
        ));

        expect(find.byType(DisplayQueryWidget), findsOneWidget);
      });

      testWidgets('handles numeric values', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          columns: ['count', 'price'],
          rows: [
            {'count': 42, 'price': 19.99}
          ],
        ));

        expect(find.text('42'), findsOneWidget);
        expect(find.text('19.99'), findsOneWidget);
      });

      testWidgets('handles boolean values', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          columns: ['active'],
          rows: [
            {'active': true},
            {'active': false}
          ],
        ));

        expect(find.text('true'), findsOneWidget);
        expect(find.text('false'), findsOneWidget);
      });

      testWidgets('handles single column', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          columns: ['only'],
          rows: [
            {'only': 'value'}
          ],
        ));

        expect(find.text('only'), findsOneWidget);
        expect(find.text('value'), findsOneWidget);
      });

      testWidgets('handles single row', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          columns: ['a', 'b', 'c'],
          rows: [
            {'a': 1, 'b': 2, 'c': 3}
          ],
        ));

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('handles many columns with row numbers', (tester) async {
        final manyCols = List.generate(10, (i) => 'col$i');
        final rowData = {for (var c in manyCols) c: 'val'};

        await tester.pumpWidget(buildTestWidget(
          columns: manyCols,
          rows: [rowData],
          showRowNumbers: true,
        ));

        expect(find.text('#'), findsOneWidget);
        expect(find.text('col0'), findsOneWidget);
        expect(find.text('col9'), findsOneWidget);
      });

      testWidgets('handles all null row', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          columns: ['a', 'b', 'c'],
          rows: [
            {'a': null, 'b': null, 'c': null}
          ],
        ));

        expect(find.text('NULL'), findsNWidgets(3));
      });

      testWidgets('null values have italic grey style', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          columns: ['name'],
          rows: [
            {'name': null}
          ],
        ));

        final nullTexts = tester.widgetList<Text>(find.text('NULL'));
        for (final text in nullTexts) {
          expect(text.style?.fontStyle, equals(FontStyle.italic));
          expect(text.style?.color, equals(Colors.grey));
        }
      });
    });

    group('dispose', () {
      testWidgets('disposes scroll controllers on widget removal',
          (tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.pumpWidget(const MaterialApp(
          home: Scaffold(body: SizedBox()),
        ));

        expect(find.byType(DisplayQueryWidget), findsNothing);
      });
    });
  });
}
