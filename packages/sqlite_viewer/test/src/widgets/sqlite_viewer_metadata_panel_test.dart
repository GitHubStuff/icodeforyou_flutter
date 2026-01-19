// test/src/widgets/sqlite_viewer_metadata_panel_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('SqliteViewerMetadataPanel', () {
    Widget buildWidget({
      DatabaseMetadata metadata = testMetadata,
      String? selectedTable,
      ValueChanged<String>? onTableSelected,
      VoidCallback? onRefresh,
      bool isLoading = false,
      TextStyle? headerStyle,
      TextStyle? labelStyle,
      TextStyle? valueStyle,
      TextStyle? tableItemStyle,
      Color? selectedTableColor,
      Color? backgroundColor,
      Color? dividerColor,
    }) {
      return testableWidgetWithScaffold(
        SizedBox(
          width: 300,
          height: 600,
          child: SqliteViewerMetadataPanel(
            metadata: metadata,
            selectedTable: selectedTable,
            onTableSelected: onTableSelected,
            onRefresh: onRefresh,
            isLoading: isLoading,
            headerStyle: headerStyle,
            labelStyle: labelStyle,
            valueStyle: valueStyle,
            tableItemStyle: tableItemStyle,
            selectedTableColor: selectedTableColor,
            backgroundColor: backgroundColor,
            dividerColor: dividerColor,
          ),
        ),
      );
    }

    testWidgets('displays database filename', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.text('test.db'), findsOneWidget);
    });

    testWidgets('displays :memory: for in-memory database', (tester) async {
      await tester.pumpWidget(buildWidget(metadata: inMemoryMetadata));
      
      expect(find.text(':memory:'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays SQLite version', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.text('SQLite'), findsOneWidget);
      expect(find.text('3.39.0'), findsOneWidget);
    });

    testWidgets('displays database size', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.text('Size'), findsOneWidget);
      expect(find.text('1.00 KB'), findsOneWidget);
    });

    testWidgets('displays database path', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.text('Path'), findsOneWidget);
      expect(find.text('/path/test.db'), findsOneWidget);
    });

    testWidgets('displays "In-memory database" for in-memory path',
        (tester) async {
      await tester.pumpWidget(buildWidget(metadata: inMemoryMetadata));
      
      expect(find.text('In-memory database'), findsOneWidget);
    });

    testWidgets('displays table count', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.text('Tables'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // 2 tables
    });

    testWidgets('displays table names', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.text('users'), findsOneWidget);
      expect(find.text('posts'), findsOneWidget);
    });

    testWidgets('displays "No tables found" when empty', (tester) async {
      await tester.pumpWidget(buildWidget(metadata: emptyMetadata));
      
      expect(find.text('No tables found'), findsOneWidget);
    });

    testWidgets('highlights selected table', (tester) async {
      await tester.pumpWidget(buildWidget(selectedTable: 'users'));
      
      // The selected table should have a chevron icon
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('calls onTableSelected when table tapped', (tester) async {
      String? selectedTable;
      await tester.pumpWidget(buildWidget(
        onTableSelected: (table) => selectedTable = table,
      ));
      
      await tester.tap(find.text('users'));
      await tester.pump();
      
      expect(selectedTable, 'users');
    });

    testWidgets('shows refresh button when onRefresh provided', (tester) async {
      await tester.pumpWidget(buildWidget(onRefresh: () {}));
      
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('hides refresh button when onRefresh is null', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('calls onRefresh when refresh button tapped', (tester) async {
      bool refreshCalled = false;
      await tester.pumpWidget(buildWidget(
        onRefresh: () => refreshCalled = true,
      ));
      
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      
      expect(refreshCalled, isTrue);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(buildWidget(
        onRefresh: () {},
        isLoading: true,
      ));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('disables refresh button when isLoading', (tester) async {
      bool refreshCalled = false;
      await tester.pumpWidget(buildWidget(
        onRefresh: () => refreshCalled = true,
        isLoading: true,
      ));
      
      // Try to find and tap the refresh button area
      final iconButton = find.byType(IconButton).first;
      await tester.tap(iconButton);
      await tester.pump();
      
      expect(refreshCalled, isFalse);
    });

    testWidgets('shows storage icon for file-based database', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.byIcon(Icons.storage), findsOneWidget);
    });

    testWidgets('shows memory icon for in-memory database', (tester) async {
      await tester.pumpWidget(buildWidget(metadata: inMemoryMetadata));
      
      expect(find.byIcon(Icons.memory), findsOneWidget);
    });

    testWidgets('applies custom styles', (tester) async {
      await tester.pumpWidget(buildWidget(
        headerStyle: const TextStyle(fontSize: 20, color: Colors.red),
        labelStyle: const TextStyle(fontSize: 10, color: Colors.blue),
        valueStyle: const TextStyle(fontSize: 12, color: Colors.green),
        tableItemStyle: const TextStyle(fontSize: 14, color: Colors.orange),
        selectedTableColor: Colors.purple,
        backgroundColor: Colors.yellow,
        dividerColor: Colors.pink,
      ));
      
      // Widget should render without errors
      expect(find.text('test.db'), findsOneWidget);
    });

    testWidgets('table item shows table_chart icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.byIcon(Icons.table_chart_outlined), findsAtLeastNWidgets(1));
    });

    testWidgets('does not call onTableSelected when null', (tester) async {
      await tester.pumpWidget(buildWidget(onTableSelected: null));
      
      // Tapping should not throw
      await tester.tap(find.text('users'));
      await tester.pump();
    });
  });
}
