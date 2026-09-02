// packages/color_grid/test/color_grid_test.dart

import 'package:color_grid/color_grid.dart' show ColorGrid;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The fifteen ARGB values fed to every grid under test, in grid order.
const List<int> _kColors = [
  0xFFFF0000,
  0xFF00FF00,
  0xFF0000FF,
  0xFFFFFF00,
  0xFFFF00FF,
  0xFF00FFFF,
  0xFF880000,
  0xFF008800,
  0xFF000088,
  0xFF888800,
  0xFF880088,
  0xFF008888,
  0xFF444444,
  0xFF888888,
  0xFFCCCCCC,
];

/// The border color the grid uses under [Brightness.light].
const Color _kBorderColorLight = Color(0xFF6A1B9A);

/// The border color the grid uses under [Brightness.dark].
const Color _kBorderColorDark = Color(0xFFCE93D8);

/// The minimum parent width at which the grid keeps its wide gap:
/// four 70px cells, five 8px gaps, and a 2px border on both sides.
const double _kWideModeMinWidth = 4 * 70 + 5 * 8 + 2 * 2;

/// Pumps [grid] centred inside a parent constrained to [width].
Future<void> _pump(
  WidgetTester tester,
  ColorGrid grid, {
  double width = _kWideModeMinWidth,
  Brightness brightness = Brightness.light,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: grid),
        ),
      ),
    ),
  );
}

/// Returns the [Border] painted by the grid's [DecoratedBox].
Border _border(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(ColorGrid),
      matching: find.byType(DecoratedBox),
    ),
  );
  return (box.decoration as BoxDecoration).border! as Border;
}

void main() {
  group('ColorGrid', () {
    testWidgets('asserts when given a color count other than fifteen', (
      tester,
    ) async {
      expect(
        () => ColorGrid(
          colors: const [0xFF000000],
          onColorTapped: (_, _) {},
          onRefreshRequested: () {},
        ),
        throwsAssertionError,
      );
    });

    testWidgets('renders fifteen color cells and one refresh cell', (
      tester,
    ) async {
      await _pump(
        tester,
        ColorGrid(
          colors: _kColors,
          onColorTapped: (_, _) {},
          onRefreshRequested: () {},
        ),
      );

      expect(
        find.descendant(
          of: find.byType(ColorGrid),
          matching: find.byType(ColoredBox),
        ),
        findsNWidgets(15),
      );
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      for (final color in _kColors) {
        expect(
          find.byWidgetPredicate(
            (widget) => widget is ColoredBox && widget.color == Color(color),
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('uses the wide gap when the parent fits wide mode', (
      tester,
    ) async {
      await _pump(
        tester,
        ColorGrid(
          colors: _kColors,
          onColorTapped: (_, _) {},
          onRefreshRequested: () {},
        ),
      );

      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(ColorGrid),
          matching: find.byType(Column),
        ),
      );
      expect(column.spacing, 8);

      final rows = tester
          .widgetList<Row>(
            find.descendant(
              of: find.byType(ColorGrid),
              matching: find.byType(Row),
            ),
          )
          .toList();
      expect(rows, hasLength(4));
      for (final row in rows) {
        expect(row.spacing, 8);
      }

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(ColorGrid),
          matching: find.byType(Padding),
        ),
      );
      expect(padding.padding, const EdgeInsets.all(8));
    });

    testWidgets('drops to the narrow gap when the parent is too narrow', (
      tester,
    ) async {
      await _pump(
        tester,
        ColorGrid(
          colors: _kColors,
          onColorTapped: (_, _) {},
          onRefreshRequested: () {},
        ),
        width: _kWideModeMinWidth - 1,
      );

      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(ColorGrid),
          matching: find.byType(Column),
        ),
      );
      expect(column.spacing, 4);

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(ColorGrid),
          matching: find.byType(Padding),
        ),
      );
      expect(padding.padding, const EdgeInsets.all(4));
    });

    testWidgets('paints the light border color under a light theme', (
      tester,
    ) async {
      await _pump(
        tester,
        ColorGrid(
          colors: _kColors,
          onColorTapped: (_, _) {},
          onRefreshRequested: () {},
        ),
      );

      expect(_border(tester).top.color, _kBorderColorLight);
      expect(_border(tester).top.width, 2);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.refresh)).color,
        _kBorderColorLight,
      );
    });

    testWidgets('paints the dark border color under a dark theme', (
      tester,
    ) async {
      await _pump(
        tester,
        ColorGrid(
          colors: _kColors,
          onColorTapped: (_, _) {},
          onRefreshRequested: () {},
        ),
        brightness: Brightness.dark,
      );

      expect(_border(tester).top.color, _kBorderColorDark);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.refresh)).color,
        _kBorderColorDark,
      );
    });

    testWidgets('tapping a color cell fires onColorTapped with its index '
        'and value', (tester) async {
      int? tappedIndex;
      int? tappedValue;
      await _pump(
        tester,
        ColorGrid(
          colors: _kColors,
          onColorTapped: (index, colorValue) {
            tappedIndex = index;
            tappedValue = colorValue;
          },
          onRefreshRequested: () {},
        ),
      );

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ColoredBox && widget.color == Color(_kColors[6]),
        ),
      );

      expect(tappedIndex, 6);
      expect(tappedValue, _kColors[6]);
    });

    testWidgets('tapping the refresh cell fires onRefreshRequested', (
      tester,
    ) async {
      var refreshes = 0;
      await _pump(
        tester,
        ColorGrid(
          colors: _kColors,
          onColorTapped: (_, _) {},
          onRefreshRequested: () => refreshes++,
        ),
      );

      await tester.tap(find.byIcon(Icons.refresh));

      expect(refreshes, 1);
    });

    testWidgets('refresh cell has an icon sized to half a cell', (
      tester,
    ) async {
      await _pump(
        tester,
        ColorGrid(
          colors: _kColors,
          onColorTapped: (_, _) {},
          onRefreshRequested: () {},
        ),
      );

      expect(tester.widget<Icon>(find.byIcon(Icons.refresh)).size, 35);
      expect(
        tester.getSize(find.byIcon(Icons.refresh).hitTestable()),
        isNotNull,
      );
    });

    testWidgets('cells are fixed at seventy logical pixels', (tester) async {
      await _pump(
        tester,
        ColorGrid(
          colors: _kColors,
          onColorTapped: (_, _) {},
          onRefreshRequested: () {},
        ),
      );

      expect(
        tester.getSize(
          find
              .descendant(
                of: find.byType(ColorGrid),
                matching: find.byType(ColoredBox),
              )
              .first,
        ),
        const Size(70, 70),
      );
    });
  });
}
