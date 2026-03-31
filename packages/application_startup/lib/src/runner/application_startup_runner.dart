// application_startup/lib/src/runner/application_startup_runner.dart
import 'dart:async' show FutureOr;

import 'package:application_startup/application_startup.dart'
    show SplashScreenConfiguration, StartupTask;
import 'package:application_startup/src/cubit/cubit.dart' show AppCubit;
import 'package:application_startup/src/runner/_app_bootstrapper.dart'
    show AppBootstrapper;
import 'package:application_startup/src/runner/_app_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:theme_manager/theme_manager.dart'
    show DefaultThemeCubit, ThemeCubitBase;

/// Orchestrates application startup, wiring together theming, splash
/// configuration, and ordered [StartupTask] execution before handing
/// off to [homeScreen].
class ApplicationStartupRunner {
  /// Creates an [ApplicationStartupRunner].
  ///
  /// [bootstrapper] defaults to [AppBootstrapper] if not provided.
  /// [createFunc] defaults to [DefaultThemeCubit.create] if not provided.
  const ApplicationStartupRunner({
    required this.splashConfig,
    required this.homeScreen,
    this.tasks = const [],
    this.lightTheme,
    this.darkTheme,
    AppBootstrapper? bootstrapper,
    this.createFunc,
  }) : _bootstrapper = bootstrapper ?? const AppBootstrapper();

  /// Configuration for the splash screen displayed during startup.
  final SplashScreenConfiguration splashConfig;

  /// The widget displayed after all [tasks] complete successfully.
  final Widget homeScreen;

  /// Ordered list of [StartupTask] instances executed before [homeScreen].
  final List<StartupTask> tasks;

  /// Optional light [ThemeData]; defaults to [ThemeData.light] with Material 3.
  final ThemeData? lightTheme;

  /// Optional dark [ThemeData]; defaults to [ThemeData.dark] with Material 3.
  final ThemeData? darkTheme;

  final AppBootstrapper _bootstrapper;

  /// Optional factory for [ThemeCubitBase]; defaults to [DefaultThemeCubit.create].
  final FutureOr<ThemeCubitBase> Function()? createFunc;

  /// Initialises Flutter bindings, resolves theming, registers the
  /// [ThemeCubitBase] singleton, and runs the application.
  Future<void> run() async {
    _bootstrapper.ensureInitialized();
    final cubit = await (createFunc ?? DefaultThemeCubit.create)();
    GetIt.I.registerSingleton<ThemeCubitBase>(cubit);
    final appCubit = AppCubit(tasks: tasks);
    _bootstrapper.run(
      AppWidget(
        appCubit: appCubit,
        splashConfig: splashConfig,
        homeScreen: homeScreen,
        tasks: tasks,
        lightTheme: lightTheme ?? ThemeData.light(useMaterial3: true),
        darkTheme: darkTheme ?? ThemeData.dark(useMaterial3: true),
      ),
    );
  }
}
