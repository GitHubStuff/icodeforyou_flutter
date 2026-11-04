// programs/since_when_dev/lib/main_app/material_app_router.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:launch_splash_screen/launch_splash_screen.dart'
    show LaunchSplashScreen;
import 'package:place_holder_widget/place_holder_widget.dart'
    show PlaceholderWidget;
import 'package:since_when_dev/home/home_screen.dart' show HomeScreen;
import 'package:since_when_dev/injection/injection.dart' show getIt;
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
    _homeRoute,
  ],
);
