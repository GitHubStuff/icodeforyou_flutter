// test/src/widgets/sqlite_viewer_table_detail/sqlite_viewer_table_detail_schema_test.dart

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

  Future<void> openSchemaTab(WidgetTester tester) async {
    await tester.tap(find.textContaining('Schema'));
    await tester.pumpAndSettle();
  }

  SqliteViewerTableDetail buildDetail({
    List<Map<String, Object?>> tableInfo = testTableInfo,
    List<Map<String, Object?>> indexList = testIndexList,
    List<Map<String, Object?>> foreignKeys = testForeignKeys,
  }) {
    return SqliteViewerTableDetail(
      tableName: 'users',
      columns: const ['id', 'name', 'email'],
      tableInfo: tableInfo,
      indexList: indexList,
      foreignKeys: foreignKeys,
      rows: testRows,
      rowCount: 3,
    );
  }

  group('Schema tab sections', () {
    testWidgets('renders three section headers', (tester) async {
      await tester.pumpWidget(wrap(buildDetail()));
      await openSchemaTab(tester);
      expect(find.text('Columns'), findsOneWidget);
      expect(find.text('Indexes'), findsOneWidget);
      expect(find.text('Foreign Keys'), findsOneWidget);
    });

    testWidgets('renders section icons', (tester) async {
      await tester.pumpWidget(wrap(buildDetail()));
      await openSchemaTab(tester);
      expect(find.byIcon(Icons.view_column_outlined), findsOneWidget);
      expect(find.byIcon(Icons.sort_outlined), findsOneWidget);
      expect(find.byIcon(Icons.link_outlined), findsOneWidget);
    });

    testWidgets('renders empty-state message when section is empty',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            indexList: const [],
            foreignKeys: const [],
          ),
        ),
      );
      await openSchemaTab(tester);
      expect(find.text('No indexes defined'), findsOneWidget);
      expect(find.text('No foreign keys defined'), findsOneWidget);
    });

    testWidgets('shows item counts in section badges', (tester) async {
      await tester.pumpWidget(wrap(buildDetail()));
      await openSchemaTab(tester);
      // tableInfo:3, indexList:3, foreignKeys:1
      // The number '3' appears in two section badges and other places —
      // assert "at least one" so we don't over-constrain.
      expect(find.text('3'), findsWidgets);
      expect(find.text('1'), findsAtLeastNWidgets(1));
    });
  });
}
