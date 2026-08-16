// programs/template_app/lib/framework/default_splash_child.dart
import 'package:flutter/widgets.dart';
import 'package:widget_animation_framework/widget_animation_framework.dart'
    show AnimationCombinerOnWidget;

import '../gen/assets.gen.dart' show Assets;

/// {@template default_splash_screen_child}
/// The default animated child displayed by the splash screen.
///
/// Renders the app icon as a 240-logical-pixel circular image, driven by
/// [animation] through an [AnimationCombinerOnWidget] that simultaneously
/// fades in (opacity 0 → 1), scales up (0 → 1), and completes one full
/// rotation (turns 1 → 2) as the animation progresses.
/// {@endtemplate}
class DefaultSplashArt extends StatelessWidget {
  /// {@macro default_splash_screen_child}
  const DefaultSplashArt({
    required this.animation,
    super.key,
  });

  /// The animation that drives the combined opacity, scale, and rotation
  /// effects, typically supplied by the owning splash screen's controller.
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => AnimationCombinerOnWidget(
    animation: animation,
    opacity: Tween<double>(begin: 0, end: 1),
    scale: Tween<double>(begin: 0, end: 1),
    turns: Tween<double>(begin: 1, end: 2),
    child: Center(
      child: SizedBox.square(
        dimension: 240,
        child: ClipOval(child: Assets.splashScreen.image(fit: BoxFit.cover)),
      ),
    ),
  );
}
