// packages/three_d_sphere/lib/src/three_d_sphere.dart

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:three_d_sphere/src/quadrant.dart' show Quadrant;

/// {@template three_d_sphere.dart}
/// A widget that renders a pseudo-3D sphere using layered radial gradients.
///
/// The sphere illusion is produced by a [CustomPaint] that draws two ovals:
/// a base oval shaded with a lightness-ramped [RadialGradient] anchored at
/// the [lightSource], and a smaller specular highlight oval offset toward
/// the same quadrant.
///
/// The widget is sized explicitly via [width] and [height]; non-circular
/// dimensions produce an ellipsoid rather than a sphere.
/// {@endtemplate}
class ThreeDSphere extends StatelessWidget {
  /// {@macro three_d_sphere.dart}
  ///
  /// [width], [height], and [sphereRadius] must be greater than zero,
  /// enforced by asserts in [build].
  const ThreeDSphere({
    required this.width,
    required this.height,
    required this.color,
    this.gradientColor = Colors.white,
    this.lightSource = Quadrant.topRight,
    this.sphereRadius = 1.15,
    super.key,
  });

  /// The width of the sphere in logical pixels.
  ///
  /// Must be greater than zero.
  final double width;

  /// The height of the sphere in logical pixels.
  ///
  /// Must be greater than zero.
  final double height;

  /// The base color of the sphere.
  ///
  /// The shading gradient is derived from this color by adjusting its
  /// lightness in HSL space.
  final Color color;

  /// The color of the specular highlight.
  ///
  /// Defaults to [Colors.white]. The highlight fades from 70% of this
  /// color's alpha at its center to fully transparent at its edge.
  final Color gradientColor;

  /// The quadrant from which the light appears to originate.
  ///
  /// Controls both the anchor of the shading gradient and the placement
  /// of the specular highlight. Defaults to [Quadrant.topRight].
  final Quadrant lightSource;

  /// The radius of the shading gradient, in units of the shortest side
  /// of the sphere's bounding rectangle.
  ///
  /// Values greater than 1.0 soften the falloff into shadow; smaller
  /// values tighten it. Must be greater than zero. Defaults to 1.15.
  final double sphereRadius;

  @override
  Widget build(BuildContext context) {
    assert(width > 0, 'width must be greater than zero');
    assert(height > 0, 'height must be greater than zero');
    assert(sphereRadius > 0, 'sphereRadius must be greater than zero');

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ThreeDSpherePainter(
          color: color,
          gradient: gradientColor,
          lightSource: lightSource,
          sphereRadius: sphereRadius,
        ),
      ),
    );
  }
}

/// The painter that renders the sphere for [ThreeDSphere].
///
/// Draws two ovals: the shaded sphere body, then the specular highlight
/// layered on top of it.
class _ThreeDSpherePainter extends CustomPainter {
  /// Creates a painter with the shading inputs supplied by [ThreeDSphere].
  const _ThreeDSpherePainter({
    required this.color,
    required this.gradient,
    required this.lightSource,
    required this.sphereRadius,
  });

  /// The base color of the sphere body.
  final Color color;

  /// The color of the specular highlight.
  final Color gradient;

  /// The quadrant from which the light appears to originate.
  final Quadrant lightSource;

  /// The radius of the body's shading gradient.
  final double sphereRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect sphereRect = Offset.zero & size;

