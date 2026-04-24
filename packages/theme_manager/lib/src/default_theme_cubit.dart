// theme_manager/lib/src/default_theme_cubit.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:theme_manager/src/theme_cubit_base.dart';
import 'package:theme_manager/src/theme_persistence.dart';

/// Default concrete implementation of [ThemeCubitBase] with persistence.
///
/// Manages the active [ThemeMode] and persists the user's selection via a
/// [ThemePersistenceAbstract] backend so that the chosen theme is restored
/// across app launches. The light and dark [ThemeData] instances are injected
/// at construction time, keeping this cubit decoupled from any specific
/// design system.
///
/// Instances must be obtained through the asynchronous [create] factory,
/// which performs persistence initialization and mode restoration. The
/// default constructor is intentionally disabled and will throw
/// [UnsupportedError] if invoked.
///
/// Example:
///
/// ```dart
/// final themeCubit = await DefaultThemeCubit.create(
///   darkTheme: myDarkTheme,
///   lightTheme: myLightTheme,
/// );
/// ```
class DefaultThemeCubit extends ThemeCubitBase {
  /// Disabled default constructor.
  ///
  /// Always throws [UnsupportedError]. Use [DefaultThemeCubit.create] to
  /// obtain a properly initialized instance, as construction requires
  /// asynchronous persistence setup.
  factory DefaultThemeCubit() => throw UnsupportedError(
    'Cannot invoke ThemeCubit() directly.\n'
    'Use DefaultThemeCubit.create() instead.\n'
    ' note: "create()" is async and returns'
    '  Future<ThemeCubit> create()',
  );

  /// Private constructor used by [create] to wire up dependencies.
  ///
  /// Seeds the cubit with [ThemeMode.dark] as a provisional initial state;
  /// [create] will emit the restored mode immediately after construction if
  /// it differs from this default.
  DefaultThemeCubit._(this._persistence, this._darkTheme, this._lightTheme)
    : super(ThemeMode.dark);

  /// Backend used to load and save the selected [ThemeMode].
  final ThemePersistenceAbstract _persistence;

  /// [ThemeData] returned by [dark].
  final ThemeData _darkTheme;

  /// [ThemeData] returned by [light].
  final ThemeData _lightTheme;

  /// Asynchronously creates and initializes a [DefaultThemeCubit].
  ///
  /// Initializes the [ThemePersistenceAbstract] backend, loads any previously
  /// persisted [ThemeMode], and constructs the cubit with the supplied
  /// [darkTheme] and [lightTheme]. If the restored mode differs from the
  /// provisional initial state, it is emitted before the cubit is returned
  /// so listeners observe the correct mode on first build.
  ///
  /// This is the only supported way to instantiate a [DefaultThemeCubit].
  static Future<DefaultThemeCubit> create({
    required ThemeData darkTheme,
    required ThemeData lightTheme,
  }) async {
    final persistence = await ThemePersistence.create();
    final restoredMode = persistence.load();
    final cubit = DefaultThemeCubit._(
      persistence,
      darkTheme,
      lightTheme,
    );
    if (restoredMode != cubit.state) {
      cubit.emit(restoredMode);
    }
    return cubit;
  }

  /// The [ThemeData] applied when the active mode resolves to dark.
  @override
  ThemeData get dark => _darkTheme;

  /// The [ThemeData] applied when the active mode resolves to light.
  @override
  ThemeData get light => _lightTheme;

  /// Switches the active theme to [ThemeMode.light] and persists the choice.
  @override
  void toLight() => _emit(ThemeMode.light);

  /// Switches the active theme to [ThemeMode.dark] and persists the choice.
  @override
  void toDark() => _emit(ThemeMode.dark);

  /// Switches the active theme to [ThemeMode.system] and persists the choice,
  /// deferring the effective brightness to the platform setting.
  @override
  void toSystem() => _emit(ThemeMode.system);

  /// Emits [mode] to listeners and asynchronously persists it.
  ///
  /// The emit happens synchronously so UI updates are immediate; the
  /// persistence write is fire-and-forget and does not block state changes.
  FutureOr<void> _emit(ThemeMode mode) async {
    emit(mode);
    _persistence.save(mode);
  }
}
