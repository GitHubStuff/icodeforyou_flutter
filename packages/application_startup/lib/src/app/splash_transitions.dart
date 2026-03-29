// application_startup/lib/src/app/splash_transitions.dart
import 'package:flutter/material.dart';

/// A collection of static [PageTransitionsBuilder]-compatible transition
/// functions for use with [Navigator]-compatible route builders.
abstract final class SplashTransitions {
  SplashTransitions._();

  /// Fades the incoming screen in.
  static Widget crossFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => FadeTransition(opacity: animation, child: child);

  /// Slides the incoming screen in from the right.
  static Widget slideLeft(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
    child: child,
  );

  /// Slides the incoming screen in from the left.
  static Widget slideRight(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
    child: child,
  );

  /// Scales the incoming screen up from the centre.
  static Widget expand(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => ScaleTransition(
    scale: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: child,
  );

  /// Scales the outgoing screen down while fading the incoming screen in.
  static Widget shrink(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.92, end: 1).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOut),
      ),
      child: child,
    ),
  );
}
