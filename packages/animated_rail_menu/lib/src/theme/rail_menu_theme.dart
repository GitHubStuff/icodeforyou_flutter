// lib/src/theme/rail_menu_theme.dart

import 'package:animated_rail_menu/src/theme/_rail_menu_theme_dark.dart';
import 'package:animated_rail_menu/src/theme/_rail_menu_theme_light.dart';
import 'package:flutter/material.dart';

/// The theming contract for [AnimatedRailMenu].
///
/// Register via [ThemeData.extensions] in your app:
///
/// ```dart
/// ThemeData.light().copyWith(
///   extensions: [RailMenuTheme.light()],
/// )
/// ```
///
/// If no extension is registered, [AnimatedRailMenu] falls back to
/// [RailMenuTheme.light()] or [RailMenuTheme.dark()] based on
/// [Brightness].
abstract class RailMenuTheme extends ThemeExtension<RailMenuTheme> {
  const RailMenuTheme();

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

  /// Returns the default light [RailMenuTheme].
  factory RailMenuTheme.light() => const RailMenuThemeLight();

  /// Returns the default dark [RailMenuTheme].
  factory RailMenuTheme.dark() => const RailMenuThemeDark();

  /// Returns the appropriate default theme for the given [brightness].
  static RailMenuTheme of(BuildContext context) {
    final theme = Theme.of(context).extension<RailMenuTheme>();
    if (theme != null) return theme;
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const RailMenuThemeDark()
        : const RailMenuThemeLight();
  }
}
