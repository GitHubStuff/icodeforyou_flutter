// packages/data_grid/test/data_grid_test.dart

import 'package:data_grid/data_grid.dart' show DataDensity, DataGrid;
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rows crafted so every comparator branch is provable from display order:
///
/// * `name` — strings where case placement matters: case-sensitive
///   ascending puts 'Zebra' first (Z=0x5A < a=0x61); case-insensitive
///   puts 'apple' first.
/// * `count` — numbers 40 and 9 discriminate numeric from lexicographic
///   ordering ('40' < '9' as strings, 9 < 40 as numbers), plus two nulls
///   so insertion sort compares null against null (the both-null branch).
/// * `mixed` — exactly one non-string value (30) so every comparison
///   involving it takes the toString fallback, never the num-num path,
///   keeping the column's total order consistent: '30' < 'fig' <
///   'kiwi' < 'pear'.
List<Map<String, Object?>> _sortRows() => <Map<String, Object?>>[
  <String, Object?>{'name': 'banana', 'count': 40, 'mixed': 'pear'},
  <String, Object?>{'name': 'Zebra', 'count': 9, 'mixed': 30},
  <String, Object?>{'name': 'apple', 'count': null, 'mixed': 'fig'},
  <String, Object?>{'name': 'mango', 'count': null, 'mixed': 'kiwi'},
];

Future<void> _pumpGrid(
  WidgetTester tester,
  DataGrid grid, {
  double width = 600,
  double height = 400,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, height: height, child: grid),
        ),
      ),
    ),
  );
}

