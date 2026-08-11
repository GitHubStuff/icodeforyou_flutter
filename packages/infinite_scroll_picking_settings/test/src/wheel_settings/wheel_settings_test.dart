// infinite_scroll_picking_settings/test/src/wheel_settings/wheel_settings_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/src/wheel_settings/wheel_settings.dart'
    show WheelSettings;

/// Fully non-default instance used for round-trip and copyWith tests.
const _kCustom = WheelSettings(
  itemExtent: 30,
  dividerThickness: 2,
  dividerInset: 6,
  wheelWidth: 70,
  wheelHeight: 100,
  perspectiveDiameter: 1.5,
  magnification: 1.5,
  wheelBorderRadius: 12,
  showBorder: false,
  selectionDebounce: Duration(microseconds: 250500),
);

void main() {
  group('WheelSettings', () {
    test('defaults match the documented values', () {
      const settings = WheelSettings();
      expect(settings.itemExtent, 24.0);
      expect(settings.dividerThickness, 1.0);
      expect(settings.dividerInset, 4.0);
      expect(settings.wheelWidth, 56.0);
      expect(settings.wheelHeight, 48.0);
      expect(settings.perspectiveDiameter, 1.2);
      expect(settings.magnification, 1.25);
      expect(settings.wheelBorderRadius, 8.0);
      expect(settings.showBorder, isTrue);
      expect(settings.selectionDebounce, Duration.zero);
    });

    test('asserts reject wheelHeight below 1.1x itemExtent', () {
      expect(
        () => WheelSettings(itemExtent: 24, wheelHeight: 26),
        throwsAssertionError,
      );
    });

    test('asserts reject magnification below 1.0', () {
      expect(
        () => WheelSettings(magnification: 0.9),
        throwsAssertionError,
      );
    });

    test('asserts reject non-positive perspectiveDiameter', () {
      expect(
        () => WheelSettings(perspectiveDiameter: 0),
        throwsAssertionError,
      );
    });

    test('asserts reject negative dividerThickness', () {
      expect(
        () => WheelSettings(dividerThickness: -1),
        throwsAssertionError,
      );
    });

    test('asserts reject negative dividerInset', () {
      expect(
        () => WheelSettings(dividerInset: -1),
        throwsAssertionError,
      );
    });

    test('value equality follows all fields', () {
      expect(
        const WheelSettings(),
        equals(const WheelSettings()),
      );
      expect(_kCustom, isNot(equals(const WheelSettings())));
    });

    test('copyWith replaces provided fields and keeps the rest', () {
      final copy = _kCustom.copyWith(magnification: 1.75);
      expect(copy.magnification, 1.75);
      expect(copy.itemExtent, 30);
      expect(copy.selectionDebounce, const Duration(microseconds: 250500));
    });

    test('fromJson of an empty map yields the defaults', () {
      expect(WheelSettings.fromJson(const {}), const WheelSettings());
    });

    test('non-default values round-trip through JSON, preserving '
        'sub-millisecond debounce', () {
      final json = _kCustom.toJson();
      expect(json['selectionDebounce'], 250500);
      expect(WheelSettings.fromJson(json), _kCustom);
    });
  });
}
