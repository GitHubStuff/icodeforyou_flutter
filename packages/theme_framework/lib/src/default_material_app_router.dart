// packages/theme_framework/lib/src/default_material_app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_framework/src/cubit/theme_cubit.dart' show ThemeCubit;

/// A root application widget that binds a [MaterialApp.router] to
/// a [ThemeCubit].
///
/// [DefaultMaterialAppRouter] ensures that the application responds dynamically
/// to [ThemeMode] changes. It wraps the app in a [BlocProvider] to make the
/// [themeCubit] available to the rest of the widget tree, and uses a
/// [BlocBuilder] to rebuild the [MaterialApp] whenever the theme state changes.
///
/// This is typically used as the top-most widget in your application tree,
/// passed directly to `runApp` or nested just below your localization
/// providers.
final class DefaultMaterialAppRouter extends StatelessWidget {
  /// Creates a [DefaultMaterialAppRouter].
  ///
  /// The [themeCubit] and [routerConfig] are required. If theme data arguments
  /// are omitted, fallback [ThemeData] configurations are automatically
  /// applied.
  const DefaultMaterialAppRouter({
    required this.themeCubit,
    required this.routerConfig,
    this.theme,
    this.darkTheme,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    super.key,
  });

  /// The cubit holding the active [ThemeMode].
  final ThemeCubit themeCubit;

  /// The router driving the app's navigation.
  final RouterConfig<Object> routerConfig;

  /// The light theme. Defaults to a plain [Brightness.light] theme.
  final ThemeData? theme;

  /// The dark theme. Defaults to a [Brightness.dark] theme with a black
  /// scaffold background.
  final ThemeData? darkTheme;

  /// The theme used when the platform requests high contrast in light mode.
  ///
  /// When null, [MaterialApp] falls back to [theme].
  final ThemeData? highContrastTheme;

  /// The theme used when the platform requests high contrast in dark mode.
  ///
  /// When null, [MaterialApp] falls back to [darkTheme].
  final ThemeData? highContrastDarkTheme;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>.value(
      value: themeCubit,
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            routerConfig: routerConfig,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            theme: theme ?? ThemeData(brightness: Brightness.light),
            darkTheme:
                darkTheme ??
                ThemeData(
                  brightness: Brightness.dark,
                  scaffoldBackgroundColor: Colors.black,
                ),
            highContrastTheme: highContrastTheme,
            highContrastDarkTheme: highContrastDarkTheme,
          );
        },
      ),
    );
  }
}
