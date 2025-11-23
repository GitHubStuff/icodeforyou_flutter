// lib/src/core/models/divider_configuration.dart

import 'package:flutter/material.dart';

/// Configuration for picker divider appearance
class DividerConfiguration {
  /// Color of the divider lines
  final Color color;

  /// Transparency of dividers (0.0 to 1.0)
  final double transparency;

  /// Thickness of divider lines
  final double thickness;

  /// Horizontal padding from left edge
  final double indent;

  /// Horizontal padding from right edge
  final double endIndent;

  /// Blur style for divider effect
  final BlurStyle? blurStyle;

  /// Blur radius for divider effect
  final double blurRadius;

  /// Spread radius for glow effect
  final double spreadRadius;

  const DividerConfiguration({
    this.color = const Color(0xFFE0E0E0),
    this.transparency = 1.0,
    this.thickness = 1.5,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.blurStyle,
    this.blurRadius = 0.0,
    this.spreadRadius = 0.0,
  })  : assert(transparency >= 0.0 && transparency <= 1.0,
            'Transparency must be between 0.0 and 1.0'),
        assert(thickness > 0.0, 'Thickness must be greater than 0'),
        assert(indent >= 0.0, 'Indent must be non-negative'),
        assert(endIndent >= 0.0, 'EndIndent must be non-negative'),
        assert(blurRadius >= 0.0, 'Blur radius must be non-negative'),
        assert(spreadRadius >= 0.0, 'Spread radius must be non-negative');

  /// Default configuration with sensible defaults
  factory DividerConfiguration.defaultConfig() {
    return const DividerConfiguration(
      color: Color(0xFFE0E0E0),
      transparency: 1.0,
      thickness: 1.5,
      indent: 0.0,
      endIndent: 0.0,
      blurStyle: null,
      blurRadius: 0.0,
      spreadRadius: 0.0,
    );
  }

  /// Configuration with subtle glow effect
  factory DividerConfiguration.withGlow({
    Color color = const Color(0xFFE0E0E0),
    double transparency = 1.0,
    double thickness = 1.5,
  }) {
    return DividerConfiguration(
      color: color,
      transparency: transparency,
      thickness: thickness,
      indent: 0.0,
      endIndent: 0.0,
      blurStyle: BlurStyle.outer,
      blurRadius: 2.0,
      spreadRadius: 1.0,
    );
  }

  /// Configuration with blur effect
  factory DividerConfiguration.withBlur({
    Color color = const Color(0xFFE0E0E0),
    double transparency = 0.8,
    double thickness = 2.0,
    BlurStyle blurStyle = BlurStyle.normal,
  }) {
    return DividerConfiguration(
      color: color,
      transparency: transparency,
      thickness: thickness,
      indent: 0.0,
      endIndent: 0.0,
      blurStyle: blurStyle,
      blurRadius: 4.0,
      spreadRadius: 0.0,
    );
  }

  /// Get the actual color with transparency applied
  Color get effectiveColor => color.withAlpha((transparency * 255).round());

  /// Whether divider has any blur or glow effect
  bool get hasEffect =>
      blurStyle != null && (blurRadius > 0 || spreadRadius > 0);

  /// Create a copy with optional new values
  DividerConfiguration copyWith({
    Color? color,
    double? transparency,
    double? thickness,
    double? indent,
    double? endIndent,
    BlurStyle? blurStyle,
    double? blurRadius,
    double? spreadRadius,
  }) {
    return DividerConfiguration(
      color: color ?? this.color,
      transparency: transparency ?? this.transparency,
      thickness: thickness ?? this.thickness,
      indent: indent ?? this.indent,
      endIndent: endIndent ?? this.endIndent,
      blurStyle: blurStyle ?? this.blurStyle,
      blurRadius: blurRadius ?? this.blurRadius,
      spreadRadius: spreadRadius ?? this.spreadRadius,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DividerConfiguration &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          transparency == other.transparency &&
          thickness == other.thickness &&
          indent == other.indent &&
          endIndent == other.endIndent &&
          blurStyle == other.blurStyle &&
          blurRadius == other.blurRadius &&
          spreadRadius == other.spreadRadius;

  @override
  int get hashCode =>
      color.hashCode ^
      transparency.hashCode ^
      thickness.hashCode ^
      indent.hashCode ^
      endIndent.hashCode ^
      blurStyle.hashCode ^
      blurRadius.hashCode ^
      spreadRadius.hashCode;
}
