// packages/animated_transparency/lib/src/transparency_range.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';

abstract class AnimationRange {
  AnimationRange(
    this.begin,
    this.end, {
    required this.duration,
    this.onEnd,
  });

  final Duration duration;
  final double begin;
  final double end;
  final VoidCallback? onEnd;
}

@immutable
class TransformRange extends AnimationRange {
  TransformRange(
    super.begin,
    super.end, {
    required super.duration,
    super.onEnd,
  }) : assert(begin >= 0 && end >= 0, 'Growth factor must be >= 0');
}

@immutable
class OpacityRange extends AnimationRange {
  OpacityRange(
    super.begin,
    super.end, {
    required super.duration,
    this.curve = Curves.linear,
    super.onEnd,
  });

  final Curve curve;
}

@immutable
class TransparencyRange {
  const TransparencyRange(this.begin, this.end)
    : assert(begin >= 0.0 && begin <= 1.0, 'begin must be between 0.0 and 1.0'),
      assert(end >= 0.0 && end <= 1.0, 'end must be between 0.0 and 1.0');

  /// Starting opacity (0.0 to 1.0)
  final double begin;

  /// Target opacity (0.0 to 1.0)
  final double end;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransparencyRange &&
          runtimeType == other.runtimeType &&
          begin == other.begin &&
          end == other.end;

  @override
  int get hashCode => Object.hash(begin, end);

  @override
  String toString() => 'TransparencyRange($begin, $end)';
}
