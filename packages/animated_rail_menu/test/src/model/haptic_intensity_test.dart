// test/src/model/haptic_intensity_test.dart

import 'package:animated_rail_menu/src/model/haptic_intensity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HapticIntensity', () {
    test('has four values', () {
      expect(HapticIntensity.values.length, 4);
    });

    test('values are none, light, medium, heavy', () {
      expect(HapticIntensity.values, [
        HapticIntensity.none,
        HapticIntensity.light,
        HapticIntensity.medium,
        HapticIntensity.heavy,
      ]);
    });
  });
}
