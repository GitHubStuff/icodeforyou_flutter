// infinite_scroll_picking_settings/lib/infinite_scroll_picking_settings.dart

// ignore_for_file: comment_references

/// Settings screen and persistable visual configuration for the
/// `infinite_scroll_picking` package.
///
/// Provides [SettingsScreen] — a full-screen editor for a
/// [PickerVisualSettings] — driven by a [SettingsCubit] backed by a
/// caller-supplied [SettingsRepository]. Use the [WheelSettingsMapper],
/// [WheelConfigMapper], and [PickerVisualSettingsMapper] extensions to
/// convert between the persistable settings types and the runtime config
/// types from the picker package.
///
/// App-wide hydration is provided by [SettingsLoader] (call once at
/// startup), which produces a [SettingsHolder] to wrap with [SettingsScope]
/// near the root of the widget tree. Pickers anywhere in the app then read
/// the current settings via `SettingsScope.watch(context)`.
///
/// For persistence backed by `app_preferences` (shared_preferences, Hive,
/// or any custom [AbstractPreferencesInterface]), use
/// [AppPreferencesSettingsRepository] as the [SettingsRepository]
/// implementation passed to [SettingsLoader.load].
library;

export 'src/picker_visual_settings/picker_visual_settings.dart'
    show PickerVisualSettings;
export 'src/settings/app_preferences_settings_repository.dart'
    show AppPreferencesSettingsRepository;
export 'src/settings/settings_cubit.dart' show SettingsCubit;
export 'src/settings/settings_holder.dart' show SettingsHolder;
export 'src/settings/settings_loader.dart' show SettingsLoader;
export 'src/settings/settings_mapper.dart'
    show PickerVisualSettingsMapper, WheelConfigMapper, WheelSettingsMapper;
export 'src/settings/settings_repository.dart' show SettingsRepository;
export 'src/settings/settings_scope.dart' show SettingsScope;
export 'src/settings/settings_state/settings_state.dart'
    show
        SettingsError,
        SettingsInitial,
        SettingsLoaded,
        SettingsLoading,
        SettingsState;
export 'src/wheel_settings/wheel_settings.dart' show WheelSettings;
export 'src/widgets/settings_screen.dart' show SettingsScreen;
