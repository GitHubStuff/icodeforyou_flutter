// packages/animated_widgets/lib/src/combination_animation/widgets/animates_widget.dart

import 'dart:async' show unawaited;

import 'package:animated_widgets/src/combination_animation/constants/combination_animation_constants.dart'
    show
        kCombinationAnimationDefaultCurve,
        kCombinationAnimationDefaultDuration,
        kCombinationAnimationOpacityMax,
        kCombinationAnimationOpacityMin;
import 'package:animated_widgets/src/combination_animation/steps/combination_animation_step.dart'
    show CombinationAnimationStep;
import 'package:animated_widgets/src/combination_animation/tweens/animation_tween.dart'
    show AnimationTween;
import 'package:flutter/widgets.dart';

part 'combination_animation_frame_builder.dart';
part 'combination_animation_sequenced.dart';

/// Fluent, sequenced combination animations for any [Widget].
///
/// Two entry points with identical per-step parameters but different
/// return types:
///
/// * [animatedSteps] returns an [AnimatedSteps] -- itself a [Widget], so a
///   lone call is a one-step animation and no terminal is needed.
/// * [animationSequence] returns an [AnimationSequence] -- a builder
///   finished with [AnimationSequence.animate], immune to the widening
///   footgun [AnimatedSteps] carries.
///
/// Both append further steps with `step` and play them in order on a single
/// controller.
///
///```dart
///  widget
///    .animatedSteps(/* step 1 */)   // entry
///    .step(/* step 2 */)            // append
///    .step(/* step 3 */);           // append — done, it's a Widget
///
///  widget
///    .animationSequence(/* step 1 */)  // entry
///    .step(/* step 2 */)               // append
///    .step(/* step 3 */)               // append
///    .animate();                      // terminal — now it's a Widget
///```
///
extension AnimatesWidgetExt on Widget {
  Widget combinationAnimationSequenced(
    List<CombinationAnimationStep> steps, {
    VoidCallback? onComplete,
    Key? key,
  }) {
    return CombinationAnimationSequenced(
      key: key,
      steps: steps,
      onComplete: onComplete,
      child: this,
    );
  }

  /// Starts an [AnimatedSteps] whose first step animates [scale] and/or
  /// [opacity] over [duration] using [curve].
  ///
  /// The result is a [Widget]; chain more steps with [AnimatedSteps.step].
  /// Omit [scale] to animate opacity alone; omit [opacity] to skip its
  /// layer. [onComplete] fires when this step's [duration] elapses.
  AnimatedSteps animatedSteps({
    AnimationTween? scale,
    AnimationTween? opacity,
    Duration duration = kCombinationAnimationDefaultDuration,
    Curve curve = kCombinationAnimationDefaultCurve,
    VoidCallback? onComplete,
  }) => AnimatedSteps._(
    steps: <CombinationAnimationStep>[
      _buildStep(
        scale: scale,
        opacity: opacity,
        duration: duration,
        curve: curve,
        onComplete: onComplete,
      ),
    ],
    child: this,
  );

  /// Starts an [AnimationSequence] whose first step animates [scale] and/or
  /// [opacity] over [duration] using [curve].
  ///
  /// Append more steps with [AnimationSequence.step], then call
  /// [AnimationSequence.animate] to obtain the [Widget]. [onComplete] fires
  /// when this step's [duration] elapses.
  AnimationSequence animationSequence({
    AnimationTween? scale,
    AnimationTween? opacity,
    Duration duration = kCombinationAnimationDefaultDuration,
    Curve curve = kCombinationAnimationDefaultCurve,
    VoidCallback? onComplete,
  }) => AnimationSequence._(
    child: this,
    steps: <CombinationAnimationStep>[
      _buildStep(
        scale: scale,
        opacity: opacity,
        duration: duration,
        curve: curve,
        onComplete: onComplete,
      ),
    ],
  );
}

