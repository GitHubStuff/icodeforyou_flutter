// packages/animated_widgets/lib/src/combination_animation/steps/combination_animation_frame_builder.dart

part of 'animates_widget.dart';

/// Builds a single frame of a combination animation by applying a [scale]
/// transform and an optional [opacity] fade to [child] at the normalized
/// progress value [t].
///
/// A "combination animation" drives more than one visual property from a
/// single progress value, so every frame is produced by sampling each supplied
/// [AnimationTween] at the same point in time. This builder is the per-frame
/// composition step: given the tweens and the current progress, it returns the
/// widget subtree representing the animation at that instant.
///
/// The [scale] tween is sampled with [AnimationTween.lerp] and applied via
/// [Transform.scale]. When [scale] is null it is treated as
/// [AnimationTween.none], leaving [child] at its natural size, so the transform
/// is always present and the result is structurally stable across frames.
///
/// The [opacity] tween is optional. When it is null, no [Opacity] widget is
/// inserted at all, avoiding an additional compositing layer for animations
/// that only scale. When it is supplied, the sampled value is clamped to the
/// inclusive range [kCombinationAnimationOpacityMin] ..
/// [kCombinationAnimationOpacityMax] before being passed to [Opacity],
/// guarding against tweens that overshoot the legal `0.0` .. `1.0` range.
///
/// The [t] value is the normalized animation progress, conventionally in the
/// `0.0` .. `1.0` range, where `0.0` is the start and `1.0` is the end. It is
/// forwarded directly to each tween's [AnimationTween.lerp].
///
/// The [child] is the widget being animated; it is never rebuilt here, only
/// wrapped by the transform and, when applicable, the opacity layer.
///
/// Returns [child] wrapped in a [Transform.scale], and additionally wrapped in
/// an [Opacity] when [opacity] is non-null.
Widget buildCombinationAnimationFrame({
  required double t,
  required AnimationTween? scale,
  required AnimationTween? opacity,
  required Widget child,
}) {
  final AnimationTween scaleValue = scale ?? AnimationTween.none;
  final scaled = Transform.scale(scale: scaleValue.lerp(t), child: child);
  if (opacity == null) return scaled;
  AnimationTween.debugAssertNormalized(opacity);
  return Opacity(
    opacity: opacity
        .lerp(t)
        .clamp(
          kCombinationAnimationOpacityMin,
          kCombinationAnimationOpacityMax,
        ),
    child: scaled,
  );
}
