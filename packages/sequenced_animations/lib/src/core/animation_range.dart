// packages/sequenced_animations/lib/src/core/animation_range.dart

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// One leg of a sequenced animation: interpolate from [begin] to [end]
/// over [duration], eased by [curve].
///
/// The meaning of [begin]/[end] belongs to the consuming widget
/// (opacity, scale factor, turns, ...). [onEnd] fires when playback
/// crosses the end of this range going forward.
///
/// [duration] must be greater than zero; the consuming widget asserts
/// this, since a const constructor cannot.
@immutable
class AnimationRange {
  const AnimationRange(
    this.begin,
    this.end, {
    required this.duration,
    this.curve = Curves.linear,
    this.onEnd,
  });

  final double begin;
  final double end;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onEnd;
}
