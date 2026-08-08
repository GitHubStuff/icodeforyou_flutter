import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_framework/src/state/theme_cubit.dart' show ThemeCubit;

final class DefaultMaterialAppRouter extends StatelessWidget {
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
