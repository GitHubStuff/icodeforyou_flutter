// test/src/core/models/divider_configuration_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/models/divider_configuration.dart';

void main() {
  group('DividerConfiguration Constructor', () {
    test('should create with default values', () {
      const config = DividerConfiguration();

      expect(config.color, const Color(0xFFE0E0E0));
      expect(config.transparency, 1.0);
      expect(config.thickness, 1.5);
      expect(config.indent, 0.0);
      expect(config.endIndent, 0.0);
      expect(config.blurStyle, isNull);
      expect(config.blurRadius, 0.0);
      expect(config.spreadRadius, 0.0);
    });

    test('should create with custom values', () {
      const config = DividerConfiguration(
        color: Colors.blue,
        transparency: 0.5,
        thickness: 2.0,
        indent: 10.0,
        endIndent: 15.0,
        blurStyle: BlurStyle.normal,
        blurRadius: 3.0,
        spreadRadius: 2.0,
      );

      expect(config.color, Colors.blue);
      expect(config.transparency, 0.5);
      expect(config.thickness, 2.0);
      expect(config.indent, 10.0);
      expect(config.endIndent, 15.0);
      expect(config.blurStyle, BlurStyle.normal);
      expect(config.blurRadius, 3.0);
      expect(config.spreadRadius, 2.0);
    });

    test('should enforce transparency bounds', () {
      expect(
          () => DividerConfiguration(transparency: -0.1), throwsAssertionError);
      expect(
          () => DividerConfiguration(transparency: 1.1), throwsAssertionError);
      expect(
          () => const DividerConfiguration(transparency: 0.0), returnsNormally);
      expect(
          () => const DividerConfiguration(transparency: 1.0), returnsNormally);
    });

    test('should enforce positive thickness', () {
      expect(() => DividerConfiguration(thickness: 0.0), throwsAssertionError);
      expect(() => DividerConfiguration(thickness: -1.0), throwsAssertionError);
      expect(() => const DividerConfiguration(thickness: 0.1), returnsNormally);
    });

    test('should enforce non-negative indents', () {
      expect(() => DividerConfiguration(indent: -1.0), throwsAssertionError);
      expect(() => DividerConfiguration(endIndent: -1.0), throwsAssertionError);
      expect(() => const DividerConfiguration(indent: 0.0), returnsNormally);
      expect(() => const DividerConfiguration(endIndent: 0.0), returnsNormally);
    });

    test('should enforce non-negative radii', () {
      expect(
          () => DividerConfiguration(blurRadius: -1.0), throwsAssertionError);
      expect(
          () => DividerConfiguration(spreadRadius: -1.0), throwsAssertionError);
      expect(
          () => const DividerConfiguration(blurRadius: 0.0), returnsNormally);
      expect(
          () => const DividerConfiguration(spreadRadius: 0.0), returnsNormally);
    });
  });

  group('DividerConfiguration Factories', () {
    test('defaultConfig should return expected defaults', () {
      final config = DividerConfiguration.defaultConfig();

      expect(config.color, const Color(0xFFE0E0E0));
      expect(config.transparency, 1.0);
      expect(config.thickness, 1.5);
      expect(config.indent, 0.0);
      expect(config.endIndent, 0.0);
      expect(config.blurStyle, isNull);
      expect(config.blurRadius, 0.0);
      expect(config.spreadRadius, 0.0);
      expect(config.hasEffect, isFalse);
    });

    test('withGlow should create glow effect', () {
      final config = DividerConfiguration.withGlow();

      expect(config.color, const Color(0xFFE0E0E0));
      expect(config.transparency, 1.0);
      expect(config.thickness, 1.5);
      expect(config.blurStyle, BlurStyle.outer);
      expect(config.blurRadius, 2.0);
      expect(config.spreadRadius, 1.0);
      expect(config.hasEffect, isTrue);
    });

    test('withGlow should accept custom parameters', () {
      final config = DividerConfiguration.withGlow(
        color: Colors.red,
        transparency: 0.8,
        thickness: 2.5,
      );

      expect(config.color, Colors.red);
      expect(config.transparency, 0.8);
      expect(config.thickness, 2.5);
      expect(config.blurStyle, BlurStyle.outer);
    });

    test('withBlur should create blur effect', () {
      final config = DividerConfiguration.withBlur();

      expect(config.color, const Color(0xFFE0E0E0));
      expect(config.transparency, 0.8);
      expect(config.thickness, 2.0);
      expect(config.blurStyle, BlurStyle.normal);
      expect(config.blurRadius, 4.0);
      expect(config.spreadRadius, 0.0);
      expect(config.hasEffect, isTrue);
    });

    test('withBlur should accept custom parameters', () {
      final config = DividerConfiguration.withBlur(
        color: Colors.green,
        transparency: 0.6,
        thickness: 3.0,
        blurStyle: BlurStyle.inner,
      );

      expect(config.color, Colors.green);
      expect(config.transparency, 0.6);
      expect(config.thickness, 3.0);
      expect(config.blurStyle, BlurStyle.inner);
    });
  });

  group('DividerConfiguration Properties', () {
    test('effectiveColor should apply transparency', () {
      const config = DividerConfiguration(
        color: Colors.white,
        transparency: 0.5,
      );

      // Check that transparency is applied (allowing for floating point precision)
      final effective = config.effectiveColor;
      expect(effective.r, 1.0);
      expect(effective.g, 1.0);
      expect(effective.b, 1.0);
      expect(effective.a, closeTo(0.5, 0.01));
    });

    test('effectiveColor with zero transparency', () {
      const config = DividerConfiguration(
        color: Colors.blue,
        transparency: 0.0,
      );
      expect(config.effectiveColor.a, 0.0);
    });

    test('effectiveColor with full opacity', () {
      const config = DividerConfiguration(
        color: Colors.red,
        transparency: 1.0,
      );
      expect(config.effectiveColor.a, 1.0);
    });

    test('hasEffect should detect no effect', () {
      const config = DividerConfiguration();
      expect(config.hasEffect, isFalse);

      const styleOnly = DividerConfiguration(blurStyle: BlurStyle.normal);
      expect(styleOnly.hasEffect, isFalse);
    });

    test('hasEffect should detect blur effect', () {
      const config = DividerConfiguration(
        blurStyle: BlurStyle.normal,
        blurRadius: 2.0,
      );
      expect(config.hasEffect, isTrue);
    });

    test('hasEffect should detect spread effect', () {
      const config = DividerConfiguration(
        blurStyle: BlurStyle.outer,
        spreadRadius: 1.0,
      );
      expect(config.hasEffect, isTrue);
    });

    test('hasEffect should detect both effects', () {
      const config = DividerConfiguration(
        blurStyle: BlurStyle.inner,
        blurRadius: 2.0,
        spreadRadius: 1.0,
      );
      expect(config.hasEffect, isTrue);
    });
  });
}
