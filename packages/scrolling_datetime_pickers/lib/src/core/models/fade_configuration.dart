// lib/src/core/models/fade_configuration.dart

import 'package:flutter/material.dart';

/// Configuration for picker fade effects
class FadeConfiguration {
  /// Whether to apply fade effect
  final bool enabled;

  /// Distance over which to apply fade (in pixels)
  final double fadeDistance;

  /// Fade curve type (linear, easeIn, easeOut, etc.)
  final Curve fadeCurve;

  /// Top fade gradient colors
  final List<Color> topColors;

  /// Bottom fade gradient colors
  final List<Color> bottomColors;

  /// Gradient stops for fade
  final List<double> stops;

  /// Whether selected item should always be fully opaque
  final bool selectedAlwaysOpaque;

  const FadeConfiguration({
    this.enabled = true,
    this.fadeDistance = 40.0,
    this.fadeCurve = Curves.linear,
    this.topColors = const [
      Color(0xFF000033),
      Color(0x00000033),
    ],
    this.bottomColors = const [
      Color(0x00000033),
      Color(0xFF000033),
    ],
    this.stops = const [0.0, 1.0],
    this.selectedAlwaysOpaque = true,
  }) : assert(fadeDistance > 0.0, 'Fade distance must be positive');

  /// Default configuration with fade enabled
  factory FadeConfiguration.defaultConfig() {
    return FadeConfiguration();
  }

  /// Configuration with no fade effect
  factory FadeConfiguration.noFade() {
    return FadeConfiguration(
      enabled: false,
    );
  }

  /// Configuration with custom fade distance
  factory FadeConfiguration.withDistance({
    required double distance,
    Curve curve = Curves.linear,
  }) {
    return FadeConfiguration(
      fadeDistance: distance,
      fadeCurve: curve,
    );
  }

  /// Configuration with ease-in fade
  factory FadeConfiguration.easeIn({
    double fadeDistance = 40.0,
  }) {
    return FadeConfiguration(
      fadeDistance: fadeDistance,
      fadeCurve: Curves.easeIn,
    );
  }

  /// Configuration with ease-out fade
  factory FadeConfiguration.easeOut({
    double fadeDistance = 40.0,
  }) {
    return FadeConfiguration(
      fadeDistance: fadeDistance,
      fadeCurve: Curves.easeOut,
    );
  }

  /// Create gradient for top fade
  LinearGradient get topGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: topColors,
        stops: stops,
      );

  /// Create gradient for bottom fade
  LinearGradient get bottomGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: bottomColors,
        stops: stops,
      );

  /// Validate configuration
  bool get isValid {
    return topColors.length >= 2 &&
        bottomColors.length >= 2 &&
        topColors.length == stops.length &&
        bottomColors.length == stops.length;
  }

  /// Copy with new values
  FadeConfiguration copyWith({
    bool? enabled,
    double? fadeDistance,
    Curve? fadeCurve,
    List<Color>? topColors,
    List<Color>? bottomColors,
    List<double>? stops,
    bool? selectedAlwaysOpaque,
  }) {
    return FadeConfiguration(
      enabled: enabled ?? this.enabled,
      fadeDistance: fadeDistance ?? this.fadeDistance,
      fadeCurve: fadeCurve ?? this.fadeCurve,
      topColors: topColors ?? this.topColors,
      bottomColors: bottomColors ?? this.bottomColors,
      stops: stops ?? this.stops,
      selectedAlwaysOpaque: selectedAlwaysOpaque ?? this.selectedAlwaysOpaque,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FadeConfiguration &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          fadeDistance == other.fadeDistance &&
          fadeCurve == other.fadeCurve &&
          _listEquals(topColors, other.topColors) &&
          _listEquals(bottomColors, other.bottomColors) &&
          _listEquals(stops, other.stops) &&
          selectedAlwaysOpaque == other.selectedAlwaysOpaque;

  @override
  int get hashCode =>
      enabled.hashCode ^
      fadeDistance.hashCode ^
      fadeCurve.hashCode ^
      Object.hashAll(topColors) ^
      Object.hashAll(bottomColors) ^
      Object.hashAll(stops) ^
      selectedAlwaysOpaque.hashCode;

  /// Helper to compare lists
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
