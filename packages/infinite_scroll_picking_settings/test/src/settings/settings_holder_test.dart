// infinite_scroll_picking_settings/test/src/settings/settings_holder_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/infinite_scroll_picking_settings.dart';

void main() {
  group('SettingsHolder', () {
    const initial = PickerVisualSettings(startingIndex: 1);
    const next = PickerVisualSettings(startingIndex: 4);

    test('seeds value from the constructor argument', () {
      final holder = SettingsHolder(initial);
      expect(holder.value, initial);
    });

    test('update() replaces value and notifies listeners', () {
      final holder = SettingsHolder(initial);
      var notifications = 0;
      holder.addListener(() => notifications++);

      holder.update(next);

      expect(holder.value, next);
      expect(notifications, 1);
    });

    test('update() is a no-op when next equals current value', () {
      final holder = SettingsHolder(initial);
      var notifications = 0;
      holder.addListener(() => notifications++);

      holder.update(initial);

      expect(holder.value, initial);
      expect(notifications, 0);
    });

    test('update() compares by value equality, not identity', () {
      // Two distinct instances with the same fields should be considered
      // equal by the freezed-generated `==`, so update() should no-op.
      final holder = SettingsHolder(const PickerVisualSettings());
      var notifications = 0;
      holder.addListener(() => notifications++);

      // ignore: prefer_const_constructors
      holder.update(PickerVisualSettings());

      expect(notifications, 0);
    });

    test('successive distinct updates each fire a notification', () {
      final holder = SettingsHolder(initial);
      var notifications = 0;
      holder.addListener(() => notifications++);

      holder
        ..update(next)
        ..update(initial)
        ..update(next);

      expect(notifications, 3);
      expect(holder.value, next);
    });
  });
}
