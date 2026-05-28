// test/src/widgets/sqlite_viewer_table_detail/sqlite_viewer_table_detail_items_test.dart

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
    List<Map<String, Object?>> tableInfo = const [],
    List<Map<String, Object?>> indexList = const [],
    List<Map<String, Object?>> foreignKeys = const [],
  }) {
    return SqliteViewerTableDetail(
      tableName: 'users',
      columns: const ['id'],
      tableInfo: tableInfo,
      indexList: indexList,
      foreignKeys: foreignKeys,
      rows: const [
        {'id': 1},
      ],
      rowCount: 1,
    );
  }

  group('Column item builder', () {
    testWidgets('renders pk column with key icon and NOT NULL badge',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            tableInfo: const [
              {
                'cid': 0,
                'name': 'id',
                'type': 'INTEGER',
                'notnull': 1,
                'dflt_value': null,
                'pk': 1,
              },
            ],
          ),
        ),
      );
      await openSchemaTab(tester);

      expect(find.byIcon(Icons.key), findsOneWidget);
      expect(find.text('id'), findsWidgets);
      expect(find.text('INTEGER'), findsOneWidget);
      expect(find.text('NOT NULL'), findsOneWidget);
    });

    testWidgets('non-pk, nullable column without default has no badges',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            tableInfo: const [
              {
                'cid': 0,
                'name': 'note',
                'type': 'TEXT',
                'notnull': 0,
                'dflt_value': null,
                'pk': 0,
              },
            ],
          ),
        ),
      );
      await openSchemaTab(tester);

      expect(find.byIcon(Icons.key), findsNothing);
      expect(find.text('NOT NULL'), findsNothing);
      expect(find.text('DEFAULT'), findsNothing);
    });

    testWidgets('column with default value renders DEFAULT badge',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            tableInfo: const [
              {
                'cid': 0,
                'name': 'flag',
                'type': 'INTEGER',
                'notnull': 1,
                'dflt_value': '0',
                'pk': 0,
              },
            ],
          ),
        ),
      );
      await openSchemaTab(tester);

      expect(find.text('NOT NULL'), findsOneWidget);
      expect(find.text('DEFAULT'), findsOneWidget);
    });

    testWidgets('handles missing keys via null-safe path', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            tableInfo: const [
              // empty map — every '?.toString() ?? "" works
              <String, Object?>{},
            ],
          ),
        ),
      );
      await openSchemaTab(tester);
      // No icons, no badges
      expect(find.byIcon(Icons.key), findsNothing);
      expect(find.text('NOT NULL'), findsNothing);
      expect(find.text('DEFAULT'), findsNothing);
    });
  });

  group('Index item builder', () {
    testWidgets('renders origin "c" as CREATE INDEX', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            indexList: const [
              {'seq': 0, 'name': 'idx_x', 'unique': 0, 'origin': 'c'},
            ],
          ),
        ),
      );
      await openSchemaTab(tester);
      expect(find.text('idx_x'), findsOneWidget);
      expect(find.text('CREATE INDEX'), findsOneWidget);
      // Not unique → no UNIQUE badge
      expect(find.text('UNIQUE'), findsNothing);
    });

    testWidgets('renders origin "u" as UNIQUE (origin label)', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            indexList: const [
              {'seq': 0, 'name': 'idx_u', 'unique': 1, 'origin': 'u'},
            ],
          ),
        ),
      );
      await openSchemaTab(tester);
      // Unique badge (from unique == 1) + UNIQUE origin label.
      expect(find.text('UNIQUE'), findsNWidgets(2));
    });

    testWidgets('renders origin "pk" as PRIMARY KEY', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            indexList: const [
              {'seq': 0, 'name': 'sqlite_pk', 'unique': 1, 'origin': 'pk'},
            ],
          ),
        ),
      );
      await openSchemaTab(tester);
      expect(find.text('PRIMARY KEY'), findsOneWidget);
    });

    testWidgets('renders unknown origin label verbatim (default case)',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            indexList: const [
              {'seq': 0, 'name': 'idx_w', 'unique': 0, 'origin': 'weird'},
            ],
          ),
        ),
      );
      await openSchemaTab(tester);
      expect(find.text('weird'), findsOneWidget);
    });

    testWidgets('handles missing index keys gracefully', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            indexList: const [<String, Object?>{}],
          ),
        ),
      );
      await openSchemaTab(tester);
      // Empty origin string → default case → empty label string rendered.
      expect(find.byType(SqliteViewerTableDetail), findsOneWidget);
    });
  });

  group('Foreign key item builder', () {
    testWidgets('renders from → to and ON DELETE / ON UPDATE clauses',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            foreignKeys: const [
              {
                'id': 0,
                'seq': 0,
                'table': 'users',
                'from': 'user_id',
                'to': 'id',
                'on_update': 'NO ACTION',
                'on_delete': 'CASCADE',
              },
            ],
          ),
        ),
      );
      await openSchemaTab(tester);
      expect(find.text('user_id'), findsOneWidget);
      expect(find.text('users.id'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(
        find.text('ON DELETE CASCADE • ON UPDATE NO ACTION'),
        findsOneWidget,
      );
    });

    testWidgets('falls back to NO ACTION when on_delete/on_update missing',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            foreignKeys: const [
              {
                'id': 0,
                'seq': 0,
                'table': 'users',
                'from': 'user_id',
                'to': 'id',
              },
            ],
          ),
        ),
      );
      await openSchemaTab(tester);
      expect(
        find.text('ON DELETE NO ACTION • ON UPDATE NO ACTION'),
        findsOneWidget,
      );
    });

    testWidgets('handles entirely missing keys', (tester) async {
      await tester.pumpWidget(
        wrap(
          buildDetail(
            foreignKeys: const [<String, Object?>{}],
          ),
        ),
      );
      await openSchemaTab(tester);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });
  });
}
