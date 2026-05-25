// animated_widgets/lib/src/length_colored_border_field/color_point_ramp.dart

import 'package:animated_widgets/src/length_colored_border_field/color_point.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';

/// A validated, ordered sequence of [ColorPoint]s that maps a text length
/// to a border color.
///
/// The ramp guarantees:
/// - at least one point
/// - the first point's [ColorPoint.point] is `0`
/// - points are strictly ascending by [ColorPoint.point]
///
/// Lookup follows a min-length rule: [colorFor] returns the color of the
/// last point whose [ColorPoint.point] is `<=` the supplied length.
class ColorPointRamp extends Equatable {
  /// Creates a [ColorPointRamp] from [points], validating the contract.
  ///
  /// Throws [AssertionError] when [points] is empty, the first point is not
  /// `0`, or the points are not strictly ascending.
  factory ColorPointRamp(List<ColorPoint> points) {
    assert(points.isNotEmpty, 'ColorPointRamp requires at least one point');
    assert(
      points.first.point == 0,
      'ColorPointRamp first point must be 0 (got ${points.first.point})',
    );
    for (var i = 1; i < points.length; i++) {
      assert(
        points[i].point > points[i - 1].point,
        'ColorPointRamp points must strictly ascend '
        '(index $i: ${points[i].point} <= ${points[i - 1].point})',
      );
    }
    return ColorPointRamp._(List.unmodifiable(points));
  }

  const ColorPointRamp._(this.points);

  /// The validated, immutable list of points backing this ramp.
  final List<ColorPoint> points;

  /// Returns the border color for a text of [length] characters.
  ///
  /// Negative [length] values resolve to the first point's color.
  Color colorFor(int length) {
    var match = points.first.color;
    for (final p in points) {
      if (length >= p.point) {
        match = p.color;
      } else {
        break;
      }
    }
    return match;
  }

  @override
  List<Object?> get props => [points];
}
