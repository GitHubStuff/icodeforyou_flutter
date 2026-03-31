// application_startup/lib/src/app/splash_screen_configuration.dart
import 'package:application_startup/src/app/splash_transitions.dart'
    show SplashTransitions;
import 'package:flutter/material.dart';

/// Holds all configuration values for the splash screen displayed
/// during application startup.
final class SplashScreenConfiguration {
  /// Creates a [SplashScreenConfiguration] with the required splash and
  /// transition settings, and an optional [splashScreen].
  const SplashScreenConfiguration({
    required this.splashScreen,
    required this.splashDuration,
    required this.transition,
    required this.transitionDuration,
    required this.homeScreen,
  });

  /// Root when the splash screen is done.
  final Widget homeScreen;

  /// Full-screen body shown during startup.
  final Widget splashScreen;

  /// Minimum time the splash is visible.
  final Duration splashDuration;

  /// Transition used when navigating from splash to the home screen.
  ///
  /// Use any [RouteTransitionsBuilder] — the package ships convenience
  /// builders on [SplashTransitions].
  final RouteTransitionsBuilder transition;

  /// Duration of the splash-to-home transition animation.
  final Duration transitionDuration;
}
