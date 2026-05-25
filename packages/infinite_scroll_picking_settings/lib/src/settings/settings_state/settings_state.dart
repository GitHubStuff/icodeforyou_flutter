// infinite_scroll_picking_settings/lib/src/settings_state/settings_state.dart

// ignore_for_file: comment_references, always_use_package_imports, public_member_api_docs

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../picker_visual_settings/picker_visual_settings.dart';

part 'settings_state.freezed.dart';

/// State emitted by the settings cubit. Sealed so consumers can pattern
/// match exhaustively.
///
/// Lifecycle:
/// * [SettingsState.initial] — cubit constructed, [load] not yet called.
/// * [SettingsState.loading] — a load is in flight.
/// * [SettingsState.loaded] — the settings are in memory and ready to
///   drive the UI. The `isDirty` flag is `true` when the in-memory value
///   diverges from what's persisted.
/// * [SettingsState.error] — load or save failed; the message is
///   surfaced to the user.
@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = SettingsInitial;

  const factory SettingsState.loading() = SettingsLoading;

  const factory SettingsState.loaded({
    required PickerVisualSettings settings,
    @Default(false) bool isDirty,
  }) = SettingsLoaded;

  const factory SettingsState.error({required String message}) = SettingsError;
}
