// lib/src/checkmark_painter.dart
import 'package:flutter/material.dart';

import '_dissolve_particle.dart';
import '_checkmark_path_builder.dart';

/// Custom painter for drawing and dissolving checkmarks with custom offsets
///
/// Follows Single Responsibility Principle - only handles painting
class CheckmarkPainter extends CustomPainter {
  final double _progress;
  final Color _strokeColor;
  final bool _isDraw;
  final List<DissolveParticle> _particles;
  final double _width;
  final Offset _startOffset;
  final Offset _midOffset;
  final Offset _finishOffset;

  const CheckmarkPainter({
    required double progress,
    required Color strokeColor,
    required bool isDraw,
    required List<DissolveParticle> particles,
    required double width,
    required Offset startOffset,
    required Offset midOffset,
    required Offset finishOffset,
  }) : _progress = progress,
       _strokeColor = strokeColor,
       _isDraw = isDraw,
       _particles = particles,
       _width = width,
       _startOffset = startOffset,
       _midOffset = midOffset,
       _finishOffset = finishOffset;

  @override
  void paint(Canvas canvas, Size size) {
    if (_isDraw) {
      _paintProgressiveCheckmark(canvas);
    } else {
      _paintDissolveEffect(canvas);
    }
  }

  void _paintProgressiveCheckmark(Canvas canvas) {
    final paint = _createStrokePaint();
    final pathBuilder = CheckmarkPathBuilder(
      width: _width,
      startOffset: _startOffset,
      midOffset: _midOffset,
      finishOffset: _finishOffset,
    );
    final segments = pathBuilder.getPathSegments();

    final path = _buildProgressivePath(segments);
    canvas.drawPath(path, paint);
  }

  void _paintDissolveEffect(Canvas canvas) {
    if (_progress <= 0.1) {
      // Show normal checkmark for first 10% of dissolve
      final fadeOpacity = 1.0 - (_progress / 0.1);
      final paint = _createStrokePaint();
      paint.color = _strokeColor.withValues(alpha: fadeOpacity);

      final pathBuilder = CheckmarkPathBuilder(
        width: _width,
        startOffset: _startOffset,
        midOffset: _midOffset,
        finishOffset: _finishOffset,
      );
      final path = pathBuilder.buildCheckmarkPath();
      canvas.drawPath(path, paint);
    }

    // Always paint particles (they start invisible and gradually appear)
    _paintDissolveParticles(canvas);
  }

  void _paintDissolveParticles(Canvas canvas) {
    final strokeWidth = _width * 0.08;
    final particlePaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (final particle in _particles) {
      final position = particle.getPositionAtTime(_progress);
      final opacity = particle.getOpacityAtTime(_progress);
      final size = particle.getSizeAtTime(_progress);

      if (opacity > 0.01) {
        particlePaint.color = _strokeColor.withValues(alpha: opacity);

        // Smaller particles that don't overlap as much
        final particleRadius = (strokeWidth * 0.4 * size).clamp(
          0.8,
          strokeWidth * 0.6,
        );

        canvas.drawCircle(position, particleRadius, particlePaint);
      }
    }
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
        segments.points.finish,
        secondProgress,
      )!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    }

    return path;
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
        oldDelegate._particles != _particles ||
        oldDelegate._startOffset != _startOffset ||
        oldDelegate._midOffset != _midOffset ||
        oldDelegate._finishOffset != _finishOffset;
  }
}
