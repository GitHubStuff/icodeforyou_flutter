// test/src/infinite_scroll_picker_config_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart';

void main() {
  group('InfiniteScrollPickerConfig', () {
    InfiniteScrollPickerConfig<String, String> baseConfig({
      List<String> items = const ['a', 'b', 'c'],
      String pickerId = 'p',
      int startingIndex = 0,
      InfiniteScrollWheelConfig wheelConfig = const InfiniteScrollWheelConfig(),
      double frameBorderRadius = 8.0,
      double frameHorizontalPadding = 12.0,
      double frameVerticalPadding = 6.0,
    }) {
      return InfiniteScrollPickerConfig<String, String>(
        items: items,
        pickerId: pickerId,
        startingIndex: startingIndex,
        wheelConfig: wheelConfig,
        frameBorderRadius: frameBorderRadius,
        frameHorizontalPadding: frameHorizontalPadding,
        frameVerticalPadding: frameVerticalPadding,
      );
    }

    group('construction and defaults', () {
      test('stores all field values with defaults', () {
        final c = InfiniteScrollPickerConfig<String, String>(
          items: const ['a', 'b'],
          pickerId: 'id',
          startingIndex: 1,
        );

        expect(c.items, const ['a', 'b']);
        expect(c.pickerId, 'id');
        expect(c.startingIndex, 1);
        expect(c.wheelConfig, const InfiniteScrollWheelConfig());
        expect(c.frameBorderRadius, 8.0);
        expect(c.frameHorizontalPadding, 12.0);
        expect(c.frameVerticalPadding, 6.0);
      });

      test('supports a generic enum pickerId', () {
        final c = InfiniteScrollPickerConfig<int, _PickerKey>(
          items: const [1, 2, 3],
          pickerId: _PickerKey.minutes,
          startingIndex: 0,
        );
        expect(c.pickerId, _PickerKey.minutes);
      });
    });

    group('asserts', () {
      test('rejects empty items', () {
        expect(
          () => InfiniteScrollPickerConfig<String, String>(
            items: const [],
            pickerId: 'p',
            startingIndex: 0,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('rejects negative startingIndex', () {
        expect(
          () => InfiniteScrollPickerConfig<String, String>(
            items: const ['a'],
            pickerId: 'p',
            startingIndex: -1,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('rejects startingIndex >= items.length', () {
        expect(
          () => InfiniteScrollPickerConfig<String, String>(
            items: const ['a', 'b'],
            pickerId: 'p',
            startingIndex: 2,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('rejects negative frameBorderRadius', () {
        expect(
          () => InfiniteScrollPickerConfig<String, String>(
            items: const ['a'],
            pickerId: 'p',
            startingIndex: 0,
            frameBorderRadius: -1,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('rejects negative frameHorizontalPadding', () {
        expect(
          () => InfiniteScrollPickerConfig<String, String>(
            items: const ['a'],
            pickerId: 'p',
            startingIndex: 0,
            frameHorizontalPadding: -1,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('rejects negative frameVerticalPadding', () {
        expect(
          () => InfiniteScrollPickerConfig<String, String>(
            items: const ['a'],
            pickerId: 'p',
            startingIndex: 0,
            frameVerticalPadding: -1,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('accepts zero frame paddings and radius', () {
        // Boundary: assertions are `>= 0`.
        expect(
          () => InfiniteScrollPickerConfig<String, String>(
            items: const ['a'],
            pickerId: 'p',
            startingIndex: 0,
            frameBorderRadius: 0,
            frameHorizontalPadding: 0,
            frameVerticalPadding: 0,
          ),
          returnsNormally,
        );
      });
    });

    group('initialWheelOffset', () {
      test('is congruent to startingIndex modulo items.length', () {
        final c = InfiniteScrollPickerConfig<String, String>(
          items: const ['a', 'b', 'c', 'd', 'e'],
          pickerId: 'p',
          startingIndex: 2,
        );
        expect(c.initialWheelOffset % c.items.length, 2);
      });

      test('uses the documented multiplier', () {
        final c = InfiniteScrollPickerConfig<int, String>(
          items: const [0, 1, 2],
          pickerId: 'p',
          startingIndex: 1,
        );
        // 3 * 10000 + 1
        expect(c.initialWheelOffset, 30001);
      });

      test('grows linearly with items.length', () {
        final small = InfiniteScrollPickerConfig<int, String>(
          items: const [0],
          pickerId: 'p',
          startingIndex: 0,
        );
        final large = InfiniteScrollPickerConfig<int, String>(
          items: List<int>.generate(100, (i) => i),
          pickerId: 'p',
          startingIndex: 0,
        );
        expect(small.initialWheelOffset, 10000);
        expect(large.initialWheelOffset, 1000000);
      });
    });

    group('copyWith', () {
      test('returns equal copy when no overrides supplied', () {
        final original = baseConfig();
        final copy = original.copyWith();
        expect(copy, equals(original));
        expect(identical(copy, original), isFalse);
      });

      test('overrides each field independently', () {
        final original = baseConfig();

        final newItems = original.copyWith(items: const ['x', 'y']);
        expect(newItems.items, const ['x', 'y']);
        expect(newItems.pickerId, original.pickerId);

        final newPickerId = original.copyWith(pickerId: 'q');
        expect(newPickerId.pickerId, 'q');

        final newStart = original.copyWith(startingIndex: 1);
        expect(newStart.startingIndex, 1);

        const newWheel = InfiniteScrollWheelConfig(itemExtent: 30);
        final newWheelCfg = original.copyWith(wheelConfig: newWheel);
        expect(newWheelCfg.wheelConfig, newWheel);

        final newRadius = original.copyWith(frameBorderRadius: 16);
        expect(newRadius.frameBorderRadius, 16);

        final newHPad = original.copyWith(frameHorizontalPadding: 20);
        expect(newHPad.frameHorizontalPadding, 20);

        final newVPad = original.copyWith(frameVerticalPadding: 10);
        expect(newVPad.frameVerticalPadding, 10);
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

      test('two configs sharing items by identity are equal', () {
        const items = ['a', 'b', 'c'];
        final a = baseConfig(items: items);
        final b = baseConfig(items: items);
        expect(a, equals(b));
      });

      test('differs when items differ in length', () {
        final a = baseConfig(items: const ['a', 'b']);
        final b = baseConfig(items: const ['a', 'b', 'c']);
        expect(a, isNot(equals(b)));
      });

      test('differs when items differ in content', () {
        final a = baseConfig(items: const ['a', 'b', 'c']);
        final b = baseConfig(items: const ['a', 'b', 'd']);
        expect(a, isNot(equals(b)));
      });

      test('differs when pickerId differs', () {
        final a = baseConfig(pickerId: 'p');
        final b = baseConfig(pickerId: 'q');
        expect(a, isNot(equals(b)));
      });

      test('differs when startingIndex differs', () {
        final a = baseConfig(startingIndex: 0);
        final b = baseConfig(startingIndex: 1);
        expect(a, isNot(equals(b)));
      });

      test('differs when wheelConfig differs', () {
        final a = baseConfig();
        final b = baseConfig(
          wheelConfig: const InfiniteScrollWheelConfig(itemExtent: 30),
        );
        expect(a, isNot(equals(b)));
      });

      test('differs when frameBorderRadius differs', () {
        final a = baseConfig();
        final b = baseConfig(frameBorderRadius: 16);
        expect(a, isNot(equals(b)));
      });

      test('differs when frameHorizontalPadding differs', () {
        final a = baseConfig();
        final b = baseConfig(frameHorizontalPadding: 20);
        expect(a, isNot(equals(b)));
      });

      test('differs when frameVerticalPadding differs', () {
        final a = baseConfig();
        final b = baseConfig(frameVerticalPadding: 10);
        expect(a, isNot(equals(b)));
      });

      test('differs when generic K type differs', () {
        // Different K runtime types should make the configs unequal even if
        // every other field stringifies the same — this exercises the
        // `runtimeType == other.runtimeType` branch.
        final a = InfiniteScrollPickerConfig<String, String>(
          items: const ['a'],
          pickerId: 'p',
          startingIndex: 0,
        );
        final b = InfiniteScrollPickerConfig<String, Object>(
          items: const ['a'],
          pickerId: 'p',
          startingIndex: 0,
        );
        expect(a, isNot(equals(b)));
      });
    });
  });
}

enum _PickerKey { minutes }
