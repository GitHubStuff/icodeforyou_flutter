// programs/template_app/lib/framework/default_splash_screen.dart

import 'dart:async' show unawaited;

import 'package:flutter/widgets.dart';
import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;
import 'package:template_app/defaults/default_splash_art.dart'
    show DefaultSplashArt;
import 'package:widget_animation_framework/widget_animation_framework.dart'
    show AnimationControllerWidget;

const _splashDuration = Duration(milliseconds: 2500);

/// {@template default_splash_screen}
/// The default splash screen of the app.
///
/// Uses [AnimationControllerWidget] to run an ease-in-out animation of
/// [_splashDuration] that drives a [DefaultSplashArt]. When the animation
/// completes, the status bar is restored via :
/// [StatusBarChameleon.setStatusBarHidden]
/// is fired without awaiting since completion is fire-and-forget here.
/// {@endtemplate}
class DefaultSplashScreen extends StatelessWidget {
  /// {@macro default_splash_screen}
  const DefaultSplashScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimationControllerWidget(
    duration: _splashDuration,
    curve: Curves.easeInOut,
    onCompleted: () =>
        unawaited(StatusBarChameleon.setStatusBarHidden(hidden: false)),
    builder: (context, animation) => DefaultSplashArt(animation: animation),
  );
}
