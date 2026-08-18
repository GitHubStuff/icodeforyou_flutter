// packages/extensions/lib/color/color_pair.dart
import 'package:extensions/color/color_ext.dart';
import 'package:flutter/material.dart';

/// Managers color as a pair, for a single truth for dart and light colors
class ColorPair {
  /// Creates a color pair of two colors
  const ColorPair({required this.dark, required this.light});

  /// Color for a when Brightness.dark
  final Color dark;

  /// Color for a when Brightness.light
  final Color light;

  /// Return the color base if the the current theme is light or dark
  Color current(BuildContext context) => isDark(context) ? dark : light;

  /// Depending on theme returns true/false based on Brightness
  bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Depending on theme returns true/false based on Brightness
  bool isLight(BuildContext context) => !isDark(context);

  /// Return the contrasting Color for the current theme
  Color contrastingColor(
    BuildContext context, {
    Color? forDark,
    Color? forLight,
  }) {
    return isDark(context)
        ? dark.contrastingColor(forDark: forDark)
        : light.contrastingColor(forLight: forLight);
  }
}
