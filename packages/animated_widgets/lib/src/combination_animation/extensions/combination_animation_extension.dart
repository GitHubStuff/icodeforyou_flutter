// packages/animated_widgets/lib/src/combination_animation/extensions/combination_animation_extension.dart
// ignore_for_file: always_use_package_imports, public_member_api_docs

import 'package:flutter/widgets.dart';

import '../constants/combination_animation_constants.dart';
import '../steps/combination_animation_step.dart';
import '../tweens/animation_tween.dart';
import '../widgets/combination_animation_sequenced.dart';
import '../widgets/combination_animation_single.dart';

/// Fluent chaining for combination animations.
///
/// `myWidget.combinationAnimation(...)` wraps the widget once.
///
/// `myWidget.combinationAnimationSequenced([step1, step2, ...])` runs every
/// step sequentially on a single controller — prefer this over chaining
/// multiple `.combinationAnimation(...)` calls, which would stack widgets
/// and run every animation in parallel from t=0.
extension CombinationAnimationX on Widget {
  Widget combinationAnimation({
    required AnimationTween scale,
    AnimationTween? opacity,
    Curve curve = kCombinationAnimationDefaultCurve,
    Duration duration = kCombinationAnimationDefaultDuration,
    VoidCallback? onComplete,
    Key? key,
  }) {
    return CombinationAnimation(
      key: key,
      scale: scale,
      opacity: opacity,
      curve: curve,
      duration: duration,
      onComplete: onComplete,
      child: this,
    );
  }

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
}
