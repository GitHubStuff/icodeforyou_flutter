// infinite_scroll_picking_settings/lib/src/settings/settings_holder.dart

// ignore_for_file: always_use_package_imports

import 'package:flutter/foundation.dart' show ChangeNotifier, ValueListenable;
import 'package:flutter/material.dart';

import '../picker_visual_settings/picker_visual_settings.dart';

/// App-wide source of truth for the current [PickerVisualSettings].
///
/// Seeded once at startup by `SettingsLoader` with values loaded from a
/// `SettingsRepository`, then read by every `InfiniteScrollPicker` in the
/// app (typically via `SettingsScope` or a [ValueListenableBuilder]).
///
/// Mutated only by `SettingsCubit` when the user taps Save on the settings
/// screen — preview tweaks during slider drags are held in cubit state and
/// never reach the holder, so a Cancel/pop discards them cleanly.
///
/// Implements [ValueListenable] so it composes with both
/// [InheritedNotifier] (used by `SettingsScope`) and direct
/// [ValueListenableBuilder] consumption.
class SettingsHolder extends ChangeNotifier
    implements ValueListenable<PickerVisualSettings> {
  /// Creates a holder seeded with [initialSettings].
  ///
  /// Production code should construct the holder via `SettingsLoader.load`
  /// rather than calling this directly — the loader handles the
  /// disk-read + default-fallback flow.
  SettingsHolder(PickerVisualSettings initialSettings)
    : _value = initialSettings;

  PickerVisualSettings _value;

  @override
  PickerVisualSettings get value => _value;

  /// Replaces the current settings and notifies all listeners.
  ///
  /// No-op when [next] equals the current value — avoids spurious rebuilds
  /// when the cubit emits a save with unchanged values (e.g. user opens
  /// settings, taps Save without changes).
  void update(PickerVisualSettings next) {
    if (_value == next) return;
    _value = next;
    notifyListeners();
  }
}
