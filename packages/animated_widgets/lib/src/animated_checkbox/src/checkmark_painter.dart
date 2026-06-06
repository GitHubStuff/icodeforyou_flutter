// lib/src/animated_checkbox/_checkmark_painter.dart

// ignore_for_file: public_member_api_docs, always_use_package_imports

import 'package:flutter/material.dart';

import 'checkmark_path_builder.dart' show CheckmarkPathBuilder, PathSegments;
import 'dissolve_particle.dart' show DissolveParticle;

/// Paints the checkmark draw and dissolve effects.
class CheckmarkPainter extends CustomPainter {
  /// Constructor that extends [CustomPainter]
  const CheckmarkPainter({
    required this.progress,
    required this.strokeColor,
    required this.isDraw,
    required this.particles,
    required this.width,
    required this.startOffset,
    required this.midOffset,
    required this.finishOffset,
  });

  final double progress;
  final Color strokeColor;
  final bool isDraw;
  final List<DissolveParticle> particles;
  final double width;
  final Offset startOffset;
  final Offset midOffset;
  final Offset finishOffset;

  @override
  void paint(Canvas canvas, Size size) {
    if (isDraw) {
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
    if (progress <= 0.1) {
      final fadeOpacity = 1.0 - (progress / 0.1);
      final paint = _createStrokePaint()
        ..color = strokeColor.withValues(alpha: fadeOpacity);
      canvas.drawPath(_pathBuilder().buildCheckmarkPath(), paint);
    }
    _paintDissolveParticles(canvas);
  }

  void _paintDissolveParticles(Canvas canvas) {
    final strokeWidth = width * 0.08;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (final particle in particles) {
      final opacity = particle.getOpacityAtTime(progress);
      if (opacity <= 0.01) continue;

      final position = particle.getPositionAtTime(progress);
      final size = particle.getSizeAtTime(progress);
      final radius = (strokeWidth * 0.4 * size).clamp(0.8, strokeWidth * 0.6);

      paint.color = strokeColor.withValues(alpha: opacity);
      canvas.drawCircle(position, radius, paint);
    }
  }

  Path _buildProgressivePath(PathSegments segments) {
    final path = Path();
    final currentLength = segments.totalLength * progress;

    path.moveTo(segments.points.start.dx, segments.points.start.dy);

    if (currentLength <= segments.firstLength) {
      final t = currentLength / segments.firstLength;
      final point = Offset.lerp(
        segments.points.start,
        segments.points.middle,
        t,
      )!;
      path.lineTo(point.dx, point.dy);
    } else {
      path.lineTo(segments.points.middle.dx, segments.points.middle.dy);
      final t = (currentLength - segments.firstLength) / segments.secondLength;
      final point = Offset.lerp(
        segments.points.middle,
        segments.points.finish,
        t,
      )!;
      path.lineTo(point.dx, point.dy);
    }

    return path;
  }

  CheckmarkPathBuilder _pathBuilder() {
    return CheckmarkPathBuilder(
      width: width,
      startOffset: startOffset,
      midOffset: midOffset,
      finishOffset: finishOffset,
    );
  }

  Paint _createStrokePaint() {
    return Paint()
      ..color = strokeColor
      ..strokeWidth = width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.isDraw != isDraw ||
        oldDelegate.particles != particles ||
        oldDelegate.startOffset != startOffset ||
        oldDelegate.midOffset != midOffset ||
        oldDelegate.finishOffset != finishOffset;
  }
}
