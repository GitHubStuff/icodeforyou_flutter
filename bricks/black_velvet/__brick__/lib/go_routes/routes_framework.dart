// programs/{{name.snakeCase()}}/lib/go_routes/routes_framework.dart

import 'dart:async' show unawaited;

import 'package:custom_widgets/custom_widgets.dart'
    show CrashScreen, CrashScreenArgs;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:splash_framework/splash_framework.dart' show SplashScreen;
import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;

import '../screens/animated_splash_screen.dart' show AnimatedSplashScreen;
import '../screens/rail_screen.dart' show RailScreen;

part 'routes.goroute.dart';

/// {@template routes_framework}
/// Central routing framework for the application.
///
/// Owns every route path exposed by the app and assembles the fully
/// configured [GoRouter] instance consumed at startup. Route path
/// constants are declared here — and only here — so that navigation
/// call sites reference a single source of truth instead of scattering
/// string literals throughout the codebase.
///
/// The individual [GoRoute] builders live in the `routes.goroute.dart`
/// part file, keeping this class focused on the public routing surface
/// while the part carries the per-route construction details.
///
/// Typical usage wires the built router into the application shell:
///
/// ```dart
/// ThemeApp(
///   routerConfig: RoutesFramework.builtRoutes(),
/// )
/// ```
/// {@endtemplate}
class RoutesFramework {
  /// {@macro rail_destination_buttons}
  ///
  /// Navigated to once startup work completes and the splash
  /// sequence has finished.
  static const app = '/app';

  /// Route path for the crash screen.
  ///
  /// Navigated to when an unrecoverable error is caught, with a
  /// [CrashScreenArgs] instance supplied via `state.extra` so the
  /// [CrashScreen] can render the failure details.
  static const crash = '/crash';

  /// Route path for the splash screen.
  ///
  /// The application's initial location; hosts the [SplashScreen]
  /// while startup tasks run.
  static const splash = '/splash';

  /// Builds the application's fully configured [GoRouter].
  ///
  /// The router starts at [splash] and registers the application,
  /// crash, and splash routes. Call once during startup and hand the
  /// result to the router-aware application widget.
  static GoRouter builtRoutes() {
    return GoRouter(
      initialLocation: splash,
      routes: <RouteBase>[
        _appRoute(),
        _crashRoute(),
        _splashRoute(),
      ],
    );
  }
}
