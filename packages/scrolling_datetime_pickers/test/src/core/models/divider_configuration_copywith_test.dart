// test/src/core/models/divider_configuration_copywith_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/models/divider_configuration.dart';

void main() {
  group('DividerConfiguration copyWith', () {
    test('should copy with all parameters changed', () {
      const original = DividerConfiguration();

      final modified = original.copyWith(
        color: Colors.red,
        transparency: 0.5,
        thickness: 3.0,
        indent: 5.0,
        endIndent: 10.0,
        blurStyle: BlurStyle.normal,
        blurRadius: 2.0,
        spreadRadius: 1.0,
      );

      expect(modified.color, Colors.red);
      expect(modified.transparency, 0.5);
      expect(modified.thickness, 3.0);
      expect(modified.indent, 5.0);
      expect(modified.endIndent, 10.0);
      expect(modified.blurStyle, BlurStyle.normal);
      expect(modified.blurRadius, 2.0);
      expect(modified.spreadRadius, 1.0);
    });

    test('should preserve all original values when no params', () {
      const original = DividerConfiguration(
        color: Colors.green,
        transparency: 0.7,
        thickness: 2.5,
        indent: 5.0,
        endIndent: 10.0,
        blurStyle: BlurStyle.outer,
        blurRadius: 3.0,
        spreadRadius: 2.0,
      );

      final copy = original.copyWith();

      expect(copy.color, original.color);
      expect(copy.transparency, original.transparency);
      expect(copy.thickness, original.thickness);
      expect(copy.indent, original.indent);
      expect(copy.endIndent, original.endIndent);
      expect(copy.blurStyle, original.blurStyle);
      expect(copy.blurRadius, original.blurRadius);
      expect(copy.spreadRadius, original.spreadRadius);
    });

    test('should copy individual parameters', () {
      const original = DividerConfiguration(
        color: Colors.blue,
        transparency: 0.5,
      );

      final colorOnly = original.copyWith(color: Colors.yellow);
      expect(colorOnly.color, Colors.yellow);
      expect(colorOnly.transparency, 0.5);

      final transparencyOnly = original.copyWith(transparency: 0.8);
      expect(transparencyOnly.color, Colors.blue);
      expect(transparencyOnly.transparency, 0.8);

      final thicknessOnly = original.copyWith(thickness: 2.5);
      expect(thicknessOnly.thickness, 2.5);

      final indentOnly = original.copyWith(indent: 10.0);
      expect(indentOnly.indent, 10.0);

      final endIndentOnly = original.copyWith(endIndent: 15.0);
      expect(endIndentOnly.endIndent, 15.0);

      final blurStyleOnly = original.copyWith(blurStyle: BlurStyle.solid);
      expect(blurStyleOnly.blurStyle, BlurStyle.solid);

      final blurRadiusOnly = original.copyWith(blurRadius: 5.0);
      expect(blurRadiusOnly.blurRadius, 5.0);

      final spreadRadiusOnly = original.copyWith(spreadRadius: 3.0);
      expect(spreadRadiusOnly.spreadRadius, 3.0);
    });
  });

  group('DividerConfiguration Equality', () {
    test('should be equal to itself', () {
      const config = DividerConfiguration();
      expect(config, equals(config));
      expect(config.hashCode, equals(config.hashCode));
    });

    test('should be equal when all properties match', () {
      const config1 = DividerConfiguration(
        color: Colors.blue,
        transparency: 0.5,
        thickness: 2.0,
        indent: 5.0,
        endIndent: 10.0,
        blurStyle: BlurStyle.normal,
        blurRadius: 3.0,
        spreadRadius: 1.0,
      );

      const config2 = DividerConfiguration(
        color: Colors.blue,
        transparency: 0.5,
        thickness: 2.0,
        indent: 5.0,
        endIndent: 10.0,
        blurStyle: BlurStyle.normal,
        blurRadius: 3.0,
        spreadRadius: 1.0,
      );

      expect(config1, equals(config2));
      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('should not be equal when any property differs', () {
      const base = DividerConfiguration();

      const diffColor = DividerConfiguration(color: Colors.red);
      expect(base, isNot(equals(diffColor)));

      const diffTransparency = DividerConfiguration(transparency: 0.5);
      expect(base, isNot(equals(diffTransparency)));

      const diffThickness = DividerConfiguration(thickness: 3.0);
      expect(base, isNot(equals(diffThickness)));

      const diffIndent = DividerConfiguration(indent: 5.0);
      expect(base, isNot(equals(diffIndent)));

      const diffEndIndent = DividerConfiguration(endIndent: 5.0);
      expect(base, isNot(equals(diffEndIndent)));

      const diffBlurStyle = DividerConfiguration(blurStyle: BlurStyle.inner);
      expect(base, isNot(equals(diffBlurStyle)));

      const diffBlurRadius = DividerConfiguration(blurRadius: 2.0);
      expect(base, isNot(equals(diffBlurRadius)));

      const diffSpreadRadius = DividerConfiguration(spreadRadius: 2.0);
      expect(base, isNot(equals(diffSpreadRadius)));
    });

    test('should not be equal to null', () {
      const config = DividerConfiguration();
      expect(config, isNot(equals(null)));
    });

    test('should not be equal to different type', () {
      const config = DividerConfiguration();
      expect(config, isNot(equals('string')));
      expect(config, isNot(equals(42)));
      expect(config, isNot(equals(true)));
    });

    test('should have different hashCode when properties differ', () {
      const config1 = DividerConfiguration(color: Colors.blue);
      const config2 = DividerConfiguration(color: Colors.red);

      expect(config1.hashCode, isNot(equals(config2.hashCode)));
    });
  });
}
