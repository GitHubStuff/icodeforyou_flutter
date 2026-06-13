// infinite_scroll_picking_settings/lib/src/settings/settings_cubit.dart
// ignore_for_file: public_member_api_docs, always_use_package_imports

import 'package:flutter_bloc/flutter_bloc.dart';

import '../picker_visual_settings/picker_visual_settings.dart';
import 'settings_holder.dart';
import 'settings_repository.dart';
import 'settings_state/settings_state.dart';

/// Orchestrates the settings screen's edit-preview-save lifecycle, mediating
/// between in-memory edits, the persistence layer, and the app-wide
/// [SettingsHolder] that drives every live picker.
///
/// The cubit is constructed with the holder already seeded by the startup
/// `SettingsLoader`, so it emits `loaded(clean)` immediately — no async
/// load step on the screen. Edits during the session live only in cubit
/// state (preview); the holder is updated only when [save] succeeds.
///
/// State transitions:
/// * ctor → `loaded(holder.value, clean)`
/// * `loaded(*)` → [updateSettings] → `loaded(working, dirty)` (preview only)
/// * `loaded(dirty)` → [save] → `loaded(working, clean)` | `error`
///                              ↳ on success: holder.update(working)
/// * `loaded(*)` → [reset] → `loaded(defaults, dirty)` (preview only)
/// * `loaded(*)` → [clearPersisted] → `loaded(defaults, clean)` | `error`
///                                   ↳ on success: holder.update(defaults)
///
/// The cubit doesn't know whether the [SettingsRepository] is backed by
/// `app_preferences`, Hive, a file, or a fake — DIP keeps it that way.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required SettingsHolder holder,
    required this._repository,
  }) : _holder = holder,
       super(SettingsState.loaded(settings: holder.value));

  final SettingsHolder _holder;
  final SettingsRepository _repository;

  /// Replaces the in-memory working copy and marks it dirty. Holder is
  /// **not** touched — live pickers across the app keep showing the
  /// last-saved values until [save] is called. No-op unless the cubit is
  /// in `loaded` state.
  void updateSettings(PickerVisualSettings settings) {
    final current = state;
    if (current is! SettingsLoaded) {
      assert(
        false,
        'updateSettings called from $current; expected SettingsLoaded',
      );
      return;
    }
    emit(SettingsState.loaded(settings: settings, isDirty: true));
  }

  /// Persists the current in-memory settings, then propagates them to the
  /// holder so every live picker rebuilds. Repository write happens first;
  /// on failure the holder is **not** updated and `error` is emitted. No-op
  /// unless the cubit is in `loaded` state.
  Future<void> save() async {
    final current = state;
    if (current is! SettingsLoaded) {
      assert(false, 'save called from $current; expected SettingsLoaded');
      return;
    }
    try {
      await _repository.save(current.settings);
      _holder.update(current.settings);
      emit(SettingsState.loaded(settings: current.settings));
    } on Exception catch (e) {
      emit(SettingsState.error(message: 'Failed to save settings: $e'));
    }
  }

  /// Resets the in-memory settings to defaults and marks them dirty. Does
  /// not touch storage or the holder — the user must [save] to commit.
  void reset() {
    emit(
      const SettingsState.loaded(
        settings: PickerVisualSettings(),
        isDirty: true,
      ),
    );
  }

  /// Clears the persisted settings, resets the holder to defaults, and
  /// emits `loaded(defaults, clean)`. On failure, emits `error` and the
  /// holder is left untouched.
  Future<void> clearPersisted() async {
    try {
      await _repository.clear();
      const defaults = PickerVisualSettings();
      _holder.update(defaults);
      emit(const SettingsState.loaded(settings: defaults));
    } on Exception catch (e) {
      emit(SettingsState.error(message: 'Failed to clear settings: $e'));
    }
  }
}
