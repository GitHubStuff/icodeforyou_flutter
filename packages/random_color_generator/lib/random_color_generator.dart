// random_color_generator/lib/src/random_color_generator.dart

import 'dart:math';

import 'package:flutter/painting.dart';

abstract final class RandomColorGenerator {
  static final _random = Random();

  static const _kMinSaturation = 0.4;
  static const _kMaxSaturation = 0.8;
  static const _kMinLightness = 0.35;
  static const _kMaxLightness = 0.65;
  static const _kMaxHue = 360.0;
  static const _kMaxAlpha = 255;

  // Absorbs HSL -> Color -> HSL precision loss from 8-bit RGB quantization.
  static const _kEpsilon = 0.005;

  /// Generates a random color in the mid-luminance range.
  ///
  /// Uses HSL color space to ensure:
  /// - Lightness: 35-65% (avoids pure white/black)
  /// - Saturation: 40-80% (vibrant but not garish)
  /// - Hue: 0-360 (full color spectrum)
  static Color generate({int alpha = _kMaxAlpha}) {
    final hue = _random.nextDouble() * _kMaxHue;
    final saturation =
        _kMinSaturation +
        _random.nextDouble() * (_kMaxSaturation - _kMinSaturation);
    final lightness =
        _kMinLightness +
        _random.nextDouble() * (_kMaxLightness - _kMinLightness);
    return HSLColor.fromAHSL(
      alpha / _kMaxAlpha,
      hue,
      saturation,
      lightness,
    ).toColor();
  }

  /// Returns true if [color] falls within the HSL range
  /// that [generate] could produce.
  ///
  /// Applies a small epsilon to account for precision loss
  /// from HSL -> Color -> HSL roundtrip via 8-bit RGB quantization.
  static bool isGenerated({required Color color}) {
    final hsl = HSLColor.fromColor(color);
    return hsl.saturation >= _kMinSaturation - _kEpsilon &&
        hsl.saturation <= _kMaxSaturation + _kEpsilon &&
        hsl.lightness >= _kMinLightness - _kEpsilon &&
        hsl.lightness <= _kMaxLightness + _kEpsilon;
  }

  /// Returns the color as #AARRGGBB hex string.
  static String toHex(Color color) {
    final a = _channelToHex(color.a);
    final r = _channelToHex(color.r);
    final g = _channelToHex(color.g);
    final b = _channelToHex(color.b);
    return '#$a$r$g$b'.toUpperCase();
  }

  /// Returns a [Color] from an #AARRGGBB hex string.
  static Color fromHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse(clean, radix: 16));
  }

  static String _channelToHex(double channel) => (channel * 255.0)
      .round()
      .clamp(0, _kMaxAlpha)
      .toRadixString(16)
      .padLeft(2, '0');
}
