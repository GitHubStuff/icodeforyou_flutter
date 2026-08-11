// programs/{{name.snakeCase()}}/lib/application_startup.dart

import 'package:flutter/material.dart';
import 'package:theme_framework/theme_framework.dart'
    show DefaultMaterialAppRouter, ThemeCubit, ThemeStorageAbstract;

import 'go_routes/routes_framework.dart' show RoutesFramework;

/// {@template application_startup.dart}
/// Composes the application's root dependencies and launches the app.
///
/// [ApplicationStartup] owns the wiring that must exist before the first
/// frame: it creates the [ThemeCubit] backed by the injected
/// [themeStorage], builds the [RoutesFramework] navigation graph, and
/// hands the assembled [DefaultMaterialAppRouter] to [runApp].
///
/// The class is immutable; all mutable state lives in the cubits and
/// router it constructs inside [runner].
/// {@endtemplate}
@immutable
final class ApplicationStartup {
  /// {@macro application_startup.dart}
  const ApplicationStartup({
    required this.themeStorage,
  });

  /// The device store the theme is read from and written to.
  final ThemeStorageAbstract themeStorage;

  /// Builds the app and hands it to [runApp].
  void runner() {
    // The cubit to manage the store of dark/light themes is created here
    // so it can be at the root of the widget tree so changes ripple from
    // the root.
    final themeCubit = ThemeCubit(themeStorage);

    // The routes for navigation.
    final goRouter = RoutesFramework.builtRoutes();

    runApp(
      DefaultMaterialAppRouter(
        themeCubit: themeCubit,
        routerConfig: goRouter,
      ),
    );
  }
}
