// lib/src/animated_checkbox/_checkmark_path_builder.dart

import 'dart:ui';

/// Builds the checkmark path from normalized offset coordinates.
class CheckmarkPathBuilder {
  const CheckmarkPathBuilder({
    required double width,
    required Offset startOffset,
    required Offset midOffset,
    required Offset finishOffset,
  })  : _width = width,
        _startOffset = startOffset,
        _midOffset = midOffset,
        _finishOffset = finishOffset;

  final double _width;
  final Offset _startOffset;
  final Offset _midOffset;
  final Offset _finishOffset;

  Path buildCheckmarkPath() {
    final points = _getCheckmarkPoints();
    return Path()
      ..moveTo(points.start.dx, points.start.dy)
      ..lineTo(points.middle.dx, points.middle.dy)
      ..lineTo(points.finish.dx, points.finish.dy);
  }

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

class CheckmarkPoints {
  const CheckmarkPoints({
    required this.start,
    required this.middle,
    required this.finish,
  });

  final Offset start;
  final Offset middle;
  final Offset finish;
}

class PathSegments {
  const PathSegments({
    required this.firstLength,
    required this.secondLength,
    required this.points,
  });

  final double firstLength;
  final double secondLength;
  final CheckmarkPoints points;

  double get totalLength => firstLength + secondLength;
}
