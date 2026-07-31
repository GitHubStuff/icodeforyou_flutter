// packages/application_startup/lib/src/application_startup.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:splash_framework/splash_framework.dart' show SplashScreen;
import 'package:theme_framework/theme_framework.dart';

final class ApplicationStartup {
  const ApplicationStartup({
    required this.themeStore,
    required this.splash,
    required this.home,
    required this.error,
    required this.duration,
    required this.tasks,
  });

  final ThemeStore themeStore;
  final Widget splash;
  final Widget home;
  final Widget error;
  final Duration duration;
  final List<Future<void> Function()> tasks;

  void run() {
    late final GoRouter router;

    router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => SplashScreen(
            duration: duration,
            tasks: tasks,
            child: splash,
            onComplete: () {
              context.read<ThemeCubit>().restore();
              context.go('/app');
            },
            onError: (_) => context.go('/error'),
          ),
        ),
        GoRoute(
          path: '/app',
          builder: (context, state) => home,
        ),
        GoRoute(
          path: '/error',
          builder: (context, state) => error,
        ),
      ],
    );

    runApp(
      ThemeApp(
        themeStore: themeStore,
        routerConfig: router,
      ),
    );
  }
}
