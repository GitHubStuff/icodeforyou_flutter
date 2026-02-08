import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:random_color_generator/random_color_generator.dart';

void main() {
  group('RandomColorGenerator.generate', () {
    test('returns a Color instance', () {
      final color = RandomColorGenerator.generate();
      expect(color, isA<Color>());
    });

    test('returns different colors on successive calls', () {
      final colors = List.generate(20, (_) => RandomColorGenerator.generate());
      final unique = colors.toSet();
      // With 20 random colors, we should get more than 1 unique value.
      expect(unique.length, greaterThan(1));
    });

    test('default alpha is fully opaque', () {
      // Generate several and verify all are fully opaque.
      for (var i = 0; i < 10; i++) {
        final color = RandomColorGenerator.generate();
        final alphaInt = (color.a * 255.0).round();
        expect(alphaInt, equals(255));
      }
    });

    test('custom alpha value is applied', () {
      final color = RandomColorGenerator.generate(alpha: 128);
      final alphaInt = (color.a * 255.0).round();
      // HSL conversion may introduce minor rounding; allow ±1.
      expect(alphaInt, closeTo(128, 1));
    });

    test('alpha of 0 produces fully transparent color', () {
      final color = RandomColorGenerator.generate(alpha: 0);
      final alphaInt = (color.a * 255.0).round();
      expect(alphaInt, equals(0));
    });

    test('generated colors have constrained lightness (35-65%)', () {
      for (var i = 0; i < 50; i++) {
        final color = RandomColorGenerator.generate();
        final hsl = HSLColor.fromColor(color);
        // Allow small floating-point tolerance.
        expect(hsl.lightness, greaterThanOrEqualTo(0.34));
        expect(hsl.lightness, lessThanOrEqualTo(0.66));
      }
    });

    test('generated colors have constrained saturation (40-80%)', () {
      for (var i = 0; i < 50; i++) {
        final color = RandomColorGenerator.generate();
        final hsl = HSLColor.fromColor(color);
        expect(hsl.saturation, greaterThanOrEqualTo(0.39));
        expect(hsl.saturation, lessThanOrEqualTo(0.81));
      }
    });

    test('generated colors span diverse hues', () {
      final hues = <double>[];
      for (var i = 0; i < 100; i++) {
        final color = RandomColorGenerator.generate();
        final hsl = HSLColor.fromColor(color);
        hues.add(hsl.hue);
      }
      final minHue = hues.reduce((a, b) => a < b ? a : b);
      final maxHue = hues.reduce((a, b) => a > b ? a : b);
      // 100 samples should span a wide range of hues.
      expect(maxHue - minHue, greaterThan(90));
    });

    test('alpha of 255 is equivalent to default', () {
      // Just verifies the path works without error.
      final color = RandomColorGenerator.generate(alpha: 255);
      final alphaInt = (color.a * 255.0).round();
      expect(alphaInt, equals(255));
    });

    test('mid-range alpha produces semi-transparent color', () {
      final color = RandomColorGenerator.generate(alpha: 200);
      final alphaInt = (color.a * 255.0).round();
      expect(alphaInt, closeTo(200, 1));
    });
  });
}
