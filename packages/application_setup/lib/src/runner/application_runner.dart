// lib/src/runner/application_runner.dart

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/app_view.dart';
import 'package:application_setup/src/app/startup_task.dart';
import 'package:application_setup/src/runner/_app_bootstrapper.dart';
import 'package:application_setup/src/runner/_app_widget.dart';
import 'package:flutter/material.dart';
import 'package:theme_manager/theme_manager.dart';

class ApplicationRunner {
  const ApplicationRunner({
    required this.splashBuilder,
    required this.app,
    this.tasks = const [],
    this.transitionDuration = const Duration(milliseconds: 600),
    this.lightTheme,
    this.darkTheme,
    this.transitionsBuilder,
    this.onReady,
    AppBootstrapper? bootstrapper,
  }) : _bootstrapper = bootstrapper ?? const AppBootstrapper();

  /// Builder that receives [onSplashDone] and returns the splash widget.
  ///
  /// The callback must be forwarded to the splash widget's completion
  /// hook so the cubit knows when the splash animation has finished.
  ///
  /// ```dart
  /// splashBuilder: (onComplete) => GrowAndFadeWidgetView(
  ///   duration: const Duration(milliseconds: 1200),
  ///   onComplete: onComplete,
  ///   child: const FlutterLogo(size: 120),
  /// ),
  /// ```
  final Widget Function(VoidCallback onSplashDone) splashBuilder;

  /// The root widget displayed after startup completes.
  final Widget app;

  final List<StartupTask> tasks;
  final Duration transitionDuration;
  final ThemeData? lightTheme;
  final ThemeData? darkTheme;
  final RouteTransitionsBuilder? transitionsBuilder;
  final void Function(ThemeCubit)? onReady;
  final AppBootstrapper _bootstrapper;

  Future<void> run() async {
    _bootstrapper.ensureInitialized();
    final themeCubit = await ThemeCubit.create();
    onReady?.call(themeCubit);
    final appCubit = AppCubit(tasks: tasks);
    _bootstrapper.run(
      AppWidget(
        themeCubit: themeCubit,
        appCubit: appCubit,
        splashBuilder: splashBuilder,
        app: app,
        transitionDuration: transitionDuration,
        lightTheme: lightTheme ?? ThemeData.light(),
        darkTheme: darkTheme ?? ThemeData.dark(),
        transitionsBuilder: transitionsBuilder ?? AppView.crossFade,
      ),
    );
  }
}
