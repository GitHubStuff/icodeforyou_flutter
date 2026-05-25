// packages/sqlite_viewer/test/src/widgets/display_query_widget_stretch_unsaturated_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  group('DisplayQueryWidget viewport stretch — unsaturated branch', () {
    testWidgets(
      'distributes slack proportionally when no column hits maxColumnWidth',
      (tester) async {
        // Two narrow columns ('a' and 'b'), default minColumnWidth = 60,
        // maxColumnWidth = 300. Content-fit widths land near minColumnWidth
        // so each column has lots of headroom.
        //
        // Viewport width is 200 — only ~80 px of slack. Each column's
        // proportional share (~40 px) is well below its ~240 px headroom,
        // so the `share < headroom` branch runs for both columns.
        const viewportWidth = 200.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: viewportWidth,
                  child: DisplayQueryWidget(
                    columns: const ['a', 'b'],
                    rows: const [
                      {'a': '1', 'b': '2'},
                    ],
                    evenRowStyle: const TextStyle(fontSize: 12),
                    oddRowStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        );

        // Widget mounted and laid out — the unsaturated branch executed
        // during _stretchToViewport.
        expect(find.byType(DisplayQueryWidget), findsOneWidget);
        expect(find.text('a'), findsOneWidget);
        expect(find.text('b'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
      },
    );
  });
}
