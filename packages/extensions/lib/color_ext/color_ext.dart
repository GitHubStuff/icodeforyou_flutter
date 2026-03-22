// extensions/lib/src/color_extension.dart

import 'package:flutter/painting.dart';

extension ColorExtension on Color {
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
}