void main() {
  group('DataDensity', () {
    test('forWindowWidth maps Material window size classes conservatively', () {
      expect(DataDensity.forWindowWidth(0), DataDensity.standard);
      expect(DataDensity.forWindowWidth(839.9), DataDensity.standard);
      expect(DataDensity.forWindowWidth(840), DataDensity.comfortable);
      expect(DataDensity.forWindowWidth(1199.9), DataDensity.comfortable);
      expect(DataDensity.forWindowWidth(1200), DataDensity.compact);
      expect(DataDensity.forWindowWidth(1599.9), DataDensity.compact);
      expect(DataDensity.forWindowWidth(1600), DataDensity.dense);
      expect(DataDensity.forWindowWidth(2400), DataDensity.dense);
    });

    test('toVisualDensity mirrors each rung as a symmetric density', () {
      const expected = <DataDensity, double>{
        DataDensity.dense: -3,
        DataDensity.compact: -2,
        DataDensity.comfortable: -1,
        DataDensity.standard: 0,
        DataDensity.relaxed: 1,
        DataDensity.spacious: 2,
        DataDensity.airy: 3,
      };
      for (final rung in DataDensity.values) {
        final value = expected[rung]!;
        expect(
          rung.toVisualDensity(),
          VisualDensity(horizontal: value, vertical: value),
          reason: '$rung should map to a symmetric density of $value',
        );
      }
    });
  });

  group('rendering', () {
    testWidgets('empty data renders nothing', (tester) async {
      await _pumpGrid(tester, const DataGrid(data: <Map<String, Object?>>[]));

      expect(find.text('#'), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('renders chrome, row numbers, data cells, and null cells', (
      tester,
    ) async {
      await _pumpGrid(tester, DataGrid(data: _sortRows()));

      expect(find.text('#'), findsOneWidget);
      for (final header in <String>['name', 'count', 'mixed']) {
        expect(find.text(header), findsOneWidget);
      }
      for (final rowNumber in <String>['1', '2', '3', '4']) {
        expect(find.text(rowNumber), findsOneWidget);
      }
      expect(find.text('banana'), findsOneWidget);
      expect(find.text('Zebra'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('null'), findsNWidgets(2));
      expect(find.byIcon(Icons.arrow_drop_up), findsNothing);
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    });

    testWidgets(
      'columnWidths widen freely but never shrink below the caption minimum',
      (tester) async {
        await _pumpGrid(
          tester,
          DataGrid(
            data: const <Map<String, Object?>>[
              <String, Object?>{'name': 'ab', 'x': 'y'},
            ],
            columnWidths: const <String, int>{'name': 300, 'x': 1},
            chromeColor: Colors.teal,
            headerStyle: const TextStyle(color: Colors.amber),
            dataStyle: const TextStyle(fontSize: 16),
            haptic: HapticIntensity.none,
            density: DataDensity.dense.toVisualDensity(),
          ),
        );

        final nameCell = tester.getSize(
          find.ancestor(of: find.text('name'), matching: find.byType(InkWell)),
        );
        expect(nameCell.width, 300);

        final xCell = tester.getSize(
          find.ancestor(of: find.text('x'), matching: find.byType(InkWell)),
        );
        expect(
          xCell.width,
          greaterThan(20),
          reason: 'a 1px override must clamp up to caption + icon + padding',
        );

        // Row-button tap without onRowTap is a safe no-op.
        await tester.tap(find.text('1'));
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('sorting', () {
    testWidgets(
      'header tap cycles ascending → descending → unsorted; numbers compare '
      'numerically, nulls sort last ascending and first descending, and the '
      'third tap restores original order',
      (tester) async {
        int? tappedNumber;
        Map<String, Object?>? tappedRow;
        final grid = DataGrid(
          data: _sortRows(),
          onRowTap: (rowNumber, rowData) {
            tappedNumber = rowNumber;
            tappedRow = rowData;
          },
        );
        await _pumpGrid(tester, grid);

        // Ascending: numeric order puts 9 first (lexicographic would put 40
        // first), nulls last.
        await tester.tap(find.text('count'));
        await tester.pump();
        expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
        expect(find.byIcon(Icons.arrow_drop_down), findsNothing);

        await tester.tap(find.text('1'));
        await tester.pump();
        expect(tappedNumber, 1);
        expect(tappedRow!['count'], 9);

        // Descending: nulls first.
        await tester.tap(find.text('count'));
        await tester.pump();
        expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
        expect(find.byIcon(Icons.arrow_drop_up), findsNothing);

        await tester.tap(find.text('1'));
        await tester.pump();
        expect(tappedRow!['count'], isNull);

        // Third tap: unsorted, original order, no indicator.
        await tester.tap(find.text('count'));
        await tester.pump();
        expect(find.byIcon(Icons.arrow_drop_up), findsNothing);
        expect(find.byIcon(Icons.arrow_drop_down), findsNothing);

        await tester.tap(find.text('1'));
        await tester.pump();
        expect(tappedRow!['name'], 'banana');
      },
    );

    testWidgets('mixed-type columns fall back to string comparison', (
      tester,
    ) async {
      Map<String, Object?>? tappedRow;
      final grid = DataGrid(
        data: _sortRows(),
        onRowTap: (rowNumber, rowData) =>
            tappedRow = rowData,
      );
      await _pumpGrid(tester, grid);

      await tester.tap(find.text('mixed'));
      await tester.pump();

      // '30' < 'fig' < 'kiwi' < 'pear' — the int 30 wins as a string; a
      // numeric comparison could never rank it against the words at all.
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(tappedRow!['mixed'], 30);
    });

    testWidgets(
      'switching the sort column resets the previous one and case-sensitive '
      'string order ranks Z before a',
      (tester) async {
        Map<String, Object?>? tappedRow;
        final grid = DataGrid(
          data: _sortRows(),
          onRowTap: (rowNumber, rowData) =>
              tappedRow = rowData,
        );
        await _pumpGrid(tester, grid);

        await tester.tap(find.text('name'));
        await tester.pump();
        await tester.tap(find.text('1'));
        await tester.pump();
        expect(tappedRow!['name'], 'Zebra');

        // New column starts its own ascending cycle; exactly one indicator.
        await tester.tap(find.text('count'));
        await tester.pump();
        expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
        expect(find.byIcon(Icons.arrow_drop_down), findsNothing);

        await tester.tap(find.text('1'));
        await tester.pump();
        expect(tappedRow!['count'], 9);
      },
    );

    testWidgets('isCaseSensitive false compares strings case-insensitively', (
      tester,
    ) async {
      Map<String, Object?>? tappedRow;
      final grid = DataGrid(
        data: _sortRows(),
        isCaseSensitive: false,
        onRowTap: (rowNumber, rowData) =>
            tappedRow = rowData,
      );
      await _pumpGrid(tester, grid);

      await tester.tap(find.text('name'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(tappedRow!['name'], 'apple');
    });
  });

  group('updates', () {
    testWidgets('a new data identity is re-copied and re-sorted in place', (
      tester,
    ) async {
      Map<String, Object?>? tappedRow;
      void onRowTap(int rowNumber, Map<String, Object?> rowData) =>
          tappedRow = rowData;

      await _pumpGrid(tester, DataGrid(data: _sortRows(), onRowTap: onRowTap));

      await tester.tap(find.text('count'));
      await tester.pump();

      final newRows = <Map<String, Object?>>[
        <String, Object?>{'name': 'kiwi', 'count': 50, 'mixed': 'a'},
        <String, Object?>{'name': 'fig', 'count': 20, 'mixed': 'b'},
      ];
      await _pumpGrid(tester, DataGrid(data: newRows, onRowTap: onRowTap));

      expect(find.text('3'), findsNothing, reason: 'only two rows remain');
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(
        tappedRow!['name'],
        'fig',
        reason: 'the active ascending count sort must apply to the new data',
      );
    });

    testWidgets('toggling isCaseSensitive re-sorts the same data', (
      tester,
    ) async {
      Map<String, Object?>? tappedRow;
      void onRowTap(int rowNumber, Map<String, Object?> rowData) =>
          tappedRow = rowData;
      final rows = _sortRows();

      await _pumpGrid(tester, DataGrid(data: rows, onRowTap: onRowTap));
      await tester.tap(find.text('name'));
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(tappedRow!['name'], 'Zebra');

      await _pumpGrid(
        tester,
        DataGrid(data: rows, isCaseSensitive: false, onRowTap: onRowTap),
      );
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(tappedRow!['name'], 'apple');
    });

    testWidgets(
      'controller ownership transitions attach, detach, and dispose cleanly',
      (tester) async {
        final rows = _sortRows();
        final horizontal = ScrollController();
        final vertical = ScrollController();
        addTearDown(horizontal.dispose);
        addTearDown(vertical.dispose);

        // Owned → provided: the owned controllers are disposed and the
        // provided ones attach.
        await _pumpGrid(tester, DataGrid(data: rows));
        await _pumpGrid(
          tester,
          DataGrid(
            data: rows,
            horizontalController: horizontal,
            verticalController: vertical,
          ),
        );
        expect(horizontal.hasClients, isTrue);
        expect(vertical.hasClients, isTrue);

        // Provided → owned: the provided controllers detach untouched
        // (caller-owned) and fresh owned ones take over.
        await _pumpGrid(tester, DataGrid(data: rows));
        expect(horizontal.hasClients, isFalse);
        expect(vertical.hasClients, isFalse);

        // Full teardown disposes owned controllers without leaks.
        await tester.pumpWidget(const SizedBox.shrink());
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('scrolling', () {
    testWidgets(
      'row buttons follow the vertical axis and the corner tap animates '
      'both axes home',
      (tester) async {
        final rows = <Map<String, Object?>>[
          for (var i = 1; i <= 30; i++)
            <String, Object?>{
              'alpha': 'a$i',
              'beta': 'b$i',
              'gamma': 'g$i',
              'delta': 'd$i',
              'epsilon': 'e$i',
            },
        ];
        final horizontal = ScrollController();
        final vertical = ScrollController();
        addTearDown(horizontal.dispose);
        addTearDown(vertical.dispose);

        await _pumpGrid(
          tester,
          DataGrid(
            data: rows,
            horizontalController: horizontal,
            verticalController: vertical,
          ),
          width: 400,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('30'), findsNothing);

        vertical.jumpTo(vertical.position.maxScrollExtent);
        await tester.pump();

        expect(
          find.text('1'),
          findsNothing,
          reason: 'the follower column must scroll with the data',
        );
        expect(find.text('30'), findsOneWidget);

        horizontal.jumpTo(100);
        await tester.pump();
        expect(horizontal.offset, 100);

        await tester.tap(find.text('#'));
        await tester.pumpAndSettle();

        expect(horizontal.offset, 0);
        expect(vertical.offset, 0);
        expect(find.text('1'), findsOneWidget);
      },
    );
  });

  group('cell dialog', () {
    testWidgets(
      'tapping a cell shows the full value in a selectable, '
      'barrier-dismissible dialog',
      (tester) async {
        await _pumpGrid(
          tester,
          DataGrid(
            data: const <Map<String, Object?>>[
              <String, Object?>{'word': 'hello', 'extra': null},
              <String, Object?>{'word': 'world', 'extra': 'x'},
            ],
            density: DataDensity.comfortable.toVisualDensity(),
          ),
        );

        await tester.tap(find.text('hello'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('word'),
          ),
          findsOneWidget,
          reason: 'the dialog title is the column name',
        );
        expect(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(SelectableText),
          ),
          findsOneWidget,
        );

        await tester.tapAt(const Offset(5, 5));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets('null cells show a non-selectable italic null dialog', (
      tester,
    ) async {
      await _pumpGrid(
        tester,
        const DataGrid(
          data: <Map<String, Object?>>[
            <String, Object?>{'word': 'hello', 'extra': null},
          ],
        ),
      );

      await tester.tap(find.text('null'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('null'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(SelectableText),
        ),
        findsNothing,
        reason: 'null renders as a styled placeholder, not selectable text',
      );

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
