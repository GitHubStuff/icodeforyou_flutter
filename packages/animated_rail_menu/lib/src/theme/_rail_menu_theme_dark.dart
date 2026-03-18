// lib/src/theme/_rail_menu_theme_dark.dart

import 'package:animated_rail_menu/src/theme/_rail_menu_theme_light.dart';
import 'package:animated_rail_menu/src/theme/rail_menu_theme.dart';
import 'package:flutter/material.dart';

/// Default dark [RailMenuTheme].
class RailMenuThemeDark extends RailMenuTheme {
  /// Creates a [RailMenuThemeDark].
  const RailMenuThemeDark();

  @override
  Color get backgroundColor => const Color(0xFF1C1B1F);

  @override
  Color get activeColor => const Color(0xFFD0BCFF);

  @override
  Color get inactiveColor => const Color(0xFFCAC4D0);

  @override
  TextStyle get labelStyle => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Color(0xFFCAC4D0),
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
      _RailMenuThemeDarkCopy(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        activeColor: activeColor ?? this.activeColor,
        inactiveColor: inactiveColor ?? this.inactiveColor,
        labelStyle: labelStyle ?? this.labelStyle,
        elevation: elevation ?? this.elevation,
      );

  @override
  RailMenuTheme lerp(RailMenuTheme? other, double t) {
    if (other is! RailMenuTheme) return this;
    return _RailMenuThemeDarkCopy(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      activeColor: Color.lerp(activeColor, other.activeColor, t)!,
      inactiveColor: Color.lerp(inactiveColor, other.inactiveColor, t)!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
    );
  }
}

class _RailMenuThemeDarkCopy extends RailMenuThemeDark {
  const _RailMenuThemeDarkCopy({
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
