// test/src/core/models/fade_configuration_test.dart

// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/models/fade_configuration.dart';

void main() {
  group('FadeConfiguration Constructor', () {
    test('should create with default values', () {
      const config = FadeConfiguration();

      expect(config.enabled, isTrue);
      expect(config.fadeDistance, 40.0);
      expect(config.fadeCurve, Curves.linear);
      expect(config.topColors, const [Color(0xFF000033), Color(0x00000033)]);
      expect(
          config.bottomColors, const [Color(0x00000033), Color(0xFF000033)]);
      expect(config.stops, const [0.0, 1.0]);
      expect(config.selectedAlwaysOpaque, isTrue);
    });

    test('should create with custom values', () {
      const config = FadeConfiguration(
        enabled: false,
        fadeDistance: 60,
        fadeCurve: Curves.easeInOut,
        topColors: [Colors.red, Colors.blue],
        bottomColors: [Colors.green, Colors.yellow],
        stops: [0.2, 0.8],
        selectedAlwaysOpaque: false,
      );

      expect(config.enabled, isFalse);
      expect(config.fadeDistance, 60.0);
      expect(config.fadeCurve, Curves.easeInOut);
      expect(config.topColors, const [Colors.red, Colors.blue]);
      expect(config.bottomColors, const [Colors.green, Colors.yellow]);
      expect(config.stops, const [0.2, 0.8]);
      expect(config.selectedAlwaysOpaque, isFalse);
    });

    test('should enforce positive fadeDistance', () {
      expect(() => FadeConfiguration(fadeDistance: 0), throwsAssertionError);
      expect(() => FadeConfiguration(fadeDistance: -1), throwsAssertionError);
      expect(() => FadeConfiguration(fadeDistance: -0.001), throwsAssertionError);
      expect(() => const FadeConfiguration(fadeDistance: 0.1), returnsNormally);
      expect(() => const FadeConfiguration(fadeDistance: 1), returnsNormally);
    });
  });

  group('FadeConfiguration Factories', () {
    test('light should return white fade colors', () {
      final config = FadeConfiguration.light();

      expect(config.enabled, isTrue);
      expect(config.fadeDistance, 40.0);
      expect(config.fadeCurve, Curves.linear);
      expect(config.topColors, const [Color(0xFFFFFFFF), Color(0x00FFFFFF)]);
      expect(
          config.bottomColors, const [Color(0x00FFFFFF), Color(0xFFFFFFFF)]);
      expect(config.stops, const [0.0, 1.0]);
      expect(config.selectedAlwaysOpaque, isTrue);
    });

    test('dark should return dark fade colors', () {
      final config = FadeConfiguration.dark();

      expect(config.enabled, isTrue);
      expect(config.fadeDistance, 40.0);
      expect(config.fadeCurve, Curves.linear);
      expect(config.topColors, const [Color(0xFF1E1E1E), Color(0x001E1E1E)]);
      expect(
          config.bottomColors, const [Color(0x001E1E1E), Color(0xFF1E1E1E)]);
      expect(config.stops, const [0.0, 1.0]);
      expect(config.selectedAlwaysOpaque, isTrue);
    });

    test('forBackground should generate fade from color', () {
      final config = FadeConfiguration.forBackground(Colors.purple);

      expect(config.enabled, isTrue);
      expect(config.fadeDistance, 40.0);
      expect(config.topColors.length, 2);
      expect(config.topColors[0], Colors.purple);
      expect(config.topColors[1].a, 0.0);
      expect(config.bottomColors.length, 2);
      expect(config.bottomColors[0].a, 0.0);
      expect(config.bottomColors[1], Colors.purple);
    });

    test('forBackground should preserve RGB values in transparent color', () {
      const testColor = Color(0xFFAABBCC);
      final config = FadeConfiguration.forBackground(testColor);

      final transparent = config.topColors[1];
      expect(transparent.a, 0.0);
      // RGB values should be preserved
      expect(transparent.r, closeTo(testColor.r, 0.01));
      expect(transparent.g, closeTo(testColor.g, 0.01));
      expect(transparent.b, closeTo(testColor.b, 0.01));
    });

    test('noFade should return disabled configuration', () {
      final config = FadeConfiguration.noFade();

      expect(config.enabled, isFalse);
      expect(config.fadeDistance, 40.0);
      expect(config.fadeCurve, Curves.linear);
      expect(config.selectedAlwaysOpaque, isTrue);
    });
  });

  group('FadeConfiguration Gradient Properties', () {
    test('topGradient should return correct LinearGradient', () {
      const config = FadeConfiguration(
        topColors: [Colors.red, Colors.blue],
        stops: [0.1, 0.9],
      );

      final gradient = config.topGradient;

      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      expect(gradient.colors, const [Colors.red, Colors.blue]);
      expect(gradient.stops, const [0.1, 0.9]);
    });

    test('bottomGradient should return correct LinearGradient', () {
      const config = FadeConfiguration(
        bottomColors: [Colors.green, Colors.yellow],
        stops: [0.2, 0.8],
      );

      final gradient = config.bottomGradient;

      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      expect(gradient.colors, const [Colors.green, Colors.yellow]);
      expect(gradient.stops, const [0.2, 0.8]);
    });

    test('gradients should use default colors and stops', () {
      const config = FadeConfiguration();

      final topGradient = config.topGradient;
      final bottomGradient = config.bottomGradient;

      expect(topGradient.colors, config.topColors);
      expect(topGradient.stops, config.stops);
      expect(bottomGradient.colors, config.bottomColors);
      expect(bottomGradient.stops, config.stops);
    });
  });
}
