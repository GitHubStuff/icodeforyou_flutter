// packages/animated_widgets/lib/src/combination_animation/widgets/combination_animation_single.dart
// ignore_for_file: always_use_package_imports, public_member_api_docs

import 'package:flutter/widgets.dart';

import '../constants/combination_animation_constants.dart';
import '../steps/combination_animation_frame_builder.dart';
import '../tweens/animation_tween.dart';

/// Animates [child] through a [scale] [AnimationTween], and optionally through
/// an [opacity] [AnimationTween], over the given [duration] using [curve].
///
/// The [Opacity] widget is omitted from the tree entirely when [opacity]
/// is `null`, avoiding an unnecessary compositing layer.
class CombinationAnimation extends StatelessWidget {
  const CombinationAnimation({
    required this.scale,
    required this.child,
    this.opacity,
    this.curve = kCombinationAnimationDefaultCurve,
    this.duration = kCombinationAnimationDefaultDuration,
    this.onComplete,
    super.key,
  });

  final AnimationTween scale;
  final AnimationTween? opacity;
  final Curve curve;
  final Duration duration;
  final Widget child;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    assert(
      opacity == null || opacity!.isValidOpacity,
      'opacity AnimationTween must lie within [0.0, 1.0]',
    );
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      onEnd: onComplete,
      curve: curve,
      child: child,
      builder: (context, t, child) => buildCombinationAnimationFrame(
        t: t,
        scale: scale,
        opacity: opacity,
        child: child!,
      ),
    );
  }
}
