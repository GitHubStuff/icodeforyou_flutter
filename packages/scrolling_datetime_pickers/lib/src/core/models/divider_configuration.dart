// lib/src/core/models/divider_configuration.dart

import 'package:flutter/material.dart';

@immutable
/// Immutable configuration for picker divider appearance.
class DividerConfiguration {
  /// Creates a [DividerConfiguration] with fully customisable divider styling.
  ///
  /// All parameters are optional and fall back to sensible defaults. The
  /// [transparency] must be between `0.0` (fully transparent) and `1.0`
  /// (fully opaque). The [thickness] must be greater than `0.0`. The
  /// [indent], [endIndent], [blurRadius], and [spreadRadius] must each be
  /// non-negative.
  const DividerConfiguration({
    this.color = const Color(0xFFE0E0E0),
    this.transparency = 1.0,
    this.thickness = 1.5,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.blurStyle,
    this.blurRadius = 0.0,
    this.spreadRadius = 0.0,
  }) : assert(
         transparency >= 0.0 && transparency <= 1.0,
         'Transparency must be between 0.0 and 1.0',
       ),
       assert(thickness > 0.0, 'Thickness must be greater than 0'),
       assert(indent >= 0.0, 'Indent must be non-negative'),
       assert(endIndent >= 0.0, 'EndIndent must be non-negative'),
       assert(blurRadius >= 0.0, 'Blur radius must be non-negative'),
       assert(spreadRadius >= 0.0, 'Spread radius must be non-negative');

  /// Creates a [DividerConfiguration] using the default values for all fields.
  ///
  /// Equivalent to calling the default constructor with no arguments.
  factory DividerConfiguration.defaultConfig() {
    return const DividerConfiguration();
  }

  /// Creates a [DividerConfiguration] with a subtle outer glow effect.
  ///
  /// Applies [BlurStyle.outer] with a [blurRadius] of `2.0` and a
  /// [spreadRadius] of `1.0`. The [color], [transparency], and [thickness]
  /// can be overridden; all other fields use their defaults.
  factory DividerConfiguration.withGlow({
    Color color = const Color(0xFFE0E0E0),
    double transparency = 1.0,
    double thickness = 1.5,
  }) {
    return DividerConfiguration(
      color: color,
      transparency: transparency,
      thickness: thickness,
      blurStyle: BlurStyle.outer,
      blurRadius: 2,
      spreadRadius: 1,
    );
  }

  /// Creates a [DividerConfiguration] with a soft blur effect.
  ///
  /// Applies a [blurRadius] of `4.0` using the supplied [blurStyle], which
  /// defaults to [BlurStyle.normal]. The [color], [transparency], and
  /// [thickness] can be overridden; [spreadRadius] defaults to `0.0`.
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
      blurStyle: blurStyle,
      blurRadius: 4,
    );
  }

  /// Base color of the divider line.
  ///
  /// The actual rendered color is [effectiveColor], which applies
  /// [transparency] on top of this value.
  final Color color;

  /// Opacity of the divider, from `0.0` (invisible) to `1.0` (fully opaque).
  ///
  /// Applied to [color] via [effectiveColor]. Must satisfy
  /// `0.0 <= transparency <= 1.0`.
  final double transparency;

  /// Stroke thickness of the divider line in logical pixels.
  ///
  /// Must be greater than `0.0`.
  final double thickness;

  /// Inset from the leading edge of the divider in logical pixels.
  ///
  /// Must be non-negative.
  final double indent;

  /// Inset from the trailing edge of the divider in logical pixels.
  ///
  /// Must be non-negative.
  final double endIndent;

  /// The [BlurStyle] used when rendering a blur or glow effect.
  ///
  /// When `null`, no blur or glow is applied regardless of [blurRadius] and
  /// [spreadRadius]. See [hasEffect].
  final BlurStyle? blurStyle;

  /// Sigma radius of the blur applied to the divider, in logical pixels.
  ///
  /// Only has a visible effect when [blurStyle] is non-null. Must be
  /// non-negative.
  final double blurRadius;

  /// Radius by which the divider's shadow spreads before blurring.
  ///
  /// Only has a visible effect when [blurStyle] is non-null. Must be
  /// non-negative.
  final double spreadRadius;

  /// The resolved color with [transparency] baked in as an alpha value.
  ///
  /// Computed as `color.withAlpha((transparency * 255).round())`. Use this
  /// value when painting the divider rather than [color] directly.
  Color get effectiveColor => color.withAlpha((transparency * 255).round());

  /// Whether this configuration will render a blur or glow effect.
  ///
  /// Returns `true` only when [blurStyle] is non-null and at least one of
  /// [blurRadius] or [spreadRadius] is greater than `0.0`.
  bool get hasEffect =>
      blurStyle != null && (blurRadius > 0 || spreadRadius > 0);

  /// Returns a copy of this configuration with the given fields replaced.
  ///
  /// Fields not provided retain their current values. Note that passing
  /// `null` for [blurStyle] will clear any existing blur or glow effect,
  /// which also causes [hasEffect] to return `false`.
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
