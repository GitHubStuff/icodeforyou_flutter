// lib/src/checkmark_path_builder.dart
import 'dart:ui';

/// Builds checkmark path based on widget dimensions and custom offsets
///
/// Follows Single Responsibility Principle - only builds paths
class CheckmarkPathBuilder {
  final double _width;
  final Offset _startOffset;
  final Offset _midOffset;
  final Offset _finishOffset;

  const CheckmarkPathBuilder({
    required double width,
    required Offset startOffset,
    required Offset midOffset,
    required Offset finishOffset,
  }) : _width = width,
       _startOffset = startOffset,
       _midOffset = midOffset,
       _finishOffset = finishOffset;

  /// Creates the checkmark path: start -> middle -> finish
  Path buildCheckmarkPath() {
    final path = Path();
    final points = _getCheckmarkPoints();

    path.moveTo(points.start.dx, points.start.dy);
    path.lineTo(points.middle.dx, points.middle.dy);
    path.lineTo(points.finish.dx, points.finish.dy);

    return path;
  }

  /// Gets the three key points of the checkmark using normalized offsets
  CheckmarkPoints _getCheckmarkPoints() {
    return CheckmarkPoints(
      start: _normalizedToPixels(_startOffset),
      middle: _normalizedToPixels(_midOffset),
      finish: _normalizedToPixels(_finishOffset),
    );
  }

  /// Converts normalized offset (0.0-1.0) to pixel coordinates
  Offset _normalizedToPixels(Offset normalizedOffset) {
    return Offset(normalizedOffset.dx * _width, normalizedOffset.dy * _width);
  }

  /// Gets path segments for progressive drawing animation
  PathSegments getPathSegments() {
    final points = _getCheckmarkPoints();

    return PathSegments(
      firstLength: (points.middle - points.start).distance,
      secondLength: (points.finish - points.middle).distance,
      points: points,
    );
  }
}

/// Data class for checkmark points
class CheckmarkPoints {
  final Offset start;
  final Offset middle;
  final Offset finish;

  const CheckmarkPoints({
    required this.start,
    required this.middle,
    required this.finish,
  });
}

/// Data class for path segments
class PathSegments {
  final double firstLength;
  final double secondLength;
  final CheckmarkPoints points;

  const PathSegments({
    required this.firstLength,
    required this.secondLength,
    required this.points,
  });

  double get totalLength => firstLength + secondLength;
}
