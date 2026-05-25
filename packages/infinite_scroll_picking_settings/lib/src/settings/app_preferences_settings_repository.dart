// infinite_scroll_picking_settings/lib/src/settings/app_preferences_settings_repository.dart

// ignore_for_file: comment_references, public_member_api_docs, always_use_package_imports

import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:app_preferences/app_preferences.dart'
    show AbstractPreferencesInterface;

import '../picker_visual_settings/picker_visual_settings.dart';
import 'settings_repository.dart';

/// [SettingsRepository] backed by an [AbstractPreferencesInterface] —
/// typically a `PlatformPreferences` (shared_preferences) or
/// `HivePreferences` instance from the `app_preferences` package.
///
/// Stores [PickerVisualSettings] as a single JSON string under
/// [storageKey]. The whole settings object is treated as one atomic
/// preference — there is no field-level partial save, which prevents the
/// torn-state hazard called out in the [SettingsRepository] interface.
///
/// Construct once at the app composition root, hand it to
/// `SettingsLoader.load(repository: ...)`, and pass the resulting holder
/// to a `SettingsScope`:
///
/// ```dart
/// final prefs = await PlatformPreferences.create();
/// final repo = AppPreferencesSettingsRepository(prefs);
/// final holder = await SettingsLoader.load(repository: repo);
/// runApp(SettingsScope(holder: holder, child: const MyApp()));
/// ```
class AppPreferencesSettingsRepository implements SettingsRepository {
  /// Creates a repository that reads and writes [PickerVisualSettings]
  /// JSON under [storageKey] in [prefs].
  ///
  /// [storageKey] defaults to [defaultStorageKey] (`'InfiniteScrollPicking'`).
  /// Override it when more than one set of picker settings needs to coexist
  /// in the same store, or to namespace the key inside a larger app's
  /// preference scheme (e.g. `'mySpace.pickerVisuals'`).
  const AppPreferencesSettingsRepository(
    this._prefs, {
    this.storageKey = defaultStorageKey,
  });

  /// Default storage key used when none is supplied to the constructor.
  static const String defaultStorageKey = 'InfiniteScrollPicking';

  final AbstractPreferencesInterface _prefs;

  /// The key under which the JSON-encoded settings live in [_prefs].
  final String storageKey;

  /// Reads the persisted JSON string and decodes it back into a
  /// [PickerVisualSettings].
  ///
  /// Returns `null` when the key is missing — first launch, or after
  /// [clear]. Throws [FormatException] when the stored string is present
  /// but cannot be parsed as JSON, and rethrows whatever
  /// [PickerVisualSettings.fromJson] throws on schema mismatch.
  /// Distinguishing "missing" from "broken" is required by the
  /// [SettingsRepository] contract so the cubit can fall back to defaults
  /// for the former and surface an error for the latter.
  @override
  Future<PickerVisualSettings?> load() async {
    final raw = await _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException(
        'Stored settings under "$storageKey" decoded to '
        '${decoded.runtimeType}, expected Map<String, dynamic>.',
        raw,
      );
    }
    return PickerVisualSettings.fromJson(decoded);
  }

  /// Encodes [settings] as a JSON string and writes it under [storageKey],
  /// overwriting any prior value.
  ///
  /// `jsonEncode` is synchronous; the underlying preference write may be
  /// async — both errors propagate to the caller, where the cubit converts
  /// them into a `SettingsState.error`.
  @override
  Future<void> save(PickerVisualSettings settings) async {
    final encoded = jsonEncode(settings.toJson());
    await _prefs.setString(storageKey, encoded);
  }

  /// Removes the persisted JSON, if any. After this completes, [load]
  /// returns `null` until the next [save].
  @override
  Future<void> clear() => _prefs.remove(storageKey);
}
