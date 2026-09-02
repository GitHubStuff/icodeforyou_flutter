// packages/infinite_scroll_picking_settings/test/infinite_scroll_picking_settings_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/infinite_scroll_picking_settings.dart';

/// Smoke tests proving every symbol exported by the package barrel
/// resolves through the barrel import alone.
void main() {
  group('infinite_scroll_picking_settings barrel', () {
    test('exports the settings model types', () {
      expect(const PickerVisualSettings(), isA<PickerVisualSettings>());
      expect(const WheelSettings(), isA<WheelSettings>());
    });

    test('exports the settings infrastructure', () {
      expect(AppPreferencesSettingsRepository, isNotNull);
      expect(SettingsCubit, isNotNull);
      expect(SettingsHolder, isNotNull);
      expect(SettingsLoader, isNotNull);
      expect(SettingsRepository, isNotNull);
      expect(SettingsScope, isNotNull);
      expect(SettingsScreen, isNotNull);
    });

    test('exports the sealed state hierarchy', () {
      expect(const SettingsState.initial(), isA<SettingsInitial>());
      expect(const SettingsState.loading(), isA<SettingsLoading>());
      expect(
        const SettingsState.loaded(settings: PickerVisualSettings()),
        isA<SettingsLoaded>(),
      );
      expect(
        const SettingsState.error(message: 'x'),
        isA<SettingsError>(),
      );
    });
  });
}
