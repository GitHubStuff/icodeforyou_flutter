// packages/animated_widgets/lib/src/animated_checkbox/src/checkmark_painter.dart

import 'package:flutter/material.dart';

import 'checkmark_path_builder.dart' show CheckmarkPathBuilder, PathSegments;
import 'dissolve_particle.dart' show DissolveParticle;

/// A [CustomPainter] responsible for rendering the visual states of
/// an animated checkmark.
///
/// This painter handles two distinct visual phases based on the [isDraw] flag:
/// 1. **Drawing Phase:** Progressively draws the checkmark stroke from start
///   to finish.
/// 2. **Dissolve Phase:** Quickly fades out the solid checkmark while rendering
///    a cloud of moving, fading [DissolveParticle]s to simulate a burst or
///   dissolve effect.
///
/// The geometry of the checkmark is defined by [startOffset], [midOffset],
/// and [finishOffset], which are scaled relative to the provided [width].
class CheckmarkPainter extends CustomPainter {
  /// Creates a [CheckmarkPainter].
  ///
  /// All parameters are required to ensure the painter can accurately calculate
  /// the path geometry and interpolate the animations at the current
  /// [progress].
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

  /// The current normalized position of the animation, ranging
  /// from `0.0` to `1.0`.
  ///
  /// When [isDraw] is true, this dictates the visible length of the checkmark.
  /// When [isDraw] is false, this drives the position, opacity, and size of
  /// the [particles].
  final double progress;

  /// The color used to stroke the checkmark and fill the dissolve particles.
  final Color strokeColor;

  /// Determines which animation effect to render.
  ///
  /// If `true`, the painter progressively draws the checkmark.
  /// If `false`, the painter renders the particle dissolve effect.
  final bool isDraw;

  /// A collection of [DissolveParticle] configurations used during the
  /// dissolve phase.
  ///
  /// These particles are only rendered when [isDraw] is `false` and their
  /// individual opacities are greater than `0.01`.
  final List<DissolveParticle> particles;

  /// The logical width of the canvas area.
  ///
  /// This is used as a baseline to calculate proportional stroke widths and
  /// particle radii to ensure the widget scales correctly at different sizes.
  final double width;

  /// The relative starting coordinate (the left tip) of the checkmark.
  final Offset startOffset;

  /// The relative middle coordinate (the bottom vertex) of the checkmark.
  final Offset midOffset;

  /// The relative finishing coordinate (the top-right tip) of the checkmark.
  final Offset finishOffset;

  /// Paints the current frame of the checkmark animation onto the given
  /// [canvas].
  ///
  /// Delegates to [_paintProgressiveCheckmark] or [_paintDissolveEffect] based
  /// on the [isDraw] state.
  @override
  void paint(Canvas canvas, Size size) {
    if (isDraw) {
      _paintProgressiveCheckmark(canvas);
    } else {
      _paintDissolveEffect(canvas);
    }
  }

  /// Draws the checkmark path corresponding to the current [progress].
  void _paintProgressiveCheckmark(Canvas canvas) {
    final paint = _createStrokePaint();
    final segments = _pathBuilder().getPathSegments();
    canvas.drawPath(_buildProgressivePath(segments), paint);
  }

  /// Renders the complete dissolve effect, including the fading checkmark and
  /// the particles.
  void _paintDissolveEffect(Canvas canvas) {
    // Fade out the main checkmark shape during the first 10% of the dissolve
    // animation.
    if (progress <= 0.1) {
      final fadeOpacity = 1.0 - (progress / 0.1);
      final paint = _createStrokePaint()
        ..color = strokeColor.withValues(alpha: fadeOpacity);
      canvas.drawPath(_pathBuilder().buildCheckmarkPath(), paint);
    }

    _paintDissolveParticles(canvas);
  }

  /// Iterates through and paints all active [particles] on the [canvas].
  ///
  /// Calculates the real-time position, size, and opacity of each particle
  /// based on the global [progress]. Particles that have faded to near-zero
  /// opacity are culled to optimize performance.
  void _paintDissolveParticles(Canvas canvas) {
    final strokeWidth = width * 0.08;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (final particle in particles) {
      final opacity = particle.getOpacityAtTime(progress);

      // Optimize by skipping particles that are practically invisible.
      if (opacity <= 0.01) continue;

      final position = particle.getPositionAtTime(progress);
      final size = particle.getSizeAtTime(progress);

      // Calculate particle radius relative to the main stroke width,
      // clamped to prevent particles from becoming completely invisible or
      // too large.
      final radius = (strokeWidth * 0.4 * size).clamp(0.8, strokeWidth * 0.6);

      paint.color = strokeColor.withValues(alpha: opacity);
      canvas.drawCircle(position, radius, paint);
    }
  }

  /// Constructs a partial [Path] representing the checkmark drawn up to
  /// [progress].
  ///
  /// Maps the global `0.0` to `1.0` progress value to the physical length
  /// of the checkmark [segments], ensuring the drawing speed is linear
  /// across the two lines (the short drop and the long rise).
  Path _buildProgressivePath(PathSegments segments) {
    final path = Path();
    final currentLength = segments.totalLength * progress;

    path.moveTo(segments.points.start.dx, segments.points.start.dy);

    if (currentLength <= segments.firstLength) {
      // We are still drawing the first segment (downward stroke).
      final t = currentLength / segments.firstLength;
      final point = Offset.lerp(
        segments.points.start,
        segments.points.middle,
        t,
      )!;
      path.lineTo(point.dx, point.dy);
    } else {
      // The first segment is complete; draw it fully and interpolate the
      // second segment.
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

  /// Instantiates a helper to calculate the physical path of the checkmark
  /// based on he provided offset proportions and the total canvas [width].
  CheckmarkPathBuilder _pathBuilder() {
    return CheckmarkPathBuilder(
      width: width,
      startOffset: startOffset,
      midOffset: midOffset,
      finishOffset: finishOffset,
    );
  }

  /// Generates the standard [Paint] object used for the checkmark stroke.
  ///
  /// The stroke width is calculated dynamically as 8% of the total widget
  /// [width] to maintain proportional thickness at any scale.
  Paint _createStrokePaint() {
    return Paint()
      ..color = strokeColor
      ..strokeWidth = width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  /// Determines whether the painter needs to redraw based on changes to its
  /// properties.
  ///
  /// Returns `true` if the animation [progress] advances, the [strokeColor]
  /// changes, the phase switches, or the layout geometry is modified.
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
