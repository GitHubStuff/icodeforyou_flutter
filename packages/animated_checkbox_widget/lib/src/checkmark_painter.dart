// lib/src/checkmark_painter.dart
import 'package:flutter/material.dart';

import 'dissolve_particle.dart';
import 'checkmark_path_builder.dart';

/// Custom painter for drawing and dissolving checkmarks
///
/// Follows Single Responsibility Principle - only handles painting
class CheckmarkPainter extends CustomPainter {
  final double _progress;
  final Color _strokeColor;
  final bool _isDraw;
  final List<DissolveParticle> _particles;
  final double _width;

  const CheckmarkPainter({
    required double progress,
    required Color strokeColor,
    required bool isDraw,
    required List<DissolveParticle> particles,
    required double width,
  }) : _progress = progress,
       _strokeColor = strokeColor,
       _isDraw = isDraw,
       _particles = particles,
       _width = width;

  @override
  void paint(Canvas canvas, Size size) {
    if (_isDraw) {
      _paintProgressiveCheckmark(canvas);
    } else {
      _paintDissolveParticles(canvas);
    }
  }

  void _paintProgressiveCheckmark(Canvas canvas) {
    final paint = _createStrokePaint();
    final pathBuilder = CheckmarkPathBuilder(_width);
    final segments = pathBuilder.getPathSegments();

    final path = _buildProgressivePath(segments);
    canvas.drawPath(path, paint);
  }

  Path _buildProgressivePath(PathSegments segments) {
    final path = Path();
    final currentLength = segments.totalLength * _progress;

    path.moveTo(segments.points.start.dx, segments.points.start.dy);

    if (currentLength <= segments.firstLength) {
      // Drawing first segment
      final segmentProgress = currentLength / segments.firstLength;
      final currentPoint = Offset.lerp(
        segments.points.start,
        segments.points.middle,
        segmentProgress,
      )!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      // First segment complete, drawing second segment
      path.lineTo(segments.points.middle.dx, segments.points.middle.dy);
      final secondProgress =
          (currentLength - segments.firstLength) / segments.secondLength;
      final currentPoint = Offset.lerp(
        segments.points.middle,
        segments.points.end,
        secondProgress,
      )!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    }

    return path;
  }

  void _paintDissolveParticles(Canvas canvas) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (final particle in _particles) {
      final position = particle.getPositionAtTime(_progress);
      final opacity = particle.getOpacityAtTime(_progress);
      final size = particle.getSizeAtTime(_progress);

      if (opacity > 0) {
        particlePaint.color = _strokeColor.withValues(alpha: opacity);
        canvas.drawCircle(position, 2.0 * size, particlePaint);
      }
    }
  }

  Paint _createStrokePaint() {
    return Paint()
      ..color = _strokeColor
      ..strokeWidth = _width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate._progress != _progress ||
        oldDelegate._strokeColor != _strokeColor ||
        oldDelegate._isDraw != _isDraw ||
        oldDelegate._particles != _particles;
  }
}
