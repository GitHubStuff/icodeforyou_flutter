import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:splash_framework/splash_framework.dart' show SplashScreen;
import 'package:theme_framework/theme_framework.dart'
    show ThemeApp, ThemeCubit, ThemeStorage;

const String _kSplashRoute = '/splash';
const String _kAppRoute = '/app';
const String _kErrorRoute = '/error';

/// Builds the route table, seeds startup work, and runs the app.
///
/// Owns the [ThemeCubit] for the life of the app: constructs it, restores it,
/// and hands the same instance to [ThemeApp].
///
/// Restoring the theme is prepended to [tasks] rather than triggered when the
/// splash finishes. It is startup work like any other — asynchronous, and
/// required to complete before the splash is dismissed — so it runs behind the
/// black splash and `/app` renders already in the stored mode.
final class ApplicationStartup {
  /// Creates an [ApplicationStartup].
  const ApplicationStartup({
    required this.themeStorage,
    required this.splash,
    required this.home,
    required this.error,
    required this.duration,
    required this.tasks,
  });

  /// The device store the theme is read from and written to.
  final ThemeStorage themeStorage;

  /// The widget shown over the black splash surface.
  final Widget splash;

  /// The screen shown once startup succeeds.
  final Widget home;

  /// The screen shown when a startup task fails.
  final Widget error;

  /// The minimum time the splash stays on screen.
  final Duration duration;

  /// Work performed while the splash is up.
  ///
  /// The theme restore runs ahead of these.
  final List<Future<void> Function()> tasks;

  /// Builds the app and hands it to [runApp].
  void run() {
    final themeCubit = ThemeCubit(themeStorage);

    final startupTasks = <Future<void> Function()>[
      themeCubit.restore,
      ...tasks,
    ];

    final router = GoRouter(
      initialLocation: _kSplashRoute,
      routes: <RouteBase>[
        GoRoute(
          path: _kSplashRoute,
          builder: (context, state) => SplashScreen(
            duration: duration,
            tasks: startupTasks,
            onComplete: () => context.go(_kAppRoute),
            onError: (_) => context.go(_kErrorRoute),
            child: splash,
          ),
        ),
        GoRoute(path: _kAppRoute, builder: (context, state) => home),
        GoRoute(path: _kErrorRoute, builder: (context, state) => error),
      ],
    );

    runApp(ThemeApp(themeCubit: themeCubit, routerConfig: router));
  }
}
