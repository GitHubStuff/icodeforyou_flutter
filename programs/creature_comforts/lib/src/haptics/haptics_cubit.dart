// programs/creature_comforts/lib/src/haptics/haptics_cubit.dart
import 'package:app_preferences_service/app_preferences_service.dart';
import 'package:extensions/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_locator/service_locator.dart';

/// Storage key for the user's chosen haptic intensity.
const _kHapticIntensityKey = 'haptic_intensity';

/// Default intensity when the prefs key is absent — quietest non-zero
/// value, matches the system-default impact users expect.
const HapticIntensity _kDefaultIntensity = HapticIntensity.light;

/// Holds the user's chosen [HapticIntensity] and exposes [tap] for
/// buttons to fire feedback at that intensity.
///
/// State *is* the current intensity (no separate state class) — there's
/// only one piece of data the cubit owns and pattern-matching on the
/// state value directly keeps consumers terse.
///
/// Persistence: reads on [bootstrap] from [AppPreferences], writes on
/// every [setIntensity]. No service layer — one prefs key with one
/// user-facing setting doesn't justify the indirection.
final class HapticsCubit extends Cubit<HapticIntensity> {
  /// Creates a cubit defaulted to [_kDefaultIntensity]. Call [bootstrap]
  /// to load the persisted value asynchronously.
  HapticsCubit() : super(_kDefaultIntensity);

  /// Loads the persisted intensity, if any. Falls back to the default
  /// silently if the read fails — broken prefs must not crash the app.
  Future<void> bootstrap() async {
    try {
      final prefs = ServiceRegistry.R
          .getSync<AppPreferences>('AppPreferences')
          .prefs;
      final raw = await prefs.getString(_kHapticIntensityKey);
      if (raw == null) return;
      final parsed = HapticIntensity.values
          .where((v) => v.name == raw)
          .firstOrNull;
      if (parsed != null) emit(parsed);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (_) {
      // Silent fall-through — keep the default intensity.
    }
  }

  /// Updates the user's chosen intensity and persists it.
  ///
  /// Emits the new value first (UI reacts immediately) then writes to
  /// prefs (slow path). A failed write does not roll back the emitted
  /// state — users see their choice take effect even if persistence
  /// has a hiccup.
  Future<void> setIntensity(HapticIntensity intensity) async {
    if (intensity == state) return;
    emit(intensity);
    try {
      final prefs = ServiceRegistry.R
          .getSync<AppPreferences>('AppPreferences')
          .prefs;
      await prefs.setString(_kHapticIntensityKey, intensity.name);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (_) {
      // Silent fall-through — UI already reflects the new value.
    }
  }

  /// Fires haptic feedback at the current intensity. Call from button
  /// `onPressed` handlers via `context.read<HapticsCubit>().tap()`.
  void tap() => state.trigger();
}
