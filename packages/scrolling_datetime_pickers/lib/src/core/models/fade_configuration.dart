// lib/src/core/models/fade_configuration.dart

import 'package:flutter/material.dart';

/// Configuration for picker fade effects.
class FadeConfiguration {
  const FadeConfiguration({
    this.enabled = true,
    this.fadeDistance = 40.0,
    this.fadeCurve = Curves.linear,
    this.topColors = const [Color(0xFF000033), Color(0x00000033)],
    this.bottomColors = const [Color(0x00000033), Color(0xFF000033)],
    this.stops = const [0.0, 1.0],
    this.selectedAlwaysOpaque = true,
  }) : assert(fadeDistance > 0.0, 'Fade distance must be positive');

  /// Light theme preset.
  factory FadeConfiguration.light() {
    return const FadeConfiguration(
      topColors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
      bottomColors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
    );
  }

  /// Dark theme preset.
  factory FadeConfiguration.dark() {
    return const FadeConfiguration(
      topColors: [Color(0xFF1E1E1E), Color(0x001E1E1E)],
      bottomColors: [Color(0x001E1E1E), Color(0xFF1E1E1E)],
    );
  }

  /// Generate fade from background color.
  factory FadeConfiguration.forBackground(Color backgroundColor) {
    final opaque = backgroundColor;
    final transparent = backgroundColor.withValues(alpha: 0);
    return FadeConfiguration(
      topColors: [opaque, transparent],
      bottomColors: [transparent, opaque],
    );
  }

  /// No fade effect.
  factory FadeConfiguration.noFade() {
    return const FadeConfiguration(enabled: false);
  }

  final bool enabled;
  final double fadeDistance;
  final Curve fadeCurve;
  final List<Color> topColors;
  final List<Color> bottomColors;
  final List<double> stops;
  final bool selectedAlwaysOpaque;

  LinearGradient get topGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: topColors,
        stops: stops,
      );

  LinearGradient get bottomGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: bottomColors,
        stops: stops,
      );

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
  int get hashCode => Object.hash(
        enabled,
        fadeDistance,
        fadeCurve,
        Object.hashAll(topColors),
        Object.hashAll(bottomColors),
        Object.hashAll(stops),
        selectedAlwaysOpaque,
      );

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
