// infinite_scroll_picking_settings/test/src/settings/settings_mapper_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart';
import 'package:infinite_scroll_picking_settings/infinite_scroll_picking_settings.dart';

void main() {
  // Distinctive, all-different field values so a copy-paste error that
  // crosses two fields would surface as a failing assertion.
  const wheelSettings = WheelSettings(
    itemExtent: 30,
    dividerThickness: 2,
    dividerInset: 8,
    wheelWidth: 80,
    wheelHeight: 100,
    perspectiveDiameter: 2,
    magnification: 1.5,
    wheelBorderRadius: 12,
    showBorder: false,
    selectionDebounce: Duration(milliseconds: 250),
  );

  const wheelConfig = InfiniteScrollWheelConfig(
    itemExtent: 30,
    dividerThickness: 2,
    dividerInset: 8,
    wheelWidth: 80,
    wheelHeight: 100,
    perspectiveDiameter: 2,
    magnification: 1.5,
    wheelBorderRadius: 12,
    showBorder: false,
    selectionDebounce: Duration(milliseconds: 250),
  );

  group('WheelSettingsMapper.toWheelConfig', () {
    test('copies every field into an InfiniteScrollWheelConfig', () {
      final result = wheelSettings.toWheelConfig();

      expect(result.itemExtent, 30);
      expect(result.dividerThickness, 2);
      expect(result.dividerInset, 8);
      expect(result.wheelWidth, 80);
      expect(result.wheelHeight, 100);
      expect(result.perspectiveDiameter, 2);
      expect(result.magnification, 1.5);
      expect(result.wheelBorderRadius, 12);
      expect(result.showBorder, isFalse);
      expect(result.selectionDebounce, const Duration(milliseconds: 250));
    });

    test('round-trips through toWheelSettings without drift', () {
      expect(
        wheelSettings.toWheelConfig().toWheelSettings(),
        wheelSettings,
      );
    });

    test('uses defaults when the source uses defaults', () {
      const defaults = WheelSettings();
      const expected = InfiniteScrollWheelConfig();

      expect(defaults.toWheelConfig(), expected);
    });
  });

  group('WheelConfigMapper.toWheelSettings', () {
    test('copies every field into a WheelSettings', () {
      final result = wheelConfig.toWheelSettings();

      expect(result.itemExtent, 30);
      expect(result.dividerThickness, 2);
      expect(result.dividerInset, 8);
      expect(result.wheelWidth, 80);
      expect(result.wheelHeight, 100);
      expect(result.perspectiveDiameter, 2);
      expect(result.magnification, 1.5);
      expect(result.wheelBorderRadius, 12);
      expect(result.showBorder, isFalse);
      expect(result.selectionDebounce, const Duration(milliseconds: 250));
    });

    test('round-trips through toWheelConfig without drift', () {
      expect(
        wheelConfig.toWheelSettings().toWheelConfig(),
        wheelConfig,
      );
    });

    test('uses defaults when the source uses defaults', () {
      const defaults = InfiniteScrollWheelConfig();
      const expected = WheelSettings();

      expect(defaults.toWheelSettings(), expected);
    });
  });

  group('PickerVisualSettingsMapper.toPickerConfig', () {
    const visual = PickerVisualSettings(
      wheel: wheelSettings,
      startingIndex: 1,
      frameBorderRadius: 16,
      frameHorizontalPadding: 20,
      frameVerticalPadding: 10,
    );

    test('copies every field and embeds the mapped wheel config', () {
      final result = visual.toPickerConfig<String, _Key>(
        items: const ['a', 'b', 'c'],
        pickerId: _Key.minutes,
      );

      expect(result.items, const ['a', 'b', 'c']);
      expect(result.pickerId, _Key.minutes);
      expect(result.startingIndex, 1);
      expect(result.frameBorderRadius, 16);
      expect(result.frameHorizontalPadding, 20);
      expect(result.frameVerticalPadding, 10);
      expect(result.wheelConfig, wheelSettings.toWheelConfig());
    });

    test('asserts when items is empty', () {
      expect(
        () => visual.toPickerConfig<String, _Key>(
          items: const [],
          pickerId: _Key.minutes,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts when startingIndex >= items.length', () {
      const oob = PickerVisualSettings(startingIndex: 3);

      expect(
        () => oob.toPickerConfig<String, _Key>(
          items: const ['a', 'b', 'c'],
          pickerId: _Key.minutes,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test(
      'accepts startingIndex == items.length - 1 (boundary)',
      () {
        const boundary = PickerVisualSettings(startingIndex: 2);

        expect(
          () => boundary.toPickerConfig<String, _Key>(
            items: const ['a', 'b', 'c'],
            pickerId: _Key.minutes,
          ),
          returnsNormally,
        );
      },
    );

    test('preserves generic type parameters', () {
      final result = const PickerVisualSettings().toPickerConfig<int, String>(
        items: const [10, 20, 30],
        pickerId: 'numeric-picker',
      );

      expect(result, isA<InfiniteScrollPickerConfig<int, String>>());
      expect(result.items, const [10, 20, 30]);
      expect(result.pickerId, 'numeric-picker');
    });
  });
}

enum _Key { minutes }
