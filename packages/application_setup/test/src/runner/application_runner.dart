// lib/src/runner/application_runner.dart

import 'package:application_setup/src/app/app_cubit.dart';
import 'package:application_setup/src/app/startup_task.dart';
import 'package:application_setup/src/runner/_app_bootstrapper.dart';
import 'package:application_setup/src/runner/_app_widget.dart';
import 'package:flutter/material.dart';
import 'package:theme_manager/theme_manager.dart';

class ApplicationRunner {
  const ApplicationRunner({
    required this.splashChild,
    required this.landingChild,
    this.tasks = const [],
    this.splashDuration = const Duration(seconds: 3),
    this.transitionDuration = const Duration(milliseconds: 600),
    this.lightTheme,
    this.darkTheme,
    this.transitionsBuilder,
    AppBootstrapper? bootstrapper,
  }) : _bootstrapper = bootstrapper ?? const AppBootstrapper();

  final Widget splashChild;
  final Widget landingChild;
  final List<StartupTask> tasks;
  final Duration splashDuration;
  final Duration transitionDuration;
  final ThemeData? lightTheme;
  final ThemeData? darkTheme;
  final RouteTransitionsBuilder? transitionsBuilder;
  final AppBootstrapper _bootstrapper;

  Future<void> run() async {
    _bootstrapper.ensureInitialized();
    final themeCubit = await ThemeCubit.create();
    final appCubit = AppCubit(
      tasks: tasks,
      splashDuration: splashDuration,
    );
    _bootstrapper.run(
      AppWidget(
        themeCubit: themeCubit,
        appCubit: appCubit,
        splashChild: splashChild,
        landingChild: landingChild,
        transitionDuration: transitionDuration,
        splashDuration: splashDuration,
        lightTheme: lightTheme ?? ThemeData.light(),
        darkTheme: darkTheme ?? ThemeData.dark(),
        transitionsBuilder: transitionsBuilder ?? defaultCrossFade,
      ),
    );
  }

  @visibleForTesting
  static Widget defaultCrossFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> _,
    Widget child,
  ) =>
      FadeTransition(opacity: animation, child: child);
}
