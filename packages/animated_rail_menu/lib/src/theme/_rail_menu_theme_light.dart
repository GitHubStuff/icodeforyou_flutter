// lib/src/theme/_rail_menu_theme_light.dart

import 'package:animated_rail_menu/src/theme/rail_menu_theme.dart';
import 'package:flutter/material.dart';

/// Default light [RailMenuTheme].
class RailMenuThemeLight extends RailMenuTheme {
  /// Creates a [RailMenuThemeLight].
  const RailMenuThemeLight();

  @override
  Color get backgroundColor => Colors.white;

  @override
  Color get activeColor => const Color(0xFF6750A4);

  @override
  Color get inactiveColor => const Color(0xFF49454F);

  @override
  TextStyle get labelStyle => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Color(0xFF49454F),
        overflow: TextOverflow.ellipsis,
      );

  @override
  double get elevation => 2;

  @override
  RailMenuTheme copyWith({
    Color? backgroundColor,
    Color? activeColor,
    Color? inactiveColor,
    TextStyle? labelStyle,
    double? elevation,
  }) =>
      _RailMenuThemeLightCopy(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        activeColor: activeColor ?? this.activeColor,
        inactiveColor: inactiveColor ?? this.inactiveColor,
        labelStyle: labelStyle ?? this.labelStyle,
        elevation: elevation ?? this.elevation,
      );

  @override
  RailMenuTheme lerp(RailMenuTheme? other, double t) {
    if (other is! RailMenuTheme) return this;
    return _RailMenuThemeLightCopy(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      activeColor: Color.lerp(activeColor, other.activeColor, t)!,
      inactiveColor: Color.lerp(inactiveColor, other.inactiveColor, t)!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
    );
  }
}

class _RailMenuThemeLightCopy extends RailMenuThemeLight {
  const _RailMenuThemeLightCopy({
    required Color backgroundColor,
    required Color activeColor,
    required Color inactiveColor,
    required TextStyle labelStyle,
    required double elevation,
  })  : _backgroundColor = backgroundColor,
        _activeColor = activeColor,
        _inactiveColor = inactiveColor,
        _labelStyle = labelStyle,
        _elevation = elevation;

  final Color _backgroundColor;
  final Color _activeColor;
  final Color _inactiveColor;
  final TextStyle _labelStyle;
  final double _elevation;

  @override
  Color get backgroundColor => _backgroundColor;

  @override
  Color get activeColor => _activeColor;

  @override
  Color get inactiveColor => _inactiveColor;

  @override
  TextStyle get labelStyle => _labelStyle;

  @override
  double get elevation => _elevation;
}

double? lerpDouble(double a, double b, double t) => a + (b - a) * t;