    final Paint spherePaint = Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        center: _alignmentFor(lightSource),
        radius: sphereRadius,
        colors: [
          _changeLightness(color, 0.45),
          _changeLightness(color, 0.20),
          color,
          _changeLightness(color, -0.25),
        ],
        stops: const [0.0, 0.30, 0.68, 1.0],
      ).createShader(sphereRect);

    canvas.drawOval(sphereRect, spherePaint);

    final Rect highlightRect = _highlightRectFor(
      size: size,
      quadrant: lightSource,
    );

    final Paint highlightPaint = Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        center: _highlightAlignmentFor(lightSource),
        colors: [
          gradient.withValues(alpha: gradient.a * 0.70),
          gradient.withValues(alpha: gradient.a * 0.20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(highlightRect);

    canvas.drawOval(highlightRect, highlightPaint);
  }

  /// Returns the shading gradient's anchor for [quadrant].
  ///
  /// Anchors sit at ±0.45 along each axis pulled toward the light source,
  /// keeping the brightest region inside the sphere's silhouette.
  Alignment _alignmentFor(Quadrant quadrant) {
    return switch (quadrant) {
      Quadrant.topLeft => const Alignment(-0.45, -0.45),
      Quadrant.topCenter => const Alignment(0, -0.45),
      Quadrant.topRight => const Alignment(0.45, -0.45),
      Quadrant.leftCenter => const Alignment(-0.45, 0),
      Quadrant.rightCenter => const Alignment(0.45, 0),
      Quadrant.bottomLeft => const Alignment(-0.45, 0.45),
      Quadrant.bottomCenter => const Alignment(0, 0.45),
      Quadrant.bottomRight => const Alignment(0.45, 0.45),
    };
  }

  /// Returns the highlight gradient's anchor for [quadrant].
  ///
  /// Anchors sit at ±0.25 along each axis — closer to center than the
  /// body's shading anchor — so the highlight's hot spot reads as a
  /// reflection on the curved surface rather than at its edge.
  Alignment _highlightAlignmentFor(Quadrant quadrant) {
    return switch (quadrant) {
      Quadrant.topLeft => const Alignment(-0.25, -0.25),
      Quadrant.topCenter => const Alignment(0, -0.25),
      Quadrant.topRight => const Alignment(0.25, -0.25),
      Quadrant.leftCenter => const Alignment(-0.25, 0),
      Quadrant.rightCenter => const Alignment(0.25, 0),
      Quadrant.bottomLeft => const Alignment(-0.25, 0.25),
      Quadrant.bottomCenter => const Alignment(0, 0.25),
      Quadrant.bottomRight => const Alignment(0.25, 0.25),
    };
  }

  /// Returns the bounding rectangle of the specular highlight oval for
  /// [quadrant] within a sphere of the given [size].
  ///
  /// The highlight measures 38% of the sphere's width by 28% of its
  /// height, inset from the light-source edge by 18% horizontally and
  /// 12% vertically, and centered on any axis where the quadrant is
  /// centered.
  Rect _highlightRectFor({required Size size, required Quadrant quadrant}) {
    final double highlightWidth = size.width * 0.38;
    final double highlightHeight = size.height * 0.28;

    final double horizontalInset = size.width * 0.18;
    final double verticalInset = size.height * 0.12;

    final double left = switch (quadrant) {
      Quadrant.topLeft ||
      Quadrant.leftCenter ||
      Quadrant.bottomLeft => horizontalInset,
      Quadrant.topCenter ||
      Quadrant.bottomCenter => (size.width - highlightWidth) / 2,
      Quadrant.topRight ||
      Quadrant.rightCenter ||
      Quadrant.bottomRight => size.width - highlightWidth - horizontalInset,
    };

    final double top = switch (quadrant) {
      Quadrant.topLeft ||
      Quadrant.topCenter ||
      Quadrant.topRight => verticalInset,
      Quadrant.leftCenter ||
      Quadrant.rightCenter => (size.height - highlightHeight) / 2,
      Quadrant.bottomLeft ||
      Quadrant.bottomCenter ||
      Quadrant.bottomRight => size.height - highlightHeight - verticalInset,
    };

    return Rect.fromLTWH(left, top, highlightWidth, highlightHeight);
  }

  /// Returns [value] with its HSL lightness shifted by [amount], clamped
  /// to the valid 0.0–1.0 range.
  ///
  /// Positive amounts lighten toward the light source; negative amounts
  /// darken toward the shadow terminator.
  Color _changeLightness(Color value, double amount) {
    final HSLColor hslColor = HSLColor.fromColor(value);

    return hslColor
        .withLightness((hslColor.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  bool shouldRepaint(covariant _ThreeDSpherePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.gradient != gradient ||
        oldDelegate.lightSource != lightSource ||
        oldDelegate.sphereRadius != sphereRadius;
  }
}
