// theme_manager/lib/src/theme_cubit_base.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Abstract base class for a [Cubit] that manages application theme state.
///
/// Emits [ThemeMode] values to signal which theme variant should be active:
/// [ThemeMode.light], [ThemeMode.dark], or [ThemeMode.system]. Concrete
/// implementations are responsible for supplying the actual [ThemeData]
/// instances and defining how mode transitions are performed (including any
/// persistence of the user's selection).
///
/// Typical usage involves providing this cubit above a [MaterialApp] and
/// wiring its state to the app's `themeMode`, while [dark] and [light] supply
/// the corresponding `darkTheme` and `theme` values.
abstract class ThemeCubitBase extends Cubit<ThemeMode> {
  /// Creates a [ThemeCubitBase] seeded with [initialState].
  ///
  /// The [initialState] determines which [ThemeMode] is emitted before any
  /// user interaction or persisted preference is applied.
  ThemeCubitBase(super.initialState);

  /// The [ThemeData] used when the current mode resolves to dark.
  ///
  /// Consumers should bind this to [MaterialApp.darkTheme].
  ThemeData get dark;

  /// The [ThemeData] used when the current mode resolves to light.
  ///
  /// Consumers should bind this to [MaterialApp.theme].
  ThemeData get light;

  /// Transitions the cubit to [ThemeMode.light].
  ///
  /// Implementations should emit [ThemeMode.light] and persist the choice
  /// where applicable.
  void toLight();

  /// Transitions the cubit to [ThemeMode.dark].
  ///
  /// Implementations should emit [ThemeMode.dark] and persist the choice
  /// where applicable.
  void toDark();

  /// Transitions the cubit to [ThemeMode.system].
  ///
  /// Implementations should emit [ThemeMode.system] and persist the choice
  /// where applicable, deferring the effective brightness to the platform.
  void toSystem();
}
