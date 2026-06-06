// lib/src/animated_checkbox/_checkmark_path_builder.dart

import 'dart:ui';

/// Builds the checkmark path from normalized offset coordinates.
class CheckmarkPathBuilder {
  /// Constructor
  const CheckmarkPathBuilder({
    required double width,
    required Offset startOffset,
    required Offset midOffset,
    required Offset finishOffset,
  }) : _width = width,
       _startOffset = startOffset,
       _midOffset = midOffset,
       _finishOffset = finishOffset;

  final double _width;
  final Offset _startOffset;
  final Offset _midOffset;
  final Offset _finishOffset;

  /// Builds the [Path] for the animated checkmark stroke.
  ///
  /// Returns a three-point path from start through middle to finish,
  /// intended for use with a [PathMetric] drawing animation.
  Path buildCheckmarkPath() {
    final points = _getCheckmarkPoints();
    return Path()
      ..moveTo(points.start.dx, points.start.dy)
      ..lineTo(points.middle.dx, points.middle.dy)
      ..lineTo(points.finish.dx, points.finish.dy);
  }

  /// Returns the [PathSegments] for the checkmark, including the
  /// length of each stroke and the three key points.
  PathSegments getPathSegments() {
    final points = _getCheckmarkPoints();
    return PathSegments(
      firstLength: (points.middle - points.start).distance,
      secondLength: (points.finish - points.middle).distance,
      points: points,
    );
  }

  CheckmarkPoints _getCheckmarkPoints() {
    return CheckmarkPoints(
      start: _normalizedToPixels(_startOffset),
      middle: _normalizedToPixels(_midOffset),
      finish: _normalizedToPixels(_finishOffset),
    );
  }

  Offset _normalizedToPixels(Offset normalized) {
    return Offset(normalized.dx * _width, normalized.dy * _width);
  }
}

/// Defines the three key [Offset] points that describe a checkmark shape.
class CheckmarkPoints {
  /// Creates a [CheckmarkPoints] with the required [start], [middle],
  /// and [finish] offsets.
  const CheckmarkPoints({
    required this.start,
    required this.middle,
    required this.finish,
  });

  /// The beginning of the first checkmark stroke.
  final Offset start;

  /// The apex where the two strokes meet.
  final Offset middle;

  /// The end of the second checkmark stroke.
  final Offset finish;
}

/// Holds the two stroke lengths and key points of a checkmark [Path].
class PathSegments {
  /// Creates a [PathSegments] with the required stroke lengths
  /// and [CheckmarkPoints].
  const PathSegments({
    required this.firstLength,
    required this.secondLength,
    required this.points,
  });

  /// The length of the first stroke, from [CheckmarkPoints.start] to
  /// [CheckmarkPoints.middle].
  final double firstLength;

  /// The length of the second stroke, from [CheckmarkPoints.middle] to
  /// [CheckmarkPoints.finish].
  final double secondLength;

  /// The three key offsets that define the checkmark shape.
  final CheckmarkPoints points;

  /// The combined length of both strokes.
  double get totalLength => firstLength + secondLength;
}
