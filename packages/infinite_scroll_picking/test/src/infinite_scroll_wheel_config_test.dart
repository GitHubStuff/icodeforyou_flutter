// infinite_scroll_picking/test/src/infinite_scroll_wheel_config_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart';

void main() {
  group('InfiniteScrollWheelConfig', () {
    InfiniteScrollWheelConfig baseConfig({
      double itemExtent = 24.0,
      double dividerThickness = 1.0,
      double dividerInset = 4.0,
      double wheelWidth = 56.0,
      double wheelHeight = 48.0,
      double perspectiveDiameter = 1.2,
      double magnification = 1.25,
      double wheelBorderRadius = 8.0,
      bool showBorder = true,
      Duration selectionDebounce = Duration.zero,
    }) {
      return InfiniteScrollWheelConfig(
        itemExtent: itemExtent,
        dividerThickness: dividerThickness,
        dividerInset: dividerInset,
        wheelWidth: wheelWidth,
        wheelHeight: wheelHeight,
        perspectiveDiameter: perspectiveDiameter,
        magnification: magnification,
        wheelBorderRadius: wheelBorderRadius,
        showBorder: showBorder,
        selectionDebounce: selectionDebounce,
      );
    }

    group('construction and defaults', () {
      test('stores documented default values', () {
        const c = InfiniteScrollWheelConfig();

        expect(c.itemExtent, 24.0);
        expect(c.dividerThickness, 1.0);
        expect(c.dividerInset, 4.0);
        expect(c.wheelWidth, 56.0);
        expect(c.wheelHeight, 48.0);
        expect(c.perspectiveDiameter, 1.2);
        expect(c.magnification, 1.25);
        expect(c.wheelBorderRadius, 8.0);
        expect(c.showBorder, isTrue);
        expect(c.selectionDebounce, Duration.zero);
      });

      test('honors explicitly supplied values', () {
        const c = InfiniteScrollWheelConfig(
          itemExtent: 30,
          dividerThickness: 2,
          dividerInset: 8,
          wheelWidth: 80,
          wheelHeight: 100,
          perspectiveDiameter: 2,
          magnification: 1.5,
          wheelBorderRadius: 12,
          showBorder: false,
          selectionDebounce: Duration(milliseconds: 100),
        );

        expect(c.itemExtent, 30);
        expect(c.dividerThickness, 2);
        expect(c.dividerInset, 8);
        expect(c.wheelWidth, 80);
        expect(c.wheelHeight, 100);
        expect(c.perspectiveDiameter, 2);
        expect(c.magnification, 1.5);
        expect(c.wheelBorderRadius, 12);
        expect(c.showBorder, isFalse);
        expect(c.selectionDebounce, const Duration(milliseconds: 100));
      });
    });

    group('asserts', () {
      test('rejects wheelHeight below 1.1x itemExtent', () {
        expect(
          () => InfiniteScrollWheelConfig(
            itemExtent: 40,
            wheelHeight: 40,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('accepts wheelHeight equal to 1.1x itemExtent (boundary)', () {
        expect(
          () => const InfiniteScrollWheelConfig(
            itemExtent: 20,
            wheelHeight: 22,
          ),
          returnsNormally,
        );
      });

      test('rejects magnification below 1.0', () {
        expect(
          () => InfiniteScrollWheelConfig(magnification: 0.99),
          throwsA(isA<AssertionError>()),
        );
      });

      test('accepts magnification of exactly 1.0 (boundary)', () {
        expect(
          () => const InfiniteScrollWheelConfig(magnification: 1),
          returnsNormally,
        );
      });

      test('rejects perspectiveDiameter of zero', () {
        expect(
          () => InfiniteScrollWheelConfig(perspectiveDiameter: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('rejects negative perspectiveDiameter', () {
        expect(
          () => InfiniteScrollWheelConfig(perspectiveDiameter: -1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('rejects negative dividerThickness', () {
        expect(
          () => InfiniteScrollWheelConfig(dividerThickness: -1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('accepts zero dividerThickness (boundary)', () {
        expect(
          () => const InfiniteScrollWheelConfig(dividerThickness: 0),
          returnsNormally,
        );
      });

      test('rejects negative dividerInset', () {
        expect(
          () => InfiniteScrollWheelConfig(dividerInset: -1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('accepts zero dividerInset (boundary)', () {
        expect(
          () => const InfiniteScrollWheelConfig(dividerInset: 0),
          returnsNormally,
        );
      });
    });

    group('copyWith', () {
      test('returns equal copy when no overrides supplied', () {
        final original = baseConfig();
        final copy = original.copyWith();
        expect(copy, equals(original));
        expect(identical(copy, original), isFalse);
      });

      test('overrides itemExtent independently', () {
        final original = baseConfig();
        final copy = original.copyWith(itemExtent: 30, wheelHeight: 60);
        expect(copy.itemExtent, 30);
        expect(copy.wheelHeight, 60);
        expect(copy.dividerThickness, original.dividerThickness);
      });

      test('overrides dividerThickness independently', () {
        final original = baseConfig();
        final copy = original.copyWith(dividerThickness: 3);
        expect(copy.dividerThickness, 3);
        expect(copy.itemExtent, original.itemExtent);
      });

      test('overrides dividerInset independently', () {
        final original = baseConfig();
        final copy = original.copyWith(dividerInset: 10);
        expect(copy.dividerInset, 10);
        expect(copy.itemExtent, original.itemExtent);
      });

      test('overrides wheelWidth independently', () {
        final original = baseConfig();
        final copy = original.copyWith(wheelWidth: 80);
        expect(copy.wheelWidth, 80);
        expect(copy.itemExtent, original.itemExtent);
      });

      test('overrides wheelHeight independently', () {
        final original = baseConfig();
        final copy = original.copyWith(wheelHeight: 100);
        expect(copy.wheelHeight, 100);
        expect(copy.itemExtent, original.itemExtent);
      });

      test('overrides perspectiveDiameter independently', () {
        final original = baseConfig();
        final copy = original.copyWith(perspectiveDiameter: 2);
        expect(copy.perspectiveDiameter, 2);
        expect(copy.itemExtent, original.itemExtent);
      });

      test('overrides magnification independently', () {
        final original = baseConfig();
        final copy = original.copyWith(magnification: 1.5);
        expect(copy.magnification, 1.5);
        expect(copy.itemExtent, original.itemExtent);
      });

      test('overrides wheelBorderRadius independently', () {
        final original = baseConfig();
        final copy = original.copyWith(wheelBorderRadius: 16);
        expect(copy.wheelBorderRadius, 16);
        expect(copy.itemExtent, original.itemExtent);
      });

      test('overrides showBorder independently', () {
        final original = baseConfig();
        final copy = original.copyWith(showBorder: false);
        expect(copy.showBorder, isFalse);
        expect(copy.itemExtent, original.itemExtent);
      });

      test('overrides selectionDebounce independently', () {
        final original = baseConfig();
        final copy = original.copyWith(
          selectionDebounce: const Duration(milliseconds: 100),
        );
        expect(copy.selectionDebounce, const Duration(milliseconds: 100));
        expect(copy.itemExtent, original.itemExtent);
      });
    });

    group('equality and hashCode', () {
      test('identical instance is equal to itself', () {
        final c = baseConfig();
        // ignore: unrelated_type_equality_checks
        expect(c == c, isTrue);
      });

      test('differs from a non-config object', () {
        final c = baseConfig();
        // ignore: unrelated_type_equality_checks
        expect(c == 'not a config', isFalse);
      });

      test('two configs with the same field values are equal', () {
        final a = baseConfig();
        final b = baseConfig();
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('differs when itemExtent differs', () {
        final a = baseConfig();
        // wheelHeight scales to keep the assertion happy.
        final b = baseConfig(itemExtent: 30, wheelHeight: 60);
        expect(a, isNot(equals(b)));
      });

      test('differs when dividerThickness differs', () {
        final a = baseConfig();
        final b = baseConfig(dividerThickness: 3);
        expect(a, isNot(equals(b)));
      });

      test('differs when dividerInset differs', () {
        final a = baseConfig();
        final b = baseConfig(dividerInset: 10);
        expect(a, isNot(equals(b)));
      });

      test('differs when wheelWidth differs', () {
        final a = baseConfig();
        final b = baseConfig(wheelWidth: 80);
        expect(a, isNot(equals(b)));
      });

      test('differs when wheelHeight differs', () {
        final a = baseConfig();
        final b = baseConfig(wheelHeight: 100);
        expect(a, isNot(equals(b)));
      });

      test('differs when perspectiveDiameter differs', () {
        final a = baseConfig();
        final b = baseConfig(perspectiveDiameter: 2);
        expect(a, isNot(equals(b)));
      });

      test('differs when magnification differs', () {
        final a = baseConfig();
        final b = baseConfig(magnification: 1.5);
        expect(a, isNot(equals(b)));
      });

      test('differs when wheelBorderRadius differs', () {
        final a = baseConfig();
        final b = baseConfig(wheelBorderRadius: 16);
        expect(a, isNot(equals(b)));
      });

      test('differs when showBorder differs', () {
        final a = baseConfig();
        final b = baseConfig(showBorder: false);
        expect(a, isNot(equals(b)));
      });

      test('differs when selectionDebounce differs', () {
        final a = baseConfig();
        final b = baseConfig(
          selectionDebounce: const Duration(milliseconds: 100),
        );
        expect(a, isNot(equals(b)));
      });
    });
  });
}
