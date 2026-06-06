// packages/animated_widgets/lib/src/combination_animation/tweens/animation_tween.dart
// ignore_for_file: public_member_api_docs

import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// A normalized begin/end pair sampled by progress `t ∈ [0, 1]`.
///
/// Use [AnimationTween.up] for ascending animations (e.g. fade-in, scale-up)
/// and [AnimationTween.down] for descending animations (e.g. fade-out,
/// scale-down).
class AnimationTween extends Equatable {
  const AnimationTween({required this.start, required this.finish});

  /// Ascending tween, defaulting to `0.0 → 1.0`.
  factory AnimationTween.up({double start = 0.0, double finish = 1.0}) =>
      AnimationTween(start: start, finish: finish);

  /// Descending tween, defaulting to `1.0 → 0.0`.
  factory AnimationTween.down({double start = 1.0, double finish = 0.0}) =>
      AnimationTween(start: start, finish: finish);

  final double start;
  final double finish;

  /// Whether both [start] and [finish] lie within the inclusive `[0.0, 1.0]`
  /// range required by [Opacity].
  bool get isValidOpacity =>
      start >= 0.0 && start <= 1.0 && finish >= 0.0 && finish <= 1.0;

  /// Linearly interpolates between [start] and [finish] at progress [t].
  double lerp(double t) => lerpDouble(start, finish, t)!;

  @override
  List<Object?> get props => [start, finish];
}
