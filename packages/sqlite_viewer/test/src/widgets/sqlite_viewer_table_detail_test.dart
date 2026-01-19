// test/src/widgets/sqlite_viewer_table_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('SqliteViewerTableDetail', () {
    const columns = ['id', 'name', 'email'];
    
    const tableInfo = [
      {'cid': 0, 'name': 'id', 'type': 'INTEGER', 'notnull': 1, 'dflt_value': null, 'pk': 1},
      {'cid': 1, 'name': 'name', 'type': 'TEXT', 'notnull': 0, 'dflt_value': null, 'pk': 0},
      {'cid': 2, 'name': 'email', 'type': 'TEXT', 'notnull': 1, 'dflt_value': "'test@example.com'", 'pk': 0},
    ];
    
    const indexList = [
      {'seq': 0, 'name': 'idx_email', 'unique': 1, 'origin': 'c', 'partial': 0},
      {'seq': 1, 'name': 'pk_idx', 'unique': 1, 'origin': 'pk', 'partial': 0},
      {'seq': 2, 'name': 'idx_name', 'unique': 0, 'origin': 'u', 'partial': 0},
    ];
    
    const foreignKeys = [
      {
        'id': 0,
        'seq': 0,
        'table': 'users',
        'from': 'user_id',
        'to': 'id',
        'on_update': 'NO ACTION',
        'on_delete': 'CASCADE',
      },
    ];
    
    const rows = [
      {'id': 1, 'name': 'Alice', 'email': 'alice@test.com'},
      {'id': 2, 'name': 'Bob', 'email': 'bob@test.com'},
    ];

    Widget buildWidget({
      String tableName = 'users',
      List<String> cols = columns,
      List<Map<String, Object?>> info = tableInfo,
      List<Map<String, Object?>> indexes = indexList,
      List<Map<String, Object?>> fks = foreignKeys,
      List<Map<String, Object?>> data = rows,
      int rowCount = 100,
      VoidCallback? onRefresh,
      bool isLoading = false,
      bool showRowNumbers = true,
      TextStyle? headerStyle,
      TextStyle? evenRowStyle,
      TextStyle? oddRowStyle,
      Color? evenRowColor,
      Color? oddRowColor,
      Color? headerBackgroundColor,
      String nullValueDisplay = 'NULL',
      TextHandling textHandling = TextHandling.trunc,
    }) {
      return testableWidgetWithScaffold(
        SizedBox(
          width: 900,
          height: 800,
          child: SqliteViewerTableDetail(
            tableName: tableName,
            columns: cols,
            tableInfo: info,
            indexList: indexes,
            foreignKeys: fks,
            rows: data,
            rowCount: rowCount,
            onRefresh: onRefresh,
            isLoading: isLoading,
            showRowNumbers: showRowNumbers,
            headerStyle: headerStyle,
            evenRowStyle: evenRowStyle,
            oddRowStyle: oddRowStyle,
            evenRowColor: evenRowColor,
            oddRowColor: oddRowColor,
            headerBackgroundColor: headerBackgroundColor,
            nullValueDisplay: nullValueDisplay,
            textHandling: textHandling,
          ),
        ),
      );
    }

    testWidgets('displays table name in header', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.text('users'), findsOneWidget);
    });

    testWidgets('displays column and row count', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.text('3 columns • 100 rows'), findsOneWidget);
    });

    testWidgets('displays table_chart icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.byIcon(Icons.table_chart), findsOneWidget);
    });

    testWidgets('shows Data and Schema tabs', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.text('Data (100)'), findsOneWidget);
      expect(find.text('Schema (3)'), findsOneWidget);
    });

    testWidgets('shows tab icons', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      expect(find.byIcon(Icons.table_rows_outlined), findsOneWidget);
      expect(find.byIcon(Icons.schema_outlined), findsOneWidget);
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
      
      await tester.tap(find.byType(IconButton).first);
      await tester.pump();
      
      expect(refreshCalled, isFalse);
    });

    testWidgets('shows empty state when no rows', (tester) async {
      await tester.pumpWidget(buildWidget(data: [], rowCount: 0));
      
      expect(find.text('No data in table'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('switches to Schema tab on tap', (tester) async {
      await tester.pumpWidget(buildWidget());
      
      await tester.tap(find.text('Schema (3)'));
      await tester.pumpAndSettle();
      
      // Schema tab content should be visible
      expect(find.text('Columns'), findsOneWidget);
    });

    group('Schema tab', () {
      testWidgets('displays Columns section', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.text('Columns'), findsOneWidget);
        expect(find.byIcon(Icons.view_column_outlined), findsOneWidget);
      });

      testWidgets('displays column names and types', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.text('id'), findsWidgets);
        expect(find.text('INTEGER'), findsOneWidget);
        expect(find.text('TEXT'), findsWidgets);
      });

      testWidgets('displays primary key icon', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.byIcon(Icons.key), findsOneWidget);
      });

      testWidgets('displays NOT NULL badge', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.text('NOT NULL'), findsWidgets);
      });

      testWidgets('displays DEFAULT badge', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.text('DEFAULT'), findsOneWidget);
      });

      testWidgets('displays Indexes section', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.text('Indexes'), findsOneWidget);
        expect(find.byIcon(Icons.sort_outlined), findsOneWidget);
      });

      testWidgets('displays index names', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.text('idx_email'), findsOneWidget);
        expect(find.text('pk_idx'), findsOneWidget);
      });

      testWidgets('displays UNIQUE badge for unique indexes', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.text('UNIQUE'), findsWidgets);
      });

      testWidgets('displays index origin labels', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.text('CREATE INDEX'), findsOneWidget);
        expect(find.text('PRIMARY KEY'), findsOneWidget);
      });

      testWidgets('displays Foreign Keys section', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.text('Foreign Keys'), findsOneWidget);
        expect(find.byIcon(Icons.link_outlined), findsOneWidget);
      });

      testWidgets('displays foreign key relationships', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.text('user_id'), findsOneWidget);
        expect(find.text('users.id'), findsOneWidget);
        expect(find.text('ON DELETE CASCADE • ON UPDATE NO ACTION'), findsOneWidget);
      });

      testWidgets('displays arrow icon for foreign key', (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      });

      testWidgets('displays "No indexes defined" when empty', (tester) async {
        await tester.pumpWidget(buildWidget(indexes: []));
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.text('No indexes defined'), findsOneWidget);
      });

      testWidgets('displays "No foreign keys defined" when empty', (tester) async {
        await tester.pumpWidget(buildWidget(fks: []));
        await tester.tap(find.text('Schema (3)'));
        await tester.pumpAndSettle();
        
        expect(find.text('No foreign keys defined'), findsOneWidget);
      });
    });

    group('Data tab', () {
      testWidgets('displays DisplayQueryWidget', (tester) async {
        await tester.pumpWidget(buildWidget());
        
        expect(find.byType(DisplayQueryWidget), findsOneWidget);
      });

      testWidgets('passes showRowNumbers to DisplayQueryWidget', (tester) async {
        await tester.pumpWidget(buildWidget(showRowNumbers: true));
        
        expect(find.text('#'), findsOneWidget);
      });

      testWidgets('applies custom row styles', (tester) async {
        await tester.pumpWidget(buildWidget(
          evenRowStyle: const TextStyle(color: Colors.red),
          oddRowStyle: const TextStyle(color: Colors.blue),
        ));
        
        expect(find.text('Alice'), findsOneWidget);
      });
    });
  });
}
