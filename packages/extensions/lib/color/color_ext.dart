// packages/extensions/lib/color_ext/color_ext.dart
import 'package:flutter/painting.dart';

/// Extensions on [Color] providing equality, contrast, and integer conversion.
extension ColorExt on Color {
  /// Compares two colors by ARGB value.
  bool equals(Color other) =>
      a == other.a && r == other.r && g == other.g && b == other.b;

  /// Returns white or black depending on which has better contrast
  /// against this color.
  Color contrastingTextColor() => computeLuminance() > 0.5
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);

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
}
