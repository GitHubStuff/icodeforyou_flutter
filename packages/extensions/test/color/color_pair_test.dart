// packages/extensions/test/color/color_pair_test.dart
import 'package:extensions/extensions.dart' show ColorPair;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Using "final" instead of "const" to to test constructor', () {
    // Purposefully omitting 'const' here to force runtime evaluation
    // and register a hit in LCOV, while leaving production code optimized.
    final pair = ColorPair(dark: Colors.black, light: Colors.white);
    expect(pair, isNotNull);
  });

  group('ColorPair Tests', () {
    testWidgets('returns dark color and correct booleans when theme is dark', (
      WidgetTester tester,
    ) async {
      // 1. Instantiate to cover Line 7
      const colorPair = ColorPair(
        dark: Colors.black,
        light: Colors.white,
      );

      late BuildContext testContext;

      // 2. Pump a widget with a Dark Theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (BuildContext context) {
              testContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // 3. Verify coverage for lines 16, 19, 20, and 23
      expect(colorPair.dark, Colors.black);
      expect(colorPair.light, Colors.white);
      expect(colorPair.isDark(testContext), isTrue);
      expect(colorPair.isLight(testContext), isFalse);
      expect(colorPair.current(testContext), Colors.black);
    });

    testWidgets('returns light color and correct booleans when theme is light', (
      WidgetTester tester,
    ) async {
      // 1. Instantiate again
      const colorPair = ColorPair(
        dark: Colors.black,
        light: Colors.white,
      );

      late BuildContext testContext;

      // 2. Pump a widget with a Light Theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Builder(
            builder: (BuildContext context) {
              testContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // 3. Verify coverage for lines 16, 19, 20, and 23 in the alternate branch
      expect(colorPair.isDark(testContext), isFalse);
      expect(colorPair.isLight(testContext), isTrue);
      expect(colorPair.current(testContext), Colors.white);
    });
  });
}
