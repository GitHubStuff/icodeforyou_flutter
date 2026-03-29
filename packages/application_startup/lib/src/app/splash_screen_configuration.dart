// application_startup/lib/src/app/splash_screen_configuration.dart
import 'package:application_startup/src/app/splash_transitions.dart'
    show SplashTransitions;
import 'package:flutter/material.dart';

/// Holds all configuration values for the splash screen displayed
/// during application startup.
class SplashScreenConfiguration {
  /// Creates a [SplashScreenConfiguration] with the required splash and
  /// transition settings, and an optional [spinnerWidget].
  const SplashScreenConfiguration({
    required this.splashWidget,
    required this.splashDuration,
    required this.transition,
    required this.transitionDuration,
    this.spinnerWidget,
  });

  /// Full-screen body shown during startup.
  final Widget splashWidget;

  /// Minimum time the splash is visible.
  final Duration splashDuration;

  /// Transition used when navigating from splash to the home screen.
  ///
  /// Use any [RouteTransitionsBuilder] — the package ships convenience
  /// builders on [SplashTransitions].
  final RouteTransitionsBuilder transition;

  /// Duration of the splash-to-home transition animation.
  final Duration transitionDuration;

  /// Widget overlaid on [splashWidget] while startup tasks are still running
  /// after [splashDuration] has elapsed.
  ///
  /// Defaults to a centred [CircularProgressIndicator] when null.
  final Widget? spinnerWidget;
}
