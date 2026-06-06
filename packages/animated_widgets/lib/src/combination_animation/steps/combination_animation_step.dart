// packages/animated_widgets/lib/src/combination_animation/steps/combination_animation_step.dart
// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';

import '../constants/combination_animation_constants.dart';
import '../tweens/animation_tween.dart';

/// A single phase in a combination animation sequence.
///
/// Each step owns its own [scale], optional [opacity], [duration], and
/// [curve]. Steps run back-to-back on a single timeline; total duration
/// is the sum of every step's [duration].
class CombinationAnimationStep extends Equatable {
  const CombinationAnimationStep({
    required this.scale,
    this.opacity,
    this.duration = kCombinationAnimationDefaultDuration,
    this.curve = kCombinationAnimationDefaultCurve,
  });

  final AnimationTween scale;
  final AnimationTween? opacity;
  final Duration duration;
  final Curve curve;

  @override
  List<Object?> get props => [scale, opacity, duration, curve];
}
