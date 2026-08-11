// infinite_scroll_picking_settings/test/src/settings/settings_mapper_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking/infinite_scroll_picking.dart'
    show InfiniteScrollWheelConfig;
import 'package:infinite_scroll_picking_settings/src/picker_visual_settings/picker_visual_settings.dart'
    show PickerVisualSettings;
import 'package:infinite_scroll_picking_settings/src/settings/settings_mapper.dart'
    show PickerVisualSettingsMapper, WheelConfigMapper, WheelSettingsMapper;
import 'package:infinite_scroll_picking_settings/src/wheel_settings/wheel_settings.dart'
    show WheelSettings;

/// Fully non-default wheel settings so field mix-ups can't hide behind
/// matching defaults.
const _kWheel = WheelSettings(
  itemExtent: 30,
  dividerThickness: 2,
  dividerInset: 6,
  wheelWidth: 70,
  wheelHeight: 100,
  perspectiveDiameter: 1.5,
  magnification: 1.5,
  wheelBorderRadius: 12,
  showBorder: false,
  selectionDebounce: Duration(milliseconds: 100),
);

void main() {
  group('WheelSettingsMapper.toWheelConfig', () {
    test('copies every field into the runtime config', () {
      final config = _kWheel.toWheelConfig();

      expect(config.itemExtent, 30);
      expect(config.dividerThickness, 2);
      expect(config.dividerInset, 6);
      expect(config.wheelWidth, 70);
      expect(config.wheelHeight, 100);
      expect(config.perspectiveDiameter, 1.5);
      expect(config.magnification, 1.5);
      expect(config.wheelBorderRadius, 12);
      expect(config.showBorder, isFalse);
      expect(config.selectionDebounce, const Duration(milliseconds: 100));
    });
  });

  group('WheelConfigMapper.toWheelSettings', () {
    test('reverse-maps every field back into settings', () {
      final settings = _kWheel.toWheelConfig().toWheelSettings();
      expect(settings, _kWheel);
    });

    test('a default runtime config maps to default settings', () {
      final settings = const WheelSettings()
          .toWheelConfig()
          .toWheelSettings();
      expect(settings, const WheelSettings());
    });
  });

  group('PickerVisualSettingsMapper.toPickerConfig', () {
    const visual = PickerVisualSettings(
      wheel: _kWheel,
      startingIndex: 2,
      frameBorderRadius: 4,
      frameHorizontalPadding: 20,
      frameVerticalPadding: 10,
    );

    test('combines settings with runtime items and pickerId', () {
      final config = visual.toPickerConfig<String, int>(
        items: const ['a', 'b', 'c'],
        pickerId: 99,
      );

      expect(config.items, const ['a', 'b', 'c']);
      expect(config.pickerId, 99);
      expect(config.startingIndex, 2);
      expect(config.frameBorderRadius, 4);
      expect(config.frameHorizontalPadding, 20);
      expect(config.frameVerticalPadding, 10);
      expect(config.wheelConfig.itemExtent, 30);
      expect(
        config.wheelConfig.selectionDebounce,
        const Duration(milliseconds: 100),
      );
    });

    test('asserts reject an empty items list', () {
      expect(
        () => visual.toPickerConfig<String, int>(
          items: const [],
          pickerId: 1,
        ),
        throwsAssertionError,
      );
    });

    test('asserts reject startingIndex beyond items.length', () {
      expect(
        () => visual.toPickerConfig<String, int>(
          items: const ['only', 'two'],
          pickerId: 1,
        ),
        throwsAssertionError,
      );
    });
  });
}
