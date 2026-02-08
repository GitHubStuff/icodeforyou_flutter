import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:random_color_generator/random_color_generator.dart';

void main() {
  group('RandomColorGenerator.contrastingTextColor', () {
    test('returns black for white background', () {
      const white = Color(0xFFFFFFFF);
      final result = RandomColorGenerator.contrastingTextColor(white);
      expect(result, equals(Colors.black));
    });

    test('returns white for black background', () {
      const black = Color(0xFF000000);
      final result = RandomColorGenerator.contrastingTextColor(black);
      expect(result, equals(Colors.white));
    });

    test('returns black for light yellow', () {
      const lightYellow = Color(0xFFFFFF00);
      final result = RandomColorGenerator.contrastingTextColor(lightYellow);
      expect(result, equals(Colors.black));
    });

    test('returns white for dark blue', () {
      const darkBlue = Color(0xFF000080);
      final result = RandomColorGenerator.contrastingTextColor(darkBlue);
      expect(result, equals(Colors.white));
    });

    test('returns white for dark red', () {
      const darkRed = Color(0xFF800000);
      final result = RandomColorGenerator.contrastingTextColor(darkRed);
      expect(result, equals(Colors.white));
    });

    test('returns white for dark green', () {
      const darkGreen = Color(0xFF006400);
      final result = RandomColorGenerator.contrastingTextColor(darkGreen);
      expect(result, equals(Colors.white));
    });

    test('returns black for light gray', () {
      const lightGray = Color(0xFFCCCCCC);
      final result = RandomColorGenerator.contrastingTextColor(lightGray);
      expect(result, equals(Colors.black));
    });

    test('returns white for dark gray', () {
      const darkGray = Color(0xFF333333);
      final result = RandomColorGenerator.contrastingTextColor(darkGray);
      expect(result, equals(Colors.white));
    });

    test('returns black for light cyan', () {
      const lightCyan = Color(0xFF00FFFF);
      final result = RandomColorGenerator.contrastingTextColor(lightCyan);
      expect(result, equals(Colors.black));
    });

    test('returns white for dark purple', () {
      const darkPurple = Color(0xFF301050);
      final result = RandomColorGenerator.contrastingTextColor(darkPurple);
      expect(result, equals(Colors.white));
    });

    test('returns black for light green (lime)', () {
      const lime = Color(0xFF00FF00);
      final result = RandomColorGenerator.contrastingTextColor(lime);
      expect(result, equals(Colors.black));
    });

    test('always returns either black or white', () {
      for (var i = 0; i < 50; i++) {
        final color = RandomColorGenerator.generate();
        final result = RandomColorGenerator.contrastingTextColor(color);
        expect(
          result == Colors.black || result == Colors.white,
          isTrue,
          reason: 'Expected black or white, got $result',
        );
      }
    });

    test('result is consistent for the same input color', () {
      const color = Color(0xFF8844AA);
      final first = RandomColorGenerator.contrastingTextColor(color);
      final second = RandomColorGenerator.contrastingTextColor(color);
      expect(first, equals(second));
    });

    test('returns black for Colors.white', () {
      final result = RandomColorGenerator.contrastingTextColor(Colors.white);
      expect(result, equals(Colors.black));
    });

    test('returns white for Colors.black', () {
      final result = RandomColorGenerator.contrastingTextColor(Colors.black);
      expect(result, equals(Colors.white));
    });

    test('handles the luminance boundary correctly', () {
      // A color right at the 0.5 luminance threshold.
      // luminance > 0.5 => black, luminance <= 0.5 => white.
      // Gray #808080 has luminance ~0.216 => white.
      const midGray = Color(0xFF808080);
      final result = RandomColorGenerator.contrastingTextColor(midGray);
      expect(result, equals(Colors.white));
    });

    test('returns black for light pink', () {
      const lightPink = Color(0xFFFFB6C1);
      final result = RandomColorGenerator.contrastingTextColor(lightPink);
      expect(result, equals(Colors.black));
    });

    test('returns white for dark teal', () {
      const darkTeal = Color(0xFF004040);
      final result = RandomColorGenerator.contrastingTextColor(darkTeal);
      expect(result, equals(Colors.white));
    });
  });
}
