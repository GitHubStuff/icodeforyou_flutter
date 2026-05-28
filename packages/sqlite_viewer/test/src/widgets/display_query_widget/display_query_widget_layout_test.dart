// test/src/widgets/display_query_widget/display_query_widget_layout_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  const evenStyle = TextStyle(fontSize: 14);
  const oddStyle = TextStyle(fontSize: 14);

  group('LayoutCalculations branches', () {
    testWidgets('content narrower than viewport => stretch fills viewport',
        (tester) async {
      await tester.pumpWidget(
        testableWidgetWithScaffold(
          SizedBox(
            width: 1200,
            height: 600,
            child: DisplayQueryWidget(
              columns: const ['a', 'b'],
              rows: const [
                {'a': 'x', 'b': 'y'},
              ],
              evenRowStyle: evenStyle,
              oddRowStyle: oddStyle,
              minColumnWidth: 60,
              maxColumnWidth: 1000,
            ),
          ),
        ),
      );
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
    });

    testWidgets(
      'content wider than viewport => no stretch, scroll horizontally',
      (tester) async {
        await tester.pumpWidget(
          testableWidgetWithScaffold(
            SizedBox(
              width: 200,
              height: 400,
              child: DisplayQueryWidget(
                columns: List.generate(15, (i) => 'column_$i'),
                rows: const [{}],
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
                minColumnWidth: 100,
                maxColumnWidth: 200,
              ),
            ),
          ),
        );
        expect(find.text('column_0'), findsOneWidget);
      },
    );

    testWidgets(
      'columns saturate at maxColumnWidth, slack remaining loops complete',
      (tester) async {
        await tester.pumpWidget(
          testableWidgetWithScaffold(
            SizedBox(
              width: 4000,
              height: 400,
              child: DisplayQueryWidget(
                columns: const ['a', 'b'],
                rows: const [
                  {'a': 'x', 'b': 'y'},
                ],
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
                // Set max much lower than what 4000/2 would give —
                // columns will saturate, breaking out of the stretch loop.
                minColumnWidth: 50,
                maxColumnWidth: 200,
              ),
            ),
          ),
        );
        expect(find.text('a'), findsOneWidget);
      },
    );

    testWidgets(
      'showRowNumbers prepends # column and indexes correctly',
      (tester) async {
        await tester.pumpWidget(
          testableWidgetWithScaffold(
            SizedBox(
              width: 600,
              height: 400,
              child: DisplayQueryWidget(
                columns: const ['id'],
                rows: const [
                  {'id': 'first'},
                  {'id': 'second'},
                ],
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
                showRowNumbers: true,
              ),
            ),
          ),
        );
        expect(find.text('#'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('first'), findsOneWidget);
        expect(find.text('second'), findsOneWidget);
      },
    );

    testWidgets(
      'showRowNumbers with column index 0 returns "false" for isNullValue',
      (tester) async {
        // Row number column should never be styled as null even if
        // the source row contains nulls.
        await tester.pumpWidget(
          testableWidgetWithScaffold(
            SizedBox(
              width: 600,
              height: 400,
              child: DisplayQueryWidget(
                columns: const ['id'],
                rows: const [
                  {'id': null},
                ],
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
                showRowNumbers: true,
              ),
            ),
          ),
        );
        expect(find.text('1'), findsOneWidget);
        expect(find.text('NULL'), findsOneWidget);
      },
    );

    testWidgets(
      'value.toString() path covers non-string cells (int, bool)',
      (tester) async {
        await tester.pumpWidget(
          testableWidgetWithScaffold(
            SizedBox(
              width: 600,
              height: 400,
              child: DisplayQueryWidget(
                columns: const ['n', 'active'],
                rows: const [
                  {'n': 42, 'active': true},
                ],
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
              ),
            ),
          ),
        );
        expect(find.text('42'), findsOneWidget);
        expect(find.text('true'), findsOneWidget);
      },
    );

    testWidgets(
      'stretchToViewport returns input unchanged for empty list',
      (tester) async {
        final key = GlobalKey<DisplayQueryWidgetState>();
        await tester.pumpWidget(
          testableWidgetWithScaffold(
            SizedBox(
              width: 600,
              height: 400,
              child: DisplayQueryWidget(
                key: key,
                columns: const ['id'],
                rows: const [
                  {'id': 1},
                ],
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
              ),
            ),
          ),
        );
        final state = key.currentState!;
        expect(state.stretchToViewport(<double>[], 800), isEmpty);
      },
    );

    testWidgets(
      'stretchToViewport returns input unchanged for non-finite viewport',
      (tester) async {
        final key = GlobalKey<DisplayQueryWidgetState>();
        await tester.pumpWidget(
          testableWidgetWithScaffold(
            SizedBox(
              width: 600,
              height: 400,
              child: DisplayQueryWidget(
                key: key,
                columns: const ['id'],
                rows: const [
                  {'id': 1},
                ],
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
              ),
            ),
          ),
        );
        final state = key.currentState!;
        final result =
            state.stretchToViewport(<double>[100, 200], double.infinity);
        expect(result, [100, 200]);
      },
    );

    testWidgets(
      'stretchToViewport returns input unchanged for zero viewport',
      (tester) async {
        final key = GlobalKey<DisplayQueryWidgetState>();
        await tester.pumpWidget(
          testableWidgetWithScaffold(
            SizedBox(
              width: 600,
              height: 400,
              child: DisplayQueryWidget(
                key: key,
                columns: const ['id'],
                rows: const [
                  {'id': 1},
                ],
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
              ),
            ),
          ),
        );
        final state = key.currentState!;
        expect(state.stretchToViewport(<double>[100, 200], 0), [100, 200]);
      },
    );

    testWidgets(
      'stretchToViewport returns input unchanged when content >= viewport',
      (tester) async {
        final key = GlobalKey<DisplayQueryWidgetState>();
        await tester.pumpWidget(
          testableWidgetWithScaffold(
            SizedBox(
              width: 600,
              height: 400,
              child: DisplayQueryWidget(
                key: key,
                columns: const ['id'],
                rows: const [
                  {'id': 1},
                ],
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
              ),
            ),
          ),
        );
        final state = key.currentState!;
        // content sum = 600, viewport = 500 -> slack <= 0 -> return.
        final result = state.stretchToViewport(<double>[300, 300], 500);
        expect(result, [300, 300]);
      },
    );

    testWidgets(
      'stretchToViewport: all columns saturate, exits via empty growable',
      (tester) async {
        final key = GlobalKey<DisplayQueryWidgetState>();
        await tester.pumpWidget(
          testableWidgetWithScaffold(
            SizedBox(
              width: 600,
              height: 400,
              child: DisplayQueryWidget(
                key: key,
                columns: const ['id'],
                rows: const [
                  {'id': 1},
                ],
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
                maxColumnWidth: 150,
              ),
            ),
          ),
        );
        final state = key.currentState!;
        // sum = 100 + 100 = 200, viewport = 10000.
        // Slack >> headroom on both → both saturate at 150 → loop exits
        // via empty growable set with slack remaining.
        final result =
            state.stretchToViewport(<double>[100, 100], 10000);
        expect(result, [150, 150]);
      },
    );

    testWidgets(
      'stretchToViewport breaks when basis is zero',
      (tester) async {
        final key = GlobalKey<DisplayQueryWidgetState>();
        await tester.pumpWidget(
          testableWidgetWithScaffold(
            SizedBox(
              width: 600,
              height: 400,
              child: DisplayQueryWidget(
                key: key,
                columns: const ['id'],
                rows: const [
                  {'id': 1},
                ],
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
                maxColumnWidth: 200,
              ),
            ),
          ),
        );
        final state = key.currentState!;
        // All zero widths => basis == 0 on first iteration.
        final result = state.stretchToViewport(<double>[0, 0], 500);
        expect(result, [0, 0]);
      },
    );

    testWidgets(
      'getCellValue returns empty string for out-of-range column index',
      (tester) async {
        final key = GlobalKey<DisplayQueryWidgetState>();
        await tester.pumpWidget(
          testableWidgetWithScaffold(
            SizedBox(
              width: 600,
              height: 400,
              child: DisplayQueryWidget(
                key: key,
                columns: const ['id'],
                rows: const [
                  {'id': 1},
                ],
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
              ),
            ),
          ),
        );
        final state = key.currentState!;
        // colIndex 5 with only 1 column → actualColIndex 5, out of range.
        expect(state.getCellValue(const {'id': 1}, 5), '');
      },
    );

    testWidgets(
      'isNullValueRowTest returns false for out-of-range column index',
      (tester) async {
        final key = GlobalKey<DisplayQueryWidgetState>();
        await tester.pumpWidget(
          testableWidgetWithScaffold(
            SizedBox(
              width: 600,
              height: 400,
              child: DisplayQueryWidget(
                key: key,
                columns: const ['id'],
                rows: const [
                  {'id': 1},
                ],
                evenRowStyle: evenStyle,
                oddRowStyle: oddStyle,
              ),
            ),
          ),
        );
        final state = key.currentState!;
        expect(state.isNullValueRowTest(const {'id': 1}, 5), isFalse);
      },
    );
  });
}
