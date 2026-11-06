// programs/since_when_dev/lib/main_app/material_app_router.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:launch_splash_screen/launch_splash_screen.dart'
    show LaunchSplashScreen;
import 'package:since_when_dev/home/home_screen.dart' show HomeScreen;
import 'package:since_when_dev/main_app/configure_dependencies.dart' show getIt;
import 'package:since_when_dev/menu_bar/menu_bar_screen.dart'
    show MenuBarScreen;
import 'package:since_when_dev/splash/default_splash_art.dart';
import 'package:splash_framework/splash_framework.dart' show SplashScreen;
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;
import 'package:theme_mode_cubit/theme_mode_cubit.dart' show ThemeModeCubit;

part 'route_home_screen.dart';
part 'route_splash_screen.dart';

/// Upper bound on the splash; exceeding it is reported via `onFailure`.
const _splashTimeout = Duration(seconds: 3);

/// Length of the splash-to-home cross-fade.
const _crossFadeDuration = Duration(milliseconds: 1500);

/// Root widget: a [MaterialApp.router] whose [ThemeMode] follows
/// [ThemeModeCubit] and whose navigation is owned by [_router].
class MaterialAppRouter extends StatelessWidget {
  /// Creates the root widget.
  const MaterialAppRouter({super.key});

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

/// Route table. Created once so [MaterialApp.router] keeps the same
/// [GoRouter] across theme rebuilds.
final GoRouter _router = GoRouter(
  initialLocation: SplashScreen.route,
  routes: [
    _splashRoute,
    _menuBarRoute,
  ],
);

final GoRoute _menuBarRoute = GoRoute(
  path: MenuBarScreen.route,
  pageBuilder: (_, state) => CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: _crossFadeDuration,
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
    child: MenuBarScreen(),
  ),
);

/// How long the splash stays visible before completing.
const _splashDuration = Duration(milliseconds: 2500);

/// Launch splash. On completion it replaces itself with [HomeScreen] via
/// `context.go`, leaving [HomeScreen] as the sole root of the stack.
/// Failure handling is not yet wired; failures are only logged.
final GoRoute _splashRoute = GoRoute(
  path: SplashScreen.route,
  builder: (_, _) => LaunchSplashScreen(
    splashDuration: _splashDuration,
    timeoutDuration: _splashTimeout,
    spinner: const CircularProgressIndicator(),
    onCompleted: (context) async {
      await _showStatusBarAfterSplashScreen();
      if (context.mounted) {
        context.go(MenuBarScreen.route);
      } else {
        throw StateError('failed to reach ${MenuBarScreen.route}');
      }
    },
    onFailure: (context, error, stackTrace) async {
      await _showStatusBarAfterSplashScreen();
    },
    child: const DefaultSplashArt(),
  ),
);

/// If the splash screen completes, or errors out, restore the status bar
Future<void> _showStatusBarAfterSplashScreen() async {
  await getIt<StatusBarVisibilityAbstract>().setStatusBarVisibility(
    isHidden: false,
  );
}
