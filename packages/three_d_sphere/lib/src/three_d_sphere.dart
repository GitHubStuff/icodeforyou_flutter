// packages/three_d_sphere/lib/src/three_d_sphere.dart

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:three_d_sphere/src/quadrant.dart' show Quadrant;

class ThreeDSphere extends StatelessWidget {
  const ThreeDSphere({
    required this.width,
    required this.height,
    required this.color,
    this.gradientColor = Colors.white,
    this.lightSource = Quadrant.topRight,
    this.sphereRadius = 1.15,
    super.key,
  });

  final double width;
  final double height;
  final Color color;
  final Color gradientColor;
  final Quadrant lightSource;
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

class _ThreeDSpherePainter extends CustomPainter {
  const _ThreeDSpherePainter({
    required this.color,
    required this.gradient,
    required this.lightSource,
    required this.sphereRadius,
  });

  final Color color;
  final Color gradient;
  final Quadrant lightSource;
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

  Alignment _alignmentFor(Quadrant quadrant) {
    return switch (quadrant) {
      Quadrant.topLeft => const Alignment(-0.45, -0.45),
      Quadrant.topCenter => const Alignment(0.0, -0.45),
      Quadrant.topRight => const Alignment(0.45, -0.45),
      Quadrant.leftCenter => const Alignment(-0.45, 0.0),
      Quadrant.rightCenter => const Alignment(0.45, 0.0),
      Quadrant.bottomLeft => const Alignment(-0.45, 0.45),
      Quadrant.bottomCenter => const Alignment(0.0, 0.45),
      Quadrant.bottomRight => const Alignment(0.45, 0.45),
    };
  }

  Alignment _highlightAlignmentFor(Quadrant quadrant) {
    return switch (quadrant) {
      Quadrant.topLeft => const Alignment(-0.25, -0.25),
      Quadrant.topCenter => const Alignment(0.0, -0.25),
      Quadrant.topRight => const Alignment(0.25, -0.25),
      Quadrant.leftCenter => const Alignment(-0.25, 0.0),
      Quadrant.rightCenter => const Alignment(0.25, 0.0),
      Quadrant.bottomLeft => const Alignment(-0.25, 0.25),
      Quadrant.bottomCenter => const Alignment(0.0, 0.25),
      Quadrant.bottomRight => const Alignment(0.25, 0.25),
    };
  }

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
