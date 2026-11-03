import 'dart:async' show unawaited;

import 'package:custom_widgets/custom_widgets.dart' show CrashScreenArgs;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:since_when_dev/go_routes/routes_framework.dart'
    show RoutesFramework;
import 'package:since_when_dev/injection/injection.dart' show getIt;
import 'package:since_when_dev/splash/animated_splash_screen.dart'
    show AnimatedSplashScreen;
import 'package:splash_framework/splash_framework.dart' show SplashScreen;
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;
import 'package:theme_mode_cubit/theme_mode_cubit.dart' show ThemeModeCubit;

///
class MasterialAppRouter extends StatelessWidget {
  ///
  const MasterialAppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeModeCubit, ThemeMode>(
      bloc: getIt<ThemeModeCubit>(),
      builder: (context, themeMode) => MaterialApp.router(
        title: 'Since When (dev)',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeMode,
        routerConfig: _router,
      ),
    );
  }
}

GoRouter _router = GoRouter(
  initialLocation: SplashScreen.route,
  routes: [
    _splashRoute(tasks: List.empty()),
  ],
);

//// Splash screens are [no] fun. They display, then transfer to the /app route
/// on success, or to the terminal /crash route with full failure context on
/// error.
GoRoute _splashRoute({required List<Future<void> Function()> tasks}) => GoRoute(
  path: SplashScreen.route,
  builder: (context, state) {
    return SplashScreen(
      duration: const Duration(milliseconds: 2500),
      tasks: tasks,
      onComplete: () {
        context.go(RoutesFramework.app);
        final vis = getIt<StatusBarVisibilityAbstract>();
        unawaited(vis.setStatusBarVisibility(isHidden: false) as Future<void>?);
      },
      onError: (error, stackTrace) {
        context.go(
          RoutesFramework.crash,
          extra: CrashScreenArgs(error: error, stackTrace: stackTrace),
        );
        final vis = getIt<StatusBarVisibilityAbstract>();
        unawaited(vis.setStatusBarVisibility(isHidden: false) as Future<void>?);
      },
      child: const AnimatedSplashScreen(),
    );
  },
);
