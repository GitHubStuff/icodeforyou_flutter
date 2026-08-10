// infinite_scroll_picking_settings/test/src/settings/settings_holder_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/src/picker_visual_settings/picker_visual_settings.dart'
    show PickerVisualSettings;
import 'package:infinite_scroll_picking_settings/src/settings/settings_holder.dart'
    show SettingsHolder;

void main() {
  group('SettingsHolder', () {
    test('exposes the seeded value', () {
      const initial = PickerVisualSettings(startingIndex: 2);
      final holder = SettingsHolder(initial);
      addTearDown(holder.dispose);

      expect(holder.value, initial);
    });

    test('update replaces the value and notifies listeners', () {
      final holder = SettingsHolder(const PickerVisualSettings());
      addTearDown(holder.dispose);
      var notifications = 0;
      holder.addListener(() => notifications++);

      const next = PickerVisualSettings(startingIndex: 7);
      holder.update(next);

      expect(holder.value, next);
      expect(notifications, 1);
    });

    test('update with an equal value is a no-op and does not notify', () {
      final holder = SettingsHolder(const PickerVisualSettings());
      addTearDown(holder.dispose);
      var notifications = 0;
      holder.addListener(() => notifications++);

      holder.update(const PickerVisualSettings());

      expect(notifications, 0);
      expect(holder.value, const PickerVisualSettings());
    });
  });
}
