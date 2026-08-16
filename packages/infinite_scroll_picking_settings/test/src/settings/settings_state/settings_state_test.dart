// packages/infinite_scroll_picking_settings/test/src/settings/settings_state/settings_state_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_picking_settings/src/picker_visual_settings/picker_visual_settings.dart'
    show PickerVisualSettings;
import 'package:infinite_scroll_picking_settings/src/settings/settings_state/settings_state.dart'
    show
        SettingsError,
        SettingsInitial,
        SettingsLoaded,
        SettingsLoading,
        SettingsState;

/// Names each sealed case through an exhaustive switch — the compiler
/// enforces that no case is forgotten here.
String _describe(SettingsState state) => switch (state) {
      SettingsInitial() => 'initial',
      SettingsLoading() => 'loading',
      SettingsLoaded(:final isDirty) => 'loaded(dirty: $isDirty)',
      SettingsError(:final message) => 'error($message)',
    };

void main() {
  group('SettingsState', () {
    test('initial and loading construct and compare by value', () {
      expect(const SettingsState.initial(), const SettingsInitial());
      expect(const SettingsState.loading(), const SettingsLoading());
      expect(
        const SettingsState.initial(),
        isNot(equals(const SettingsState.loading())),
      );
    });

    test('loaded carries settings and defaults isDirty to false', () {
      const state = SettingsState.loaded(settings: PickerVisualSettings());
      expect(state, isA<SettingsLoaded>());
      final loaded = state as SettingsLoaded;
      expect(loaded.settings, const PickerVisualSettings());
      expect(loaded.isDirty, isFalse);
    });

    test('loaded equality covers both settings and isDirty', () {
      const clean = SettingsState.loaded(settings: PickerVisualSettings());
      const dirty = SettingsState.loaded(
        settings: PickerVisualSettings(),
        isDirty: true,
      );
      expect(
        clean,
        const SettingsState.loaded(settings: PickerVisualSettings()),
      );
      expect(clean, isNot(equals(dirty)));
    });

    test('error carries its message', () {
      const state = SettingsState.error(message: 'boom');
      expect(state, isA<SettingsError>());
      expect((state as SettingsError).message, 'boom');
      expect(state, const SettingsState.error(message: 'boom'));
    });

    test('the sealed hierarchy is exhaustively matchable', () {
      expect(_describe(const SettingsState.initial()), 'initial');
      expect(_describe(const SettingsState.loading()), 'loading');
      expect(
        _describe(
          const SettingsState.loaded(
            settings: PickerVisualSettings(),
            isDirty: true,
          ),
        ),
        'loaded(dirty: true)',
      );
      expect(
        _describe(const SettingsState.error(message: 'x')),
        'error(x)',
      );
    });
  });
}
