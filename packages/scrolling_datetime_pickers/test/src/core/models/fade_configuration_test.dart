// test/src/core/models/fade_configuration_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/models/fade_configuration.dart';

void main() {
  group('FadeConfiguration Constructor', () {
    test('should create with default values', () {
      final config = FadeConfiguration();

      expect(config.enabled, isTrue);
      expect(config.fadeDistance, 40.0);
      expect(config.fadeCurve, Curves.linear);
      expect(config.topColors.length, 2);
      expect(config.topColors[0], const Color(0xFF000033));
      expect(config.topColors[1], const Color(0x00000033));
      expect(config.bottomColors.length, 2);
      expect(config.bottomColors[0], const Color(0x00000033));
      expect(config.bottomColors[1], const Color(0xFF000033));
      expect(config.stops, [0.0, 1.0]);
      expect(config.selectedAlwaysOpaque, isTrue);
    });

    test('should create with custom values', () {
      final config = FadeConfiguration(
        enabled: false,
        fadeDistance: 60.0,
        fadeCurve: Curves.easeIn,
        topColors: [Colors.red, Colors.transparent],
        bottomColors: [Colors.transparent, Colors.blue],
        stops: [0.0, 1.0],
        selectedAlwaysOpaque: false,
      );

      expect(config.enabled, isFalse);
      expect(config.fadeDistance, 60.0);
      expect(config.fadeCurve, Curves.easeIn);
      expect(config.topColors, [Colors.red, Colors.transparent]);
      expect(config.bottomColors, [Colors.transparent, Colors.blue]);
      expect(config.stops, [0.0, 1.0]);
      expect(config.selectedAlwaysOpaque, isFalse);
    });

    test('should enforce positive fade distance', () {
      expect(() => FadeConfiguration(fadeDistance: 0.0), throwsAssertionError);
      expect(() => FadeConfiguration(fadeDistance: -1.0), throwsAssertionError);
      expect(() => FadeConfiguration(fadeDistance: 10.0), returnsNormally);
    });
  });

  group('FadeConfiguration Factories', () {
    test('defaultConfig should return default configuration', () {
      final config = FadeConfiguration.defaultConfig();

      expect(config.enabled, isTrue);
      expect(config.fadeDistance, 40.0);
      expect(config.fadeCurve, Curves.linear);
      expect(config.selectedAlwaysOpaque, isTrue);
    });

    test('noFade should disable fade effect', () {
      final config = FadeConfiguration.noFade();

      expect(config.enabled, isFalse);
      expect(config.fadeDistance, 40.0);
      expect(config.fadeCurve, Curves.linear);
    });

    test('withDistance should set custom distance and curve', () {
      final config = FadeConfiguration.withDistance(
        distance: 80.0,
        curve: Curves.easeOut,
      );

      expect(config.enabled, isTrue);
      expect(config.fadeDistance, 80.0);
      expect(config.fadeCurve, Curves.easeOut);
    });

    test('easeIn should use easeIn curve', () {
      final config = FadeConfiguration.easeIn();

      expect(config.fadeCurve, Curves.easeIn);
      expect(config.fadeDistance, 40.0);

      final customDistance = FadeConfiguration.easeIn(fadeDistance: 50.0);
      expect(customDistance.fadeCurve, Curves.easeIn);
      expect(customDistance.fadeDistance, 50.0);
    });

    test('easeOut should use easeOut curve', () {
      final config = FadeConfiguration.easeOut();

      expect(config.fadeCurve, Curves.easeOut);
      expect(config.fadeDistance, 40.0);

      final customDistance = FadeConfiguration.easeOut(fadeDistance: 50.0);
      expect(customDistance.fadeCurve, Curves.easeOut);
      expect(customDistance.fadeDistance, 50.0);
    });
  });

  group('FadeConfiguration Gradients', () {
    test('topGradient should create correct gradient', () {
      final config = FadeConfiguration();
      final gradient = config.topGradient;

      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      expect(gradient.colors, config.topColors);
      expect(gradient.stops, config.stops);
    });

    test('bottomGradient should create correct gradient', () {
      final config = FadeConfiguration();
      final gradient = config.bottomGradient;

      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      expect(gradient.colors, config.bottomColors);
      expect(gradient.stops, config.stops);
    });
  });

  group('FadeConfiguration Validation', () {
    test('isValid should validate configuration', () {
      final valid = FadeConfiguration();
      expect(valid.isValid, isTrue);

      final invalid = FadeConfiguration(
        topColors: [Colors.red],
        bottomColors: [Colors.blue],
        stops: [0.0],
      );
      expect(invalid.isValid, isFalse);

      final mismatch = FadeConfiguration(
        topColors: [Colors.red, Colors.blue],
        bottomColors: [Colors.green, Colors.yellow],
        stops: [0.0],
      );
      expect(mismatch.isValid, isFalse);
    });
  });

  group('FadeConfiguration copyWith', () {
    test('should copy with all new values', () {
      final original = FadeConfiguration();

      final modified = original.copyWith(
        enabled: false,
        fadeDistance: 100.0,
        fadeCurve: Curves.bounceIn,
        topColors: [Colors.green, Colors.transparent],
        bottomColors: [Colors.transparent, Colors.red],
        stops: [0.0, 0.5],
        selectedAlwaysOpaque: false,
      );

      expect(modified.enabled, isFalse);
      expect(modified.fadeDistance, 100.0);
      expect(modified.fadeCurve, Curves.bounceIn);
      expect(modified.topColors, [Colors.green, Colors.transparent]);
      expect(modified.bottomColors, [Colors.transparent, Colors.red]);
      expect(modified.stops, [0.0, 0.5]);
      expect(modified.selectedAlwaysOpaque, isFalse);
    });

    test('should preserve unmodified values', () {
      final original = FadeConfiguration(
        fadeDistance: 50.0,
        fadeCurve: Curves.easeInOut,
      );

      final copy = original.copyWith();

      expect(copy.enabled, original.enabled);
      expect(copy.fadeDistance, original.fadeDistance);
      expect(copy.fadeCurve, original.fadeCurve);
      expect(copy.topColors, original.topColors);
      expect(copy.bottomColors, original.bottomColors);
      expect(copy.stops, original.stops);
      expect(copy.selectedAlwaysOpaque, original.selectedAlwaysOpaque);
    });
  });

  group('FadeConfiguration Equality', () {
    test('should execute full equality operator', () {
      // Use non-const to avoid const canonicalization
      final config1 = FadeConfiguration();
      final config2 = FadeConfiguration();

      // Explicitly test == operator
      expect(config1 == config2, isTrue);
      expect(config1.hashCode == config2.hashCode, isTrue);
    });

    test('should detect inequality in all fields', () {
      final base = FadeConfiguration();

      // Test each field difference
      expect(base == FadeConfiguration(enabled: false), isFalse);
      expect(base == FadeConfiguration(fadeDistance: 50.0), isFalse);
      expect(base == FadeConfiguration(fadeCurve: Curves.easeIn), isFalse);
      expect(base == FadeConfiguration(selectedAlwaysOpaque: false), isFalse);
      expect(
          base ==
              FadeConfiguration(
                topColors: [Colors.red, Colors.blue],
              ),
          isFalse);
      expect(
          base ==
              FadeConfiguration(
                bottomColors: [Colors.red, Colors.blue],
              ),
          isFalse);
      expect(
          base ==
              FadeConfiguration(
                stops: [0.0, 0.5],
              ),
          isFalse);
    });

    test('should handle list length differences', () {
      final config1 = FadeConfiguration(
        topColors: [Colors.red, Colors.blue],
        bottomColors: [Colors.green, Colors.yellow],
        stops: [0.0, 1.0],
      );

      final config2 = FadeConfiguration(
        topColors: [Colors.red, Colors.blue, Colors.green],
        bottomColors: [Colors.green, Colors.yellow, Colors.red],
        stops: [0.0, 0.5, 1.0],
      );

      expect(config1 == config2, isFalse);
    });

    test('should handle list content differences', () {
      final config1 = FadeConfiguration(
        topColors: [Colors.red, Colors.blue],
      );

      final config2 = FadeConfiguration(
        topColors: [Colors.red, Colors.green],
      );

      expect(config1 == config2, isFalse);
    });

    test('should handle identical instances', () {
      final config = FadeConfiguration();
      expect(config == config, isTrue);
    });
  });
}
