// test/src/_settings_direction_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:settings_widget/src/_settings_direction.dart';

void main() {
  group('SettingsDirection', () {
    test('has four values', () {
      expect(SettingsDirection.values, hasLength(4));
    });

    test('contains top', () {
      expect(SettingsDirection.values, contains(SettingsDirection.top));
    });

    test('contains bottom', () {
      expect(SettingsDirection.values, contains(SettingsDirection.bottom));
    });

    test('contains left', () {
      expect(SettingsDirection.values, contains(SettingsDirection.left));
    });

    test('contains right', () {
      expect(SettingsDirection.values, contains(SettingsDirection.right));
    });
  });
}
