// packages/animated_widgets/lib/src/combination_animation/steps/combination_animation_frame_builder.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';

import '../constants/combination_animation_constants.dart';
import '../tweens/animation_tween.dart';

/// Builds one frame of a combination animation: applies [scale] (and optional
/// [opacity]) at progress [t] to [child].
///
/// When [opacity] is null, the [Opacity] widget is omitted entirely so the
/// extra compositing layer is never created.
Widget buildCombinationAnimationFrame({
  required double t,
  required AnimationTween scale,
  required AnimationTween? opacity,
  required Widget child,
}) {
  final scaled = Transform.scale(scale: scale.lerp(t), child: child);
  if (opacity == null) return scaled;
  return Opacity(
    opacity: opacity.lerp(t).clamp(
          kCombinationAnimationOpacityMin,
          kCombinationAnimationOpacityMax,
        ),
    child: scaled,
  );
}
