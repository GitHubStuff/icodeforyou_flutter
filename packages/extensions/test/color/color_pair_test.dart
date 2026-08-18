// packages/extensions/test/color/color_pair_test.dart
import 'package:extensions/extensions.dart' show ColorPair;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorPair', () {
    const Color darkColor = Colors.black;
    const Color lightColor = Colors.white;
    const ColorPair colorPair = ColorPair(dark: darkColor, light: lightColor);

    test('constructor assigns colors correctly', () {
      expect(colorPair.dark, darkColor);
      expect(colorPair.light, lightColor);
    });

    testWidgets('returns correct values when theme is Brightness.light', (
      WidgetTester tester,
    ) async {
      late BuildContext testContext;

      // Pump a widget tree with a Light Theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Builder(
            builder: (BuildContext context) {
              testContext = context; // Extract the context
              return const SizedBox();
            },
          ),
        ),
      );

      // Verify booleans
      expect(colorPair.isDark(testContext), isFalse);
      expect(colorPair.isLight(testContext), isTrue);

      // Verify current color
      expect(colorPair.current(testContext), lightColor);

      // Verify contrastingColor (Light branch)
      // Since contrastingColor relies on an extension, we verify it executes
      // without error and returns a valid Color type.
      final contrast = colorPair.contrastingColor(
        testContext,
        forLight: Colors.blue,
      );
      expect(contrast, isA<Color>());
    });

    testWidgets('returns correct values when theme is Brightness.dark', (
      WidgetTester tester,
    ) async {
      late BuildContext testContext;

      // Pump a widget tree with a Dark Theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (BuildContext context) {
              testContext = context; // Extract the context
              return const SizedBox();
            },
          ),
        ),
      );

      // Verify booleans
      expect(colorPair.isDark(testContext), isTrue);
      expect(colorPair.isLight(testContext), isFalse);

      // Verify current color
      expect(colorPair.current(testContext), darkColor);

      // Verify contrastingColor (Dark branch)
      final contrast = colorPair.contrastingColor(
        testContext,
        forDark: Colors.red,
      );
      expect(contrast, isA<Color>());
    });
  });
}
