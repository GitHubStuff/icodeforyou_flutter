import 'package:black_velvet/go_routes/routes_framework.dart'
    show RoutesFramework;
import 'package:flutter/material.dart';
import 'package:theme_framework/theme_framework.dart'
    show DefaultMaterialAppRouter, ThemeCubit, ThemeStorageAbstract;

final class ApplicationStartup {
  const ApplicationStartup({
    required this.themeStorage,
  });

  /// The device store the theme is read from and written to.
  final ThemeStorageAbstract themeStorage;

  /// Builds the app and hands it to [runApp].
  void runner() {
    /// The cubit to manage the store of dark/light themes is created here
    /// so it can be at the root of the widget tree so changes ripple from
    /// the root
    final themeCubit = ThemeCubit(themeStorage);

    /// The routes for navigation
    final goRouter = RoutesFramework.builtRoutes();

    runApp(
      DefaultMaterialAppRouter(
        themeCubit: themeCubit,
        routerConfig: goRouter,
      ),
    );
  }
}