/// A [Widget] that plays its [CombinationAnimationStep]s in order on a
/// single controller, extendable with more steps in place.
///
/// Created by [AnimatesWidgetExt.animatedSteps]. Each [step] call returns a
/// new instance carrying every step so far, so only the final one in the
/// chain is mounted. Because it is itself a [Widget], re-entering via
/// [AnimatesWidgetExt.animatedSteps] on an intermediate widened to `Widget`
/// re-applies the extension and nests instead of appends. Append with
/// [step] instead -- it is not defined on `Widget`, so a widened
/// intermediate fails to compile rather than nesting silently. Use
/// [AnimatesWidgetExt.animationSequence] to remove the risk entirely.
final class AnimatedSteps extends StatelessWidget {
  const AnimatedSteps._({
    required this.child,
    required this._steps,
  });

  /// The widget the steps are applied to.
  final Widget child;

  final List<CombinationAnimationStep> _steps;

  /// The accumulated steps, exposed for testing.
  @visibleForTesting
  List<CombinationAnimationStep> get steps => _steps;

  /// Appends one step and returns a new [AnimatedSteps].
  ///
  /// Each supplied [AnimationTween] carries its own start and finish, so
  /// continuity between steps is the caller's choice. [onComplete] fires
  /// when this step's [duration] elapses.
  AnimatedSteps step({
    AnimationTween? scale,
    AnimationTween? opacity,
    Duration duration = kCombinationAnimationDefaultDuration,
    Curve curve = kCombinationAnimationDefaultCurve,
    VoidCallback? onComplete,
  }) => AnimatedSteps._(
    steps: <CombinationAnimationStep>[
      ..._steps,
      _buildStep(
        scale: scale,
        opacity: opacity,
        duration: duration,
        curve: curve,
        onComplete: onComplete,
      ),
    ],
    child: child,
  );

  @override
  Widget build(BuildContext context) =>
      child.combinationAnimationSequenced(_steps);
}

/// A non-[Widget] builder that plays its [CombinationAnimationStep]s in
/// order on a single controller once [animate] is called.
///
/// Created by [AnimatesWidgetExt.animationSequence]. Because it is not a
/// [Widget], it cannot be placed in the tree or re-chained by accident --
/// the only way to finish is [animate], which makes the widening footgun of
/// [AnimatedSteps] a compile error here.
final class AnimationSequence {
  const AnimationSequence._({
    required this.child,
    required this._steps,
  });

  /// The widget the steps are applied to.
  final Widget child;

  final List<CombinationAnimationStep> _steps;

  /// The accumulated steps, exposed for testing.
  @visibleForTesting
  List<CombinationAnimationStep> get steps => _steps;

  /// Appends one step and returns a new [AnimationSequence].
  ///
  /// Each supplied [AnimationTween] carries its own start and finish, so
  /// continuity between steps is the caller's choice. [onComplete] fires
  /// when this step's [duration] elapses.
  AnimationSequence step({
    AnimationTween? scale,
    AnimationTween? opacity,
    Duration duration = kCombinationAnimationDefaultDuration,
    Curve curve = kCombinationAnimationDefaultCurve,
    VoidCallback? onComplete,
  }) => AnimationSequence._(
    child: child,
    steps: <CombinationAnimationStep>[
      ..._steps,
      _buildStep(
        scale: scale,
        opacity: opacity,
        duration: duration,
        curve: curve,
        onComplete: onComplete,
      ),
    ],
  );

  /// Builds the sequenced [Widget]. The optional [key] is forwarded to the
  /// underlying animation.
  Widget animate({Key? key}) =>
      child.combinationAnimationSequenced(_steps, key: key);
}

//+
/// Helper method used by both AnimationSequence and AnimatedSteps
CombinationAnimationStep _buildStep({
  required AnimationTween? scale,
  required AnimationTween? opacity,
  required Duration duration,
  required Curve curve,
  required VoidCallback? onComplete,
}) => CombinationAnimationStep(
  scale: scale ?? AnimationTween.none,
  opacity: opacity,
  duration: duration,
  curve: curve,
  onComplete: onComplete,
);
