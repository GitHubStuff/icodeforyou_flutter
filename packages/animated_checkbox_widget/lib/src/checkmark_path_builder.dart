// lib/src/checkmark_path_builder.dart
import 'dart:ui';

/// Builds checkmark path based on widget dimensions
///
/// Follows Single Responsibility Principle - only builds paths
class CheckmarkPathBuilder {
  final double _width;

  const CheckmarkPathBuilder(this._width);

  /// Creates the checkmark path: start -> middle -> end
  Path buildCheckmarkPath() {
    final path = Path();
    final points = _getCheckmarkPoints();

    path.moveTo(points.start.dx, points.start.dy);
    path.lineTo(points.middle.dx, points.middle.dy);
    path.lineTo(points.end.dx, points.end.dy);

    return path;
  }

  /// Gets the three key points of the checkmark
  CheckmarkPoints _getCheckmarkPoints() {
    return CheckmarkPoints(
      start: Offset(0, _width / 2.0),
      middle: Offset(_width / 2.0, _width),
      end: Offset(_width, 0.0),
    );
  }

  /// Gets path segments for progressive drawing animation
  PathSegments getPathSegments() {
    final points = _getCheckmarkPoints();

    return PathSegments(
      firstLength: (points.middle - points.start).distance,
      secondLength: (points.end - points.middle).distance,
      points: points,
    );
  }
}

/// Data class for checkmark points
class CheckmarkPoints {
  final Offset start;
  final Offset middle;
  final Offset end;

  const CheckmarkPoints({
    required this.start,
    required this.middle,
    required this.end,
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
