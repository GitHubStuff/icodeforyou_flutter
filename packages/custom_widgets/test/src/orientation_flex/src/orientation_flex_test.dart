// packages/custom_widgets/test/src/orientation_flex/src/orientation_flex_test.dart

import 'package:custom_widgets/custom_widgets.dart' show OrientationFlex;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A pair of inert children for the flex under test.
const List<Widget> _kChildren = [
  SizedBox(width: 10, height: 10),
  SizedBox(width: 10, height: 10),
];

/// Pumps [flex] under a fixed [MediaQuery] viewport of [size].
Future<void> _pump(WidgetTester tester, Size size, OrientationFlex flex) {
  return tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(textDirection: TextDirection.ltr, child: flex),
    ),
  );
}

/// The [Flex] rendered by the widget under test.
Flex _flexOf(WidgetTester tester) => tester.widget<Flex>(find.byType(Flex));

void main() {
  group('OrientationFlex', () {
    testWidgets('a landscape viewport resolves to forLandscape',
        (tester) async {
      await _pump(
        tester,
        const Size(800, 400),
        const OrientationFlex(children: _kChildren),
      );

      expect(_flexOf(tester).direction, Axis.horizontal);
    });

    testWidgets('a portrait viewport resolves to forPortrait',
        (tester) async {
      await _pump(
        tester,
        const Size(400, 800),
        const OrientationFlex(children: _kChildren),
      );

      expect(_flexOf(tester).direction, Axis.vertical);
    });

    testWidgets('an exactly square viewport resolves to forSquare',
        (tester) async {
      await _pump(
        tester,
        const Size(500, 500),
        const OrientationFlex(
          forSquare: Axis.horizontal,
          children: _kChildren,
        ),
      );

      expect(_flexOf(tester).direction, Axis.horizontal);
    });

    testWidgets('squareTolerance widens the square band', (tester) async {
      await _pump(
        tester,
        const Size(1000, 990),
        const OrientationFlex(
          squareTolerance: 0.02,
          forSquare: Axis.horizontal,
          forLandscape: Axis.vertical,
          children: _kChildren,
        ),
      );

      expect(_flexOf(tester).direction, Axis.horizontal);
    });

    testWidgets('the trigger is decoupled from the resolved axis',
        (tester) async {
      await _pump(
        tester,
        const Size(800, 400),
        const OrientationFlex(
          forLandscape: Axis.vertical,
          children: _kChildren,
        ),
      );

      expect(_flexOf(tester).direction, Axis.vertical);
    });

    testWidgets('forwards all pass-through Flex parameters', (tester) async {
      await _pump(
        tester,
        const Size(800, 400),
        const OrientationFlex(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          spacing: 4,
          textDirection: TextDirection.rtl,
          verticalDirection: VerticalDirection.up,
          textBaseline: TextBaseline.alphabetic,
          children: _kChildren,
        ),
      );

      final flex = _flexOf(tester);
      expect(flex.mainAxisAlignment, MainAxisAlignment.end);
      expect(flex.mainAxisSize, MainAxisSize.min);
      expect(flex.crossAxisAlignment, CrossAxisAlignment.baseline);
      expect(flex.spacing, 4);
      expect(flex.textDirection, TextDirection.rtl);
      expect(flex.verticalDirection, VerticalDirection.up);
      expect(flex.textBaseline, TextBaseline.alphabetic);
    });

    test('asserts on a negative squareTolerance', () {
      expect(
        () => OrientationFlex(squareTolerance: -1, children: _kChildren),
        throwsAssertionError,
      );
    });
  });
}
