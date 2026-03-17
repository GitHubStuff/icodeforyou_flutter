import 'dart:math';

import 'package:flutter/material.dart';

/// Generates random colors suitable for both light and dark themes
/// with readable white or black text overlay.
abstract final class RandomColorGenerator {
  static final _random = Random();

  /// Generates a random color in the mid-luminance range.
  ///
  /// Uses HSL color space to ensure:
  /// - Lightness: 35-65% (avoids pure white/black)
  /// - Saturation: 40-80% (vibrant but not garish)
  /// - Hue: 0-360 (full color spectrum)
  static Color generate({int alpha = 255}) {
    final hue = _random.nextDouble() * 360;
    final saturation = 0.4 + _random.nextDouble() * 0.4; // 40-80%
    final lightness = 0.35 + _random.nextDouble() * 0.3; // 35-65%
    return HSLColor.fromAHSL(alpha / 255, hue, saturation, lightness).toColor();
  }

  /// Returns the color as #AARRGGBB hex string.
  static String toHex(Color color) {
    final a = (color.a * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(
          2,
          '0',
        );
    final r = (color.r * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(
          2,
          '0',
        );
    final g = (color.g * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(
          2,
          '0',
        );
    final b = (color.b * 255.0)
        .round()
        .clamp(0, 255)
        .toRadixString(16)
        .padLeft(
          2,
          '0',
        );
    return '#$a$r$g$b'.toUpperCase();
  }

  /// Returns Color from #AARRGGBB hex string.
  static Color fromHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse(clean, radix: 16));
  }

  /// Returns white or black depending on which has better contrast.
  static Color contrastingTextColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
