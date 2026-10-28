// programs/since_when_dev/lib/splash/animated_splash_screen.dart
import 'package:flutter/widgets.dart';
import 'package:island_control/island_control.dart';
import 'package:widget_animation_framework/widget_animation_framework.dart'
    show AnimationControllerWidget;

import 'default_splash_art.dart' show DefaultSplashArt;

const _splashDuration = Duration(milliseconds: 2500);

/// {@template default_splash_screen}
/// The default splash screen of the app.
///
/// Uses [AnimationControllerWidget] to run an ease-in-out animation of
/// [_splashDuration]
/// that drives a [DefaultSplashArt]. When the animation completes,
/// the status bar is restored via [StatusBarChameleon.setStatusBarHidden],
/// fired without awaiting since completion is fire-and-forget here.
/// {@endtemplate}
class AnimatedSplashScreen extends StatelessWidget {
  /// {@macro default_splash_screen}
  const AnimatedSplashScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimationControllerWidget(
    duration: _splashDuration,
    curve: Curves.easeInOut,
    onCompleted: () => IslandControl.setIsland(isHidden: false),
    builder: (context, animation) => DefaultSplashArt(animation: animation),
  );
}
