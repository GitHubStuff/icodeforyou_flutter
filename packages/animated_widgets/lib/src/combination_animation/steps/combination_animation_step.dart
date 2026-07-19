// packages/animated_widgets/lib/src/combination_animation/steps/combination_animation_step.dart

import 'package:animated_widgets/src/combination_animation/constants/combination_animation_constants.dart'
    show
        kCombinationAnimationDefaultCurve,
        kCombinationAnimationDefaultDuration;
import 'package:animated_widgets/src/combination_animation/tweens/animation_tween.dart'
    show AnimationTween;
import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';

/// A single phase in a combination animation sequence.
///
/// Each step owns its own [scaling], optional [opacity], [duration], and
/// [curve]. Steps run back-to-back on a single timeline; total duration
/// is the sum of every step's [duration].
///
/// [onComplete] fires when this step's [duration] elapses. It is a
/// side-effect hook, not value state, so it is intentionally excluded from
/// [props]: two steps that differ only by callback compare equal, which
/// keeps equality stable when callers pass fresh closures on each build.
class CombinationAnimationStep extends Equatable {
  /// Creates a [CombinationAnimationStep].
  ///
  /// [scaling] is optional; [opacity] is optional, and [duration] and
  /// [curve] fall back to the package defaults when omitted.
  const CombinationAnimationStep({
    AnimationTween? scale,
    this.opacity,
    this.duration = kCombinationAnimationDefaultDuration,
    this.curve = kCombinationAnimationDefaultCurve,
    this.onComplete,
  }) : scaling = scale ?? AnimationTween.none;

  /// The scale tween animated across this step, from its start to its
  /// finish value.
  final AnimationTween scaling;

  /// The optional opacity tween animated across this step.
  ///
  /// When `null`, no opacity layer is applied, avoiding an unnecessary
  /// compositing layer for steps that only scale.
  final AnimationTween? opacity;

  /// How long this step runs before the sequence advances to the next.
  ///
  /// Defaults to [kCombinationAnimationDefaultDuration].
  final Duration duration;

  /// The easing curve applied to this step's tweens.
  ///
  /// Defaults to [kCombinationAnimationDefaultCurve].
  final Curve curve;

  /// Called once when this step's [duration] elapses.
  ///
  /// A side-effect hook for reacting to step completion; it does not affect
  /// the animation and is excluded from [props].
  final VoidCallback? onComplete;

  @override
  List<Object?> get props => [scaling, opacity, duration, curve];
}
