// packages/slider_directional/lib/src/slider_direction.dart
import 'package:flutter/widgets.dart';

/// Controls both the axis of a slider and where its minimum value sits.
///
/// One value encodes two facts:
///
/// - **Orientation** (horizontal vs. vertical), via [axis].
/// - **Origin** (which end of the axis holds the minimum value), via
///   [isReversed].
///
/// Semantics:
///
/// - [left]   — horizontal, min on the left,  max on the right.
/// - [right]  — horizontal, min on the right, max on the left.
/// - [top]    — vertical,   min at the top,   max at the bottom.
/// - [bottom] — vertical,   min at the bottom, max at the top.
enum SliderDirection {
  left,
  top,
  right,
  bottom;

  /// `true` for [left] and [right].
  bool get isHorizontal =>
      this == SliderDirection.left || this == SliderDirection.right;

  /// `true` for [top] and [bottom].
  bool get isVertical => !isHorizontal;

  /// The Flutter [Axis] this direction lays out along.
  Axis get axis => isHorizontal ? Axis.horizontal : Axis.vertical;

  /// Whether the minimum sits on the end of the axis opposite to the
  /// "natural" reading direction.
  ///
  /// - Horizontal natural direction: left → right, so [right] is reversed.
  /// - Vertical natural direction: bottom → top (low at the bottom, as on a
  ///   chart Y-axis), so [top] is reversed.
  bool get isReversed =>
      this == SliderDirection.right || this == SliderDirection.top;
}
