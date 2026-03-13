// lib/src/animated_checkbox/_checkmark_painter.dart

import 'package:animated_widgets/src/animated_checkbox/_checkmark_path_builder.dart';
import 'package:animated_widgets/src/animated_checkbox/_dissolve_particle.dart';
import 'package:flutter/material.dart';

/// Paints the checkmark draw and dissolve effects.
class CheckmarkPainter extends CustomPainter {
  const CheckmarkPainter({
    required double progress,
    required Color strokeColor,
    required bool isDraw,
    required List<DissolveParticle> particles,
    required double width,
    required Offset startOffset,
    required Offset midOffset,
    required Offset finishOffset,
  })  : _progress = progress,
        _strokeColor = strokeColor,
        _isDraw = isDraw,
        _particles = particles,
        _width = width,
        _startOffset = startOffset,
        _midOffset = midOffset,
        _finishOffset = finishOffset;

  final double _progress;
  final Color _strokeColor;
  final bool _isDraw;
  final List<DissolveParticle> _particles;
  final double _width;
  final Offset _startOffset;
  final Offset _midOffset;
  final Offset _finishOffset;

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
    final segments = _pathBuilder().getPathSegments();
    canvas.drawPath(_buildProgressivePath(segments), paint);
  }

  void _paintDissolveEffect(Canvas canvas) {
    if (_progress <= 0.1) {
      final fadeOpacity = 1.0 - (_progress / 0.1);
      final paint = _createStrokePaint()
        ..color = _strokeColor.withValues(alpha: fadeOpacity);
      canvas.drawPath(_pathBuilder().buildCheckmarkPath(), paint);
    }
    _paintDissolveParticles(canvas);
  }

  void _paintDissolveParticles(Canvas canvas) {
    final strokeWidth = _width * 0.08;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (final particle in _particles) {
      final opacity = particle.getOpacityAtTime(_progress);
      if (opacity <= 0.01) continue;

      final position = particle.getPositionAtTime(_progress);
      final size = particle.getSizeAtTime(_progress);
      final radius =
          (strokeWidth * 0.4 * size).clamp(0.8, strokeWidth * 0.6);

      paint.color = _strokeColor.withValues(alpha: opacity);
      canvas.drawCircle(position, radius, paint);
    }
  }

  Path _buildProgressivePath(PathSegments segments) {
    final path = Path();
    final currentLength = segments.totalLength * _progress;

    path.moveTo(segments.points.start.dx, segments.points.start.dy);

    if (currentLength <= segments.firstLength) {
      final t = currentLength / segments.firstLength;
      final point =
          Offset.lerp(segments.points.start, segments.points.middle, t)!;
      path.lineTo(point.dx, point.dy);
    } else {
      path.lineTo(segments.points.middle.dx, segments.points.middle.dy);
      final t =
          (currentLength - segments.firstLength) / segments.secondLength;
      final point =
          Offset.lerp(segments.points.middle, segments.points.finish, t)!;
      path.lineTo(point.dx, point.dy);
    }

    return path;
  }

  CheckmarkPathBuilder _pathBuilder() {
    return CheckmarkPathBuilder(
      width: _width,
      startOffset: _startOffset,
      midOffset: _midOffset,
      finishOffset: _finishOffset,
    );
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
