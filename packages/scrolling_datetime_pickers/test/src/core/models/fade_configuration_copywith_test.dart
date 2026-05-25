// test/src/core/models/fade_configuration_copywith_test.dart

// ignore_for_file: document_ignores, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/models/fade_configuration.dart';

void main() {
  group('FadeConfiguration copyWith', () {
    test('should copy with all parameters changed', () {
      const original = FadeConfiguration();

      final modified = original.copyWith(
        enabled: false,
        fadeDistance: 80,
        fadeCurve: Curves.bounceIn,
        topColors: [Colors.red, Colors.blue],
        bottomColors: [Colors.green, Colors.yellow],
        stops: [0.25, 0.75],
        selectedAlwaysOpaque: false,
      );

      expect(modified.enabled, isFalse);
      expect(modified.fadeDistance, 80.0);
      expect(modified.fadeCurve, Curves.bounceIn);
      expect(modified.topColors, const [Colors.red, Colors.blue]);
      expect(modified.bottomColors, const [Colors.green, Colors.yellow]);
      expect(modified.stops, const [0.25, 0.75]);
      expect(modified.selectedAlwaysOpaque, isFalse);
    });

    test('should preserve all original values when no params', () {
      const original = FadeConfiguration(
        enabled: false,
        fadeDistance: 50,
        fadeCurve: Curves.easeOut,
        topColors: [Colors.orange, Colors.pink],
        bottomColors: [Colors.cyan, Colors.teal],
        stops: [0.1, 0.9],
        selectedAlwaysOpaque: false,
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

    test('should copy individual parameters', () {
      const original = FadeConfiguration(
        
      );

      final enabledOnly = original.copyWith(enabled: false);
      expect(enabledOnly.enabled, isFalse);
      expect(enabledOnly.fadeDistance, 40.0);

      final fadeDistanceOnly = original.copyWith(fadeDistance: 100);
      expect(fadeDistanceOnly.enabled, isTrue);
      expect(fadeDistanceOnly.fadeDistance, 100.0);

      final fadeCurveOnly = original.copyWith(fadeCurve: Curves.elasticIn);
      expect(fadeCurveOnly.fadeCurve, Curves.elasticIn);

      final topColorsOnly =
          original.copyWith(topColors: [Colors.amber, Colors.lime]);
      expect(topColorsOnly.topColors, const [Colors.amber, Colors.lime]);

      final bottomColorsOnly =
          original.copyWith(bottomColors: [Colors.indigo, Colors.brown]);
      expect(bottomColorsOnly.bottomColors, const [Colors.indigo, Colors.brown]);

      final stopsOnly = original.copyWith(stops: [0.3, 0.7]);
      expect(stopsOnly.stops, const [0.3, 0.7]);

      final selectedAlwaysOpaqueOnly =
          original.copyWith(selectedAlwaysOpaque: false);
      expect(selectedAlwaysOpaqueOnly.selectedAlwaysOpaque, isFalse);
    });
  });

  group('FadeConfiguration Equality', () {
    test('should be equal to itself', () {
      const config = FadeConfiguration();
      expect(config, equals(config));
      expect(config.hashCode, equals(config.hashCode));
    });

    test('identical should return true for same instance', () {
      const config = FadeConfiguration();
      expect(identical(config, config), isTrue);
    });

    test('should be equal when all properties match', () {
      const config1 = FadeConfiguration(
        enabled: false,
        fadeDistance: 55,
        fadeCurve: Curves.decelerate,
        topColors: [Colors.purple, Colors.deepPurple],
        bottomColors: [Colors.deepOrange, Colors.orange],
        stops: [0.15, 0.85],
        selectedAlwaysOpaque: false,
      );

      const config2 = FadeConfiguration(
        enabled: false,
        fadeDistance: 55,
        fadeCurve: Curves.decelerate,
        topColors: [Colors.purple, Colors.deepPurple],
        bottomColors: [Colors.deepOrange, Colors.orange],
        stops: [0.15, 0.85],
        selectedAlwaysOpaque: false,
      );

      expect(config1, equals(config2));
      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('should not be equal when enabled differs', () {
      const config1 = FadeConfiguration();
      const config2 = FadeConfiguration(enabled: false);
      expect(config1, isNot(equals(config2)));
    });

    test('should not be equal when fadeDistance differs', () {
      const config1 = FadeConfiguration();
      const config2 = FadeConfiguration(fadeDistance: 50);
      expect(config1, isNot(equals(config2)));
    });

    test('should not be equal when fadeCurve differs', () {
      const config1 = FadeConfiguration();
      const config2 = FadeConfiguration(fadeCurve: Curves.easeIn);
      expect(config1, isNot(equals(config2)));
    });

    test('should not be equal when topColors differs', () {
      const config1 = FadeConfiguration(topColors: [Colors.red, Colors.blue]);
      const config2 =
          FadeConfiguration(topColors: [Colors.green, Colors.yellow]);
      expect(config1, isNot(equals(config2)));
    });

    test('should not be equal when bottomColors differs', () {
      const config1 =
          FadeConfiguration(bottomColors: [Colors.red, Colors.blue]);
      const config2 =
          FadeConfiguration(bottomColors: [Colors.green, Colors.yellow]);
      expect(config1, isNot(equals(config2)));
    });

    test('should not be equal when stops differs', () {
      const config1 = FadeConfiguration();
      const config2 = FadeConfiguration(stops: [0.2, 0.8]);
      expect(config1, isNot(equals(config2)));
    });

    test('should not be equal when selectedAlwaysOpaque differs', () {
      const config1 = FadeConfiguration();
      const config2 = FadeConfiguration(selectedAlwaysOpaque: false);
      expect(config1, isNot(equals(config2)));
    });

    test('should not be equal to null', () {
      const config = FadeConfiguration();
      expect(config, isNot(equals(null)));
    });

    test('should not be equal to different type', () {
      const config = FadeConfiguration();
      expect(config, isNot(equals('string')));
      expect(config, isNot(equals(42)));
      expect(config, isNot(equals(true)));
    });

    test('should have different hashCode when properties differ', () {
      const config1 = FadeConfiguration();
      const config2 = FadeConfiguration(fadeDistance: 80);
      expect(config1.hashCode, isNot(equals(config2.hashCode)));
    });
  });

  group('FadeConfiguration _listEquals coverage', () {
    test('should detect different list lengths in topColors', () {
      const config1 = FadeConfiguration(
        topColors: [Colors.red, Colors.blue],
      );
      const config2 = FadeConfiguration(
        topColors: [Colors.red, Colors.blue, Colors.green],
      );
      expect(config1, isNot(equals(config2)));
    });

    test('should detect different list lengths in bottomColors', () {
      const config1 = FadeConfiguration(
        bottomColors: [Colors.red],
      );
      const config2 = FadeConfiguration(
        bottomColors: [Colors.red, Colors.blue],
      );
      expect(config1, isNot(equals(config2)));
    });

    test('should detect different list lengths in stops', () {
      const config1 = FadeConfiguration(
        stops: [0.0, 0.5, 1.0],
      );
      const config2 = FadeConfiguration(
        
      );
      expect(config1, isNot(equals(config2)));
    });

    test('should detect element differences at various indices', () {
      // Difference at index 0
      const config1 = FadeConfiguration(
        topColors: [Colors.red, Colors.blue],
      );
      const config2 = FadeConfiguration(
        topColors: [Colors.green, Colors.blue],
      );
      expect(config1, isNot(equals(config2)));

      // Difference at index 1
      const config3 = FadeConfiguration(
        topColors: [Colors.red, Colors.yellow],
      );
      expect(config1, isNot(equals(config3)));
    });

    test('should be equal with identical list contents', () {
      const config1 = FadeConfiguration(
        topColors: [Colors.red, Colors.blue],
        bottomColors: [Colors.green, Colors.yellow],
      );
      const config2 = FadeConfiguration(
        topColors: [Colors.red, Colors.blue],
        bottomColors: [Colors.green, Colors.yellow],
      );
      expect(config1, equals(config2));
    });
  });
}
