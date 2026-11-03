// programs/since_when_dev/lib/splash/animated_splash_screen.dart
import 'dart:async' show unawaited;

import 'package:flutter/widgets.dart';
import 'package:since_when_dev/injection/injection.dart' show getIt;
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;
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

  /// Named used for Navigation
  static const route = '/animatedSplashScreen';

  @override
  Widget build(BuildContext context) {
    final vis = getIt<StatusBarVisibilityAbstract>();
    return AnimationControllerWidget(
      duration: _splashDuration,
      curve: Curves.easeInOut,
      onCompleted: () => unawaited(
        vis.setStatusBarVisibility(isHidden: false) as Future<void>?,
      ),
      builder: (context, animation) => DefaultSplashArt(animation: animation),
    );
  }
}
