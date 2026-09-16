// packages/sqlite_viewer/test/src/widgets/display_query_widget/display_query_widget_cells_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('CellBuilders extension behavior', () {
    testWidgets('builds row 0 with even style and row 1 with odd style',
        (tester) async {
      await tester.pumpWidget(
        testableWidgetWithScaffold(
          const SizedBox(
            width: 600,
            height: 400,
            child: DisplayQueryWidget(
              columns: ['id', 'name'],
              rows: [
                {'id': 1, 'name': 'A'},
                {'id': 2, 'name': 'B'},
              ],
              evenRowStyle: TextStyle(fontSize: 14),
              oddRowStyle: TextStyle(fontSize: 16),
              evenRowColor: Colors.white,
              oddRowColor: Colors.grey,
            ),
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('null values render in italic grey style', (tester) async {
      await tester.pumpWidget(
        testableWidgetWithScaffold(
          const SizedBox(
            width: 600,
            height: 400,
            child: DisplayQueryWidget(
              columns: ['id', 'name'],
              rows: [
                {'id': 1, 'name': null},
              ],
              evenRowStyle: TextStyle(fontSize: 14),
              oddRowStyle: TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
      expect(find.text('NULL'), findsOneWidget);
    });

    testWidgets('renders with TextHandling.wrap branch', (tester) async {
      await tester.pumpWidget(
        testableWidgetWithScaffold(
          const SizedBox(
            width: 600,
            height: 400,
            child: DisplayQueryWidget(
              columns: ['note'],
              rows: [
                {'note': 'A very long note that should wrap to many lines'},
              ],
              evenRowStyle: TextStyle(fontSize: 14),
              oddRowStyle: TextStyle(fontSize: 14),
              textHandling: TextHandling.wrap,
            ),
          ),
        ),
      );
      expect(find.text('A very long note that should wrap to many lines'),
          findsOneWidget);
    });
  });
}
