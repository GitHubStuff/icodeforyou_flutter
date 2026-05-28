// test/src/widgets/sqlite_viewer_metadata_panel/sqlite_viewer_metadata_panel_table_list_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  Widget wrap(Widget child) {
    return testableWidgetWithScaffold(
      SizedBox(width: 320, height: 600, child: child),
    );
  }

  group('TableListBuilder extension', () {
    testWidgets('renders ListView.separated when tables present',
        (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: testMetadata)),
      );
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Divider), findsWidgets);
    });

    testWidgets('renders table_chart_outlined icon for unselected items',
        (tester) async {
      await tester.pumpWidget(
        wrap(const SqliteViewerMetadataPanel(metadata: testMetadata)),
      );
      // Two unselected items
      expect(
        find.byIcon(Icons.table_chart_outlined),
        findsNWidgets(2),
      );
    });

    testWidgets('selected item still renders table icon and chevron',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const SqliteViewerMetadataPanel(
            metadata: testMetadata,
            selectedTable: 'posts',
          ),
        ),
      );
      expect(find.byIcon(Icons.table_chart_outlined), findsNWidgets(2));
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets(
      'shows italic "No tables found" message when tables empty',
      (tester) async {
        await tester.pumpWidget(
          wrap(const SqliteViewerMetadataPanel(metadata: emptyMetadata)),
        );

        final textWidget = tester.widget<Text>(find.text('No tables found'));
        expect(textWidget.style?.fontStyle, FontStyle.italic);
      },
    );

    testWidgets('selected table is bold; unselected is normal',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const SqliteViewerMetadataPanel(
            metadata: testMetadata,
            selectedTable: 'users',
            // Provide a base tableItemStyle so copyWith merges
            tableItemStyle: TextStyle(fontSize: 14),
          ),
        ),
      );

      final users = tester.widget<Text>(find.text('users'));
      final posts = tester.widget<Text>(find.text('posts'));
      expect(users.style?.fontWeight, FontWeight.w600);
      expect(posts.style?.fontWeight, FontWeight.normal);
    });
  });
}
