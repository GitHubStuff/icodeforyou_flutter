// packages/rail_navigation/test/src/widgets/rail_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_navigation/src/widgets/rail_widget.dart';

Widget _wrap(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: child),
  );
}

Flex _railFlex(WidgetTester tester) {
  return tester.widget<Flex>(
    find.descendant(
      of: find.byType(RailWidget),
      matching: find.byType(Flex),
    ),
  );
}

SafeArea _railSafeArea(WidgetTester tester) {
  return tester.widget<SafeArea>(
    find.descendant(
      of: find.byType(RailWidget),
      matching: find.byType(SafeArea),
    ),
  );
}

Material _railMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find.descendant(
      of: find.byType(RailWidget),
      matching: find.byType(Material),
    ),
  );
}

void main() {
  group('RailPlacement', () {
    test('bottom lays out horizontally', () {
      expect(RailPlacement.bottom.axis, Axis.horizontal);
    });

    test('left lays out vertically', () {
      expect(RailPlacement.left.axis, Axis.vertical);
    });

    test('right lays out vertically', () {
      expect(RailPlacement.right.axis, Axis.vertical);
    });
  });

  group('RailWidget', () {
    testWidgets(
      'bottom placement is horizontal, space-evenly, 80 tall, and skips the '
      'top inset',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const Align(
              alignment: Alignment.bottomCenter,
              child: RailWidget(
                children: [SizedBox(width: 48, height: 48)],
              ),
            ),
          ),
        );

        final flex = _railFlex(tester);
        expect(flex.direction, Axis.horizontal);
        expect(flex.mainAxisAlignment, MainAxisAlignment.spaceEvenly);

        final safeArea = _railSafeArea(tester);
        expect(safeArea.top, isFalse);
        expect(safeArea.left, isTrue);
        expect(safeArea.right, isTrue);
        expect(safeArea.bottom, isTrue);

        expect(tester.getSize(find.byType(RailWidget)).height, 80);
      },
    );

    testWidgets(
      'left placement is vertical, packed at the start, 80 wide, and skips '
      'the right inset',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const Align(
              alignment: Alignment.centerLeft,
              child: RailWidget(
                placement: RailPlacement.left,
                children: [SizedBox(width: 48, height: 48)],
              ),
            ),
          ),
        );

        final flex = _railFlex(tester);
        expect(flex.direction, Axis.vertical);
        expect(flex.mainAxisAlignment, MainAxisAlignment.start);

        final safeArea = _railSafeArea(tester);
        expect(safeArea.top, isTrue);
        expect(safeArea.left, isTrue);
        expect(safeArea.right, isFalse);
        expect(safeArea.bottom, isTrue);

        expect(tester.getSize(find.byType(RailWidget)).width, 80);
      },
    );

    testWidgets('right placement is vertical and skips the left inset', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const Align(
            alignment: Alignment.centerRight,
            child: RailWidget(
              placement: RailPlacement.right,
              children: [SizedBox(width: 48, height: 48)],
            ),
          ),
        ),
      );

      final flex = _railFlex(tester);
      expect(flex.direction, Axis.vertical);
      expect(flex.mainAxisAlignment, MainAxisAlignment.start);

      final safeArea = _railSafeArea(tester);
      expect(safeArea.top, isTrue);
      expect(safeArea.left, isFalse);
      expect(safeArea.right, isTrue);
      expect(safeArea.bottom, isTrue);

      expect(tester.getSize(find.byType(RailWidget)).width, 80);
    });

    testWidgets('an explicit alignment overrides the placement default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const Align(
            alignment: Alignment.bottomCenter,
            child: RailWidget(
              alignment: MainAxisAlignment.center,
              children: [SizedBox(width: 48, height: 48)],
            ),
          ),
        ),
      );

      expect(_railFlex(tester).mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('applies the provided spacing between children', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const Align(
            alignment: Alignment.centerLeft,
            child: RailWidget(
              placement: RailPlacement.left,
              spacing: 16,
              children: [
                SizedBox(width: 48, height: 48),
                SizedBox(width: 48, height: 48),
              ],
            ),
          ),
        ),
      );

      expect(_railFlex(tester).spacing, 16);
    });

    testWidgets('paints the provided background color', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Align(
            alignment: Alignment.bottomCenter,
            child: RailWidget(
              backgroundColor: Colors.amber,
              children: [SizedBox(width: 48, height: 48)],
            ),
          ),
        ),
      );

      expect(_railMaterial(tester).color, Colors.amber);
    });

    testWidgets('falls back to surfaceContainer when backgroundColor is null', (
      tester,
    ) async {
      final theme = ThemeData();
      await tester.pumpWidget(
        _wrap(
          const Align(
            alignment: Alignment.bottomCenter,
            child: RailWidget(
              children: [SizedBox(width: 48, height: 48)],
            ),
          ),
          theme: theme,
        ),
      );

      expect(
        _railMaterial(tester).color,
        theme.colorScheme.surfaceContainer,
      );
    });

    testWidgets('applies a custom extent as the cross-axis size', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const Align(
            alignment: Alignment.bottomCenter,
            child: RailWidget(
              extent: 64,
              children: [SizedBox(width: 48, height: 48)],
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(RailWidget)).height, 64);
    });
  });
}
