// packages/extensions/lib/color/color_ext.dart
import 'package:flutter/material.dart'
    show Brightness, Color, Colors, HSLColor, ThemeData;

/// Extensions on [Color] providing equality, contrast, and integer conversion.
extension ColorExt on Color {
  /// Compares two colors by ARGB value.
  bool equals(Color other) =>
      a == other.a && r == other.r && g == other.g && b == other.b;

  /// Returns white or black depending on which has better contrast
  /// against this color.
  Color contrastingColor({Color? forDark, Color? forLight}) =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.light
      ? forLight ?? const Color(0xFF000000)
      : forDark ?? const Color(0xFFFFFFFF);

  /// Returns the color as a 32-bit ARGB integer.
  int toInt() =>
      ((a * 255).round() << 24) |
      ((r * 255).round() << 16) |
      ((g * 255).round() << 8) |
      (b * 255).round();

  /// Returns this color with its opacity set to [alpha] (0.0–1.0).
  /// Defaults to 0.25 when no value is given.
  Color withAlphaValue([double alpha = 0.25]) {
    assert(
      alpha >= 0.0 && alpha <= 1.0,
      'alpha must be between 0.0 and 1.0',
    );
    return withValues(alpha: alpha);
  }

  /// Constants for Neon effect
  static const double _accentSaturation = 1;
  static const double _accentLightness = 0.62;
  static const double _coreTint = 0.45;

  /// Returns an accent-style version of this colour: the same hue at full
  /// saturation and raised lightness, the way Material accent swatches relate
  /// to their primary swatches (e.g. `Colors.green` → something close to
  /// `Colors.greenAccent`).
  ///
  /// Greys (zero saturation) have no hue to accent and are returned unchanged.
  Color toNeonAccent() {
    final hsl = HSLColor.fromColor(this);

    return (hsl.saturation == 0)
        ? this
        : hsl
              .withSaturation(_accentSaturation)
              .withLightness(_accentLightness)
              .toColor();
  }

  /// Returns the tube-core colour for this glow: white with a faint tint of
  /// the hue, so the glyph reads as lit rather than as flat coloured text.
  Color toNeonCore({double tint = _coreTint}) {
    assert(tint >= 0.0 && tint <= 1.0, 'Tint is 0.0 to 1.0');
    return Color.lerp(Colors.white, toNeonAccent(), tint)!;
  }
}
