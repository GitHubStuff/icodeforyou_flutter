// test/src/widgets/display_query_widget/display_query_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  const evenStyle = TextStyle(fontSize: 14);
  const oddStyle = TextStyle(fontSize: 14, fontStyle: FontStyle.italic);

  Widget buildWidget({
    List<String> columns = const ['id', 'name'],
    List<Map<String, Object?>> rows = testRows,
    bool showRowNumbers = false,
    TextHandling textHandling = TextHandling.trunc,
    Widget? emptyWidget,
    TextStyle? headerStyle,
    Color? evenRowColor,
    Color? oddRowColor,
    Color? headerBackgroundColor,
    Color? borderColor,
    String nullValueDisplay = 'NULL',
    double minColumnWidth = 60,
    double maxColumnWidth = 300,
    double headerHeight = 48,
    double rowHeight = 44,
  }) {
    return testableWidgetWithScaffold(
      SizedBox(
        width: 800,
        height: 600,
        child: DisplayQueryWidget(
          columns: columns,
          rows: rows,
          evenRowStyle: evenStyle,
          oddRowStyle: oddStyle,
          headerStyle: headerStyle,
          evenRowColor: evenRowColor,
          oddRowColor: oddRowColor,
          headerBackgroundColor: headerBackgroundColor,
          borderColor: borderColor,
          showRowNumbers: showRowNumbers,
          textHandling: textHandling,
          emptyWidget: emptyWidget,
          nullValueDisplay: nullValueDisplay,
          minColumnWidth: minColumnWidth,
          maxColumnWidth: maxColumnWidth,
          headerHeight: headerHeight,
          rowHeight: rowHeight,
        ),
      ),
    );
  }

  group('DisplayQueryWidget rendering', () {
    testWidgets('renders with columns and rows', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('id'), findsOneWidget);
      expect(find.text('name'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('renders NULL placeholder for null values', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('NULL'), findsAtLeastNWidgets(1));
    });

    testWidgets('respects custom nullValueDisplay', (tester) async {
      await tester.pumpWidget(
        buildWidget(nullValueDisplay: '(empty)'),
      );
      expect(find.text('(empty)'), findsAtLeastNWidgets(1));
      expect(find.text('NULL'), findsNothing);
    });

    testWidgets('renders row numbers column when showRowNumbers is true', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(showRowNumbers: true));
      expect(find.text('#'), findsOneWidget);
      expect(find.text('1'), findsAtLeastNWidgets(1));
      expect(find.text('2'), findsAtLeastNWidgets(1));
      expect(find.text('3'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders header styles', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          headerStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
          headerBackgroundColor: Colors.amber,
        ),
      );
      expect(find.text('id'), findsOneWidget);
    });

    testWidgets('renders empty widget when columns is empty', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          columns: const [],
          rows: const [],
          emptyWidget: const Text('CUSTOM EMPTY'),
        ),
      );
      expect(find.text('CUSTOM EMPTY'), findsOneWidget);
    });

    testWidgets(
      'returns SizedBox.shrink when columns empty and no emptyWidget',
      (tester) async {
        await tester.pumpWidget(
          buildWidget(columns: const [], rows: const []),
        );
        // Just make sure it doesn't crash and renders empty
        expect(find.text('id'), findsNothing);
        expect(find.text('name'), findsNothing);
      },
    );

    testWidgets('renders "No data available" when rows empty no emptyWidget', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(rows: const []),
      );
      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('renders custom empty widget when rows empty', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          rows: const [],
          emptyWidget: const Text('Nothing here'),
        ),
      );
      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('renders with TextHandling.wrap', (tester) async {
      await tester.pumpWidget(buildWidget(textHandling: TextHandling.wrap));
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('uses custom border, even and odd row colors', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          evenRowColor: Colors.blue.shade50,
          oddRowColor: Colors.blue.shade100,
          borderColor: Colors.red,
        ),
      );
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('handles single-column data', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          columns: const ['only'],
          rows: const [
            {'only': 'value1'},
            {'only': 'value2'},
          ],
        ),
      );
      expect(find.text('only'), findsOneWidget);
      expect(find.text('value1'), findsOneWidget);
      expect(find.text('value2'), findsOneWidget);
    });

    testWidgets('handles missing column in row (returns empty cell)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          columns: const ['id', 'name', 'extra'],
          rows: const [
            {'id': 1, 'name': 'a'},
          ],
        ),
      );
      // 'extra' header rendered
      expect(find.text('extra'), findsOneWidget);
      // value missing => null display
      expect(find.text('NULL'), findsOneWidget);
    });
  });

  group('DisplayQueryWidget lifecycle', () {
    testWidgets('recomputes layout when columns change', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('id'), findsOneWidget);

      await tester.pumpWidget(
        buildWidget(columns: const ['a', 'b']),
      );
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('id'), findsNothing);
    });

    testWidgets('recomputes layout when row count changes', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Alice'), findsOneWidget);

      await tester.pumpWidget(
        buildWidget(
          rows: const [
            {'id': 99, 'name': 'Solo'},
          ],
        ),
      );
      expect(find.text('Solo'), findsOneWidget);
      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('recomputes layout when showRowNumbers toggled', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('#'), findsNothing);

      await tester.pumpWidget(buildWidget(showRowNumbers: true));
      expect(find.text('#'), findsOneWidget);
    });

    testWidgets('does not recompute on unrelated rebuild', (tester) async {
      await tester.pumpWidget(buildWidget());
      // Rebuild with same params
      await tester.pumpWidget(buildWidget());
      expect(find.text('id'), findsOneWidget);
    });

    testWidgets(
      'invalidates cached widths on didChangeDependencies '
      '(text scaler change)',
      (tester) async {
        const widget = SizedBox(
          width: 600,
          height: 400,
          child: DisplayQueryWidget(
            columns: ['id', 'name'],
            rows: testRows,
            evenRowStyle: evenStyle,
            oddRowStyle: oddStyle,
          ),
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.noScaling),
              child: widget,
            ),
          ),
        );

        // Change MediaQuery text scaler — triggers didChangeDependencies
        await tester.pumpWidget(
          const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
              child: widget,
            ),
          ),
        );

        expect(find.text('id'), findsOneWidget);
      },
    );

    testWidgets('dispose tears down without error', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      // Reaching here without exception means dispose ran cleanly.
      expect(find.text('id'), findsNothing);
    });
  });

  group('horizontal scroll sync', () {
    testWidgets(
      'header and body scroll controllers sync (no exceptions)',
      (tester) async {
        await tester.pumpWidget(
          buildWidget(
            columns: List.generate(20, (i) => 'col_$i'),
            rows: List.generate(
              5,
              (rowIndex) => {
                for (var i = 0; i < 20; i++) 'col_$i': 'r${rowIndex}_c$i',
              },
            ),
          ),
        );

        // Drag the header horizontally — first listener (header → body) fires.
        // First-drag target is on-screen; subsequent drags use fixed
        // on-screen offsets since the original targets may have scrolled
        // out of the hit-testable area.
        await tester.drag(
          find.text('col_0'),
          const Offset(-200, 0),
          warnIfMissed: false,
        );
        await tester.pump();

        // Drag from a fixed on-screen offset inside the body — second
        // listener (body → header) fires. warnIfMissed: false because we
        // only need the gesture to reach the body's scroll view; we don't
        // care which cell receives it.
        await tester.dragFrom(
          const Offset(400, 300),
          const Offset(-100, 0),
        );
        await tester.pump();
      },
    );
  });
}
