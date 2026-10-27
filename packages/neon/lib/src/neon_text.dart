// packages/neon/lib/src/neon_text.dart

// packages/neon/lib/src/neon_text.dart
import 'dart:ui' show ImageFilter;

import 'package:extensions/extensions.dart' show ColorExt;
import 'package:flutter/material.dart';

/// Renders [text] as a glowing neon sign.
///
/// Pass any base colour (e.g. `Colors.green`); the widget derives the lit
/// accent hue for the glow and a faintly tinted white for the tube core.
///
/// [distance] moves the sign away from the viewer: `0` is sharp and close,
/// `1` is far away — the halo spreads wider, the tube core dims, and the
/// whole sign drifts out of focus.
///
/// Expects the `TiltNeon` font family to be declared in the owning package's
/// `pubspec.yaml`. When this widget is consumed from another package, pass
/// that package's name via [package] so the font asset resolves.
class NeonText extends StatelessWidget {
  /// Creates a neon-styled text widget.
  const NeonText(
    this.text, {
    required this.color,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.tint = 0.45,
    this.distance = 0,
    this.fontSize = 48,
    this.package,
    super.key,
  }) : assert(tint >= 0 && tint <= 1, 'Tint >= 0.0 and <= 1.0'),
       assert(distance >= 0 && distance <= 1, 'Distance >= 0.0 and <= 1.0');

  /// The text to render.
  final String text;

  /// The base colour of the sign. Brightened to an accent for the glow.
  final Color color;

  /// Max lines in text
  final int? maxLines;

  /// Overflow type
  final TextOverflow overflow;

  /// Value to LERP() the color
  final double tint;

  /// How far away the sign appears, from `0` (close, sharp) to `1` (far,
  /// blurred).
  final double distance;

  /// The font size in logical pixels.
  final double fontSize;

  /// The name of the package that bundles the `TiltNeon` font asset.
  ///
  /// Leave `null` when the widget is used from within that same package.
  final String? package;

  static const String _fontFamily = 'TiltNeon';
  static const double _outerGlowAlpha = 0.6;

  /// Base blur radii of the four glow layers at `distance == 0`.
  static const List<double> _baseBlurRadii = [4, 12, 24, 48];

  /// How much the glow radii grow at `distance == 1` (a multiplier of 3×).
  static const double _maxGlowSpread = 2;

  /// How much the tube core fades at `distance == 1`.
  static const double _maxCoreFade = 0.5;

  /// Gaussian sigma applied to the whole sign at `distance == 1`.
  static const double _maxDefocusSigma = 6;

  @override
  Widget build(BuildContext context) {
    final glow = color.toNeonAccent();
    final core = color
        .toNeonCore(tint: tint)
        .withValues(alpha: 1 - distance * _maxCoreFade);

    final sign = Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: _fontFamily,
        package: package,
        fontSize: fontSize,
        color: core,
        shadows: _buildGlow(glow),
      ),
    );

    if (distance == 0) {
      return sign;
    }

    final sigma = distance * _maxDefocusSigma;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: sign,
    );
  }

  List<Shadow> _buildGlow(Color glow) {
    final spread = 1 + distance * _maxGlowSpread;
    final radii = _baseBlurRadii.map((radius) => radius * spread).toList();

    return [
      Shadow(color: glow, blurRadius: radii[0]),
      Shadow(color: glow, blurRadius: radii[1]),
      Shadow(color: glow, blurRadius: radii[2]),
      Shadow(
        color: glow.withValues(alpha: _outerGlowAlpha),
        blurRadius: radii[3],
      ),
    ];
  }
}

/*
import 'package:extensions/extensions.dart' show ColorExt;
import 'package:flutter/material.dart';

/// Renders [text] as a glowing neon sign.
///
/// Pass any base colour (e.g. `Colors.green`); the widget derives the lit
/// accent hue for the glow and a faintly tinted white for the tube core.
///
/// Expects the `TiltNeon` font family to be declared in the owning package's
/// `pubspec.yaml`. When this widget is consumed from another package, pass
/// that package's name via [package] so the font asset resolves.
class NeonText extends StatelessWidget {
  /// Creates a neon-styled text widget.
  const NeonText(
    this.text, {
    required this.color,
    this.tint = 0.45,
    this.fontSize = 48,
    this.package,
    super.key,
  }) : assert(tint >= 0 && tint <= 1, 'Tint >= 0.0 and <= 1.0');

  /// The text to render.
  final String text;

  /// The base colour of the sign. Brightened to an accent for the glow.
  final Color color;

  /// Value to LERP() the color
  final double tint;

  /// The font size in logical pixels.
  final double fontSize;

  /// The name of the package that bundles the `TiltNeon` font asset.
  ///
  /// Leave `null` when the widget is used from within that same package.
  final String? package;

  static const String _fontFamily = 'TiltNeon';
  static const double _outerGlowAlpha = 0.6;

  @override
  Widget build(BuildContext context) {
    final glow = color.toNeonAccent();
    final core = color.toNeonCore(tint: tint);

    return Text(
      text,
      style: TextStyle(
        fontFamily: _fontFamily,
        package: package,
        fontSize: fontSize,
        color: core,
        shadows: _buildGlow(glow),
      ),
    );
  }

  List<Shadow> _buildGlow(Color glow) {
    return [
      Shadow(color: glow, blurRadius: 4),
      Shadow(color: glow, blurRadius: 12),
      Shadow(color: glow, blurRadius: 24),
      Shadow(color: glow.withValues(alpha: _outerGlowAlpha), blurRadius: 48),
    ];
  }
}
*/
