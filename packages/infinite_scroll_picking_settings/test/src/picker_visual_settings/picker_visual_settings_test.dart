// packages/infinite_scroll_picking_settings/test/src/picker_visual_settings/picker_visual_settings_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/src/picker_visual_settings/picker_visual_settings.dart'
    show PickerVisualSettings;
import 'package:infinite_scroll_picking_settings/src/wheel_settings/wheel_settings.dart'
    show WheelSettings;

/// Fully non-default instance used for round-trip and copyWith tests.
const _kCustom = PickerVisualSettings(
  wheel: WheelSettings(itemExtent: 30, wheelHeight: 90),
  startingIndex: 5,
  frameBorderRadius: 4,
  frameHorizontalPadding: 20,
  frameVerticalPadding: 10,
);

void main() {
  group('PickerVisualSettings', () {
    test('defaults match the documented values', () {
      const settings = PickerVisualSettings();
      expect(settings.wheel, const WheelSettings());
      expect(settings.startingIndex, 0);
      expect(settings.frameBorderRadius, 8.0);
      expect(settings.frameHorizontalPadding, 12.0);
      expect(settings.frameVerticalPadding, 6.0);
    });

    test('asserts reject negative startingIndex', () {
      expect(
        () => PickerVisualSettings(startingIndex: -1),
        throwsAssertionError,
      );
    });

    test('asserts reject negative frameBorderRadius', () {
      expect(
        () => PickerVisualSettings(frameBorderRadius: -0.1),
        throwsAssertionError,
      );
    });

    test('asserts reject negative frameHorizontalPadding', () {
      expect(
        () => PickerVisualSettings(frameHorizontalPadding: -1),
        throwsAssertionError,
      );
    });

    test('asserts reject negative frameVerticalPadding', () {
      expect(
        () => PickerVisualSettings(frameVerticalPadding: -1),
        throwsAssertionError,
      );
    });

    test('value equality follows all fields', () {
      expect(_kCustom, const PickerVisualSettings(
        wheel: WheelSettings(itemExtent: 30, wheelHeight: 90),
        startingIndex: 5,
        frameBorderRadius: 4,
        frameHorizontalPadding: 20,
        frameVerticalPadding: 10,
      ));
      expect(_kCustom, isNot(equals(const PickerVisualSettings())));
    });

    test('copyWith replaces provided fields and keeps the rest', () {
      final copy = _kCustom.copyWith(startingIndex: 9);
      expect(copy.startingIndex, 9);
      expect(copy.frameBorderRadius, 4);
      expect(copy.wheel, _kCustom.wheel);
    });

    test('fromJson of an empty map yields the defaults', () {
      final settings = PickerVisualSettings.fromJson(const {});
      expect(settings, const PickerVisualSettings());
    });

    test('non-default values round-trip through JSON', () {
      final restored = PickerVisualSettings.fromJson(_kCustom.toJson());
      expect(restored, _kCustom);
    });
  });
}
