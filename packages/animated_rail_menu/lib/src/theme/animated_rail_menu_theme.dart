// animated_rail_menu/lib/src/theme/animated_rail_menu_theme.dart

import 'package:animated_rail_menu/src/theme/animated_rail_menu_theme_dark.dart';
import 'package:animated_rail_menu/src/theme/animated_rail_menu_theme_light.dart';
import 'package:flutter/material.dart';

/// The theming extension for [AnimatedRailMenuTheme].
///
/// Register via [ThemeData.extensions] in your app:
///
/// ```dart
/// ThemeData.light().copyWith(
///   extensions: [AnimatedRailMenuTheme.light()],
/// )
/// ```
///
/// If no extension is registered, [AnimatedRailMenuTheme] falls back to
/// [AnimatedRailMenuTheme.light()] or [AnimatedRailMenuTheme.dark()] based on
/// [Brightness].
abstract class AnimatedRailMenuTheme
    extends ThemeExtension<AnimatedRailMenuTheme> {
  /// Placeholder Constructor
  const AnimatedRailMenuTheme();

  /// Returns the default dark [AnimatedRailMenuTheme].
  factory AnimatedRailMenuTheme.dark() => const AnimatedRailMenuThemeDark();

  /// Returns the default light [AnimatedRailMenuTheme].
  factory AnimatedRailMenuTheme.light() => const AnimatedRailMenuThemeLight();

  /// The background color of the rail or bar surface.
  Color get backgroundColor;

  /// The color of the active indicator bar and active icon.
  Color get activeColor;

  /// The color applied to inactive icons and labels.
  Color get inactiveColor;

  /// The text style applied to item labels.
  TextStyle get labelStyle;

  /// The elevation of the rail or bar surface.
  double get elevation;

  /// Returns the appropriate default theme for the given device/app brightness.
  static AnimatedRailMenuTheme of(BuildContext context) {
    final theme = Theme.of(context).extension<AnimatedRailMenuTheme>();
    if (theme != null) return theme;
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const AnimatedRailMenuThemeDark()
        : const AnimatedRailMenuThemeLight();
  }
}
