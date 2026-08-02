import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_framework/src/state/theme_cubit.dart' show ThemeCubit;

/// Provides [themeCubit] above a [MaterialApp.router] and drives the app's
/// [MaterialApp.themeMode] from its state.
///
/// Takes the cubit by value rather than constructing one, so the instance whose
/// [ThemeCubit.restore] ran during startup is the instance the tree renders.
/// Ownership stays with the caller for the life of the app.
final class ThemeApp extends StatelessWidget {
  /// Creates a [ThemeApp].
  const ThemeApp({
    required this.themeCubit,
    required this.routerConfig,
    super.key,
  });

  /// The cubit holding the active [ThemeMode].
  final ThemeCubit themeCubit;

  /// The router driving the app's navigation.
  final RouterConfig<Object> routerConfig;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>.value(
      value: themeCubit,
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            routerConfig: routerConfig,
            themeMode: themeMode,
            theme: ThemeData(brightness: Brightness.light),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
            ),
          );
        },
      ),
    );
  }
}
