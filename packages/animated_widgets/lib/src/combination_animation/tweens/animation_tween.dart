// packages/animated_widgets/lib/src/combination_animation/tweens/animation_tween.dart
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// An immutable, normalized begin/end pair sampled by animation progress
/// `t ∈ [0, 1]`.
///
/// An [AnimationTween] describes a single scalar effect — such as opacity or a
/// resize factor — as the value it holds at the start of an animation
/// ([start], when `t == 0`) and the value it holds at the end ([finish], when
/// `t == 1`). Intermediate values are produced with [lerp].
///
/// Use the [AnimationTween.up] factory for ascending effects (e.g. fade-in,
/// scale-up) and [AnimationTween.down] for descending effects (e.g. fade-out,
/// scale-down). When an effect should be left unchanged, use [none].
///
/// Equality is value-based via [Equatable]: two tweens are equal when their
/// [start] and [finish] match.
///
/// ```dart
/// const fadeIn = AnimationTween(start: 0, finish: 1);
/// final opacity = fadeIn.lerp(0.5); // 0.5
/// ```
class AnimationTween extends Equatable {
  /// Creates a tween that interpolates from [start] (at `t == 0`) to [finish]
  /// (at `t == 1`).
  const AnimationTween({required this.start, required this.finish});

  /// Creates an ascending tween, defaulting to `0.0 → 1.0`.
  ///
  /// Suitable for effects that grow over the course of the animation, such as
  /// fading in or scaling up. Override [start] and [finish] to interpolate
  /// across a narrower ascending range.
  factory AnimationTween.up({double start = 0.0, double finish = 1.0}) =>
      AnimationTween(start: start, finish: finish);

  /// Creates a descending tween, defaulting to `1.0 → 0.0`.
  ///
  /// Suitable for effects that shrink over the course of the animation, such
  /// as fading out or scaling down. Override [start] and [finish] to
  /// interpolate across a narrower descending range.
  factory AnimationTween.down({double start = 1.0, double finish = 0.0}) =>
      AnimationTween(start: start, finish: finish);

  /// The identity tween (`1.0 → 1.0`).
  ///
  /// Holds a constant value of `1.0` across all progress, leaving the target
  /// effect unchanged. Use this as a default when an effect (opacity, resize,
  /// …) is not requested.
  static const AnimationTween none = AnimationTween(start: 1, finish: 1);

  /// The value sampled at the start of the animation, i.e. at progress
  /// `t == 0`.
  final double start;

  /// The value sampled at the end of the animation, i.e. at progress
  /// `t == 1`.
  final double finish;

  /// Whether both [start] and [finish] lie within the inclusive `[0.0, 1.0]`
  /// range required by [Opacity] and by normalized resize factors.
  ///
  /// Returns `false` if either bound falls outside that range.
  bool get isNormalized => _isNormalized(start) && _isNormalized(finish);

  /// Linearly interpolates between [start] and [finish] at progress [t].
  ///
  /// [t] is expected to be in the range `[0.0, 1.0]`, where `0.0` yields
  /// [start] and `1.0` yields [finish]. Values outside that range extrapolate.
  double lerp(double t) => lerpDouble(start, finish, t)!;

  /// Asserts that [tween] is [isNormalized], surfacing a descriptive message
  /// in debug builds. A `null` tween is treated as valid (the effect is
  /// absent).
  ///
  /// For development if the test fails, it will assert out, but in production
  /// the true/false return gives the user the option to respond to
  /// success/failure
  ///
  /// ```dart
  /// assert(AnimationTween.debugAssertNormalized(opacityTween), '*message*');
  /// ```
  ///
  /// ```dart
  /// if (!AnimationTween.debugAssertNormalized()) {
  ///    /* user code for invalid tween */
  /// }
  /// ```
  ///
  static bool debugAssertNormalized(AnimationTween? tween) {
    final tweenTest = tween == null || tween.isNormalized;
    assert(tweenTest, _invalidTweenMessage(tween));
    return tweenTest;
  }

  /// Whether [value] lies within the inclusive `[0.0, 1.0]` range.
  static bool _isNormalized(double value) => value >= 0.0 && value <= 1.0;

  /// Builds a human-readable diagnostic describing which bounds of [tween]
  /// fall outside the normalized range. Used as the [debugAssertNormalized]
  /// failure message.
  static String _invalidTweenMessage(AnimationTween tween) {
    final buffer = StringBuffer('Invalid AnimationTween\n');
    if (!_isNormalized(tween.start)) {
      buffer.writeln('  start is invalid: ${tween.start}');
    }
    if (!_isNormalized(tween.finish)) {
      buffer.writeln('  finish is invalid: ${tween.finish}');
    }
    return buffer.toString();
  }

  /// The properties used by [Equatable] to determine value equality:
  /// [start] and [finish].
  @override
  List<Object?> get props => [start, finish];
}
