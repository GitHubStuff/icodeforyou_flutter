// lib/src/core/models/fade_configuration.dart

import 'package:flutter/material.dart';

/// Immutable configuration for picker fade overlay effects.
@immutable
class FadeConfiguration {
  /// Creates a [FadeConfiguration] with fully customisable fade styling.
  ///
  /// The [fadeDistance] controls how tall each fade overlay is in logical
  /// pixels and must be greater than `0.0`. The [topColors] and
  /// [bottomColors] lists define the gradient stops for the top and bottom
  /// overlays respectively and must align with [stops]. When [enabled] is
  /// `false` the overlays are not rendered regardless of other values.
  const FadeConfiguration({
    this.enabled = true,
    this.fadeDistance = 40.0,
    this.fadeCurve = Curves.linear,
    this.topColors = const [Color(0xFF000033), Color(0x00000033)],
    this.bottomColors = const [Color(0x00000033), Color(0xFF000033)],
    this.stops = const [0.0, 1.0],
    this.selectedAlwaysOpaque = true,
  }) : assert(fadeDistance > 0.0, 'Fade distance must be positive');

  /// Creates a [FadeConfiguration] suited for a light background.
  ///
  /// Uses opaque white at the outer edge fading to transparent white toward
  /// the centre, matching a typical light-theme surface colour.
  factory FadeConfiguration.light() {
    return const FadeConfiguration(
      topColors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
      bottomColors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
    );
  }

  /// Creates a [FadeConfiguration] suited for a dark background.
  ///
  /// Uses opaque dark grey (`#1E1E1E`) at the outer edge fading to
  /// transparent toward the centre, matching a typical dark-theme surface.
  factory FadeConfiguration.dark() {
    return const FadeConfiguration(
      topColors: [Color(0xFF1E1E1E), Color(0x001E1E1E)],
      bottomColors: [Color(0x001E1E1E), Color(0xFF1E1E1E)],
    );
  }

  /// Creates a [FadeConfiguration] derived from an arbitrary [backgroundColor].
  ///
  /// Constructs the gradient by pairing the fully opaque [backgroundColor]
  /// with a fully transparent copy of the same hue, ensuring the fade blends
  /// seamlessly into any custom surface colour.
  factory FadeConfiguration.forBackground(Color backgroundColor) {
    final opaque = backgroundColor;
    final transparent = backgroundColor.withValues(alpha: 0);
    return FadeConfiguration(
      topColors: [opaque, transparent],
      bottomColors: [transparent, opaque],
    );
  }

  /// Creates a [FadeConfiguration] with fade overlays disabled.
  ///
  /// All other fields retain their default values. Use when the picker should
  /// render without any top or bottom fade treatment.
  factory FadeConfiguration.noFade() {
    return const FadeConfiguration(enabled: false);
  }

  /// Whether the fade overlays are rendered.
  ///
  /// When `false`, [topGradient] and [bottomGradient] are still computed but
  /// the caller is expected to skip painting them. Defaults to `true`.
  final bool enabled;

  /// Height of each fade overlay in logical pixels.
  ///
  /// Determines how far the gradient extends from the top and bottom edges
  /// of the picker toward the selected item. Must be greater than `0.0`.
  final double fadeDistance;

  /// Animation curve applied when transitioning the fade overlay.
  ///
  /// Defaults to [Curves.linear]. Only relevant when the fade overlays are
  /// animated by the consuming widget.
  final Curve fadeCurve;

  /// Gradient colors for the top fade overlay, ordered from edge to centre.
  ///
  /// The first color sits at the top edge (typically opaque) and the last
  /// color sits at the inner boundary (typically transparent). Must have the
  /// same length as [stops].
  final List<Color> topColors;

  /// Gradient colors for the bottom fade overlay, ordered from centre to edge.
  ///
  /// The first color sits at the inner boundary (typically transparent) and
  /// the last color sits at the bottom edge (typically opaque). Must have the
  /// same length as [stops].
  final List<Color> bottomColors;

  /// Gradient stop positions corresponding to [topColors] and [bottomColors].
  ///
  /// Each value must be in the range `0.0` to `1.0` and the list must be the
  /// same length as both color lists. Defaults to `[0.0, 1.0]`.
  final List<double> stops;

  /// Whether the selected item row is always rendered at full opacity.
  ///
  /// When `true`, the overlay gradients are masked so they do not dim the
  /// currently selected item. Defaults to `true`.
  final bool selectedAlwaysOpaque;

  /// A [LinearGradient] for the top fade overlay, flowing top-to-bottom.
  ///
  /// Built from [topColors] and [stops]. Apply this gradient to a
  /// top-aligned overlay widget sized to [fadeDistance].
  LinearGradient get topGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: topColors,
    stops: stops,
  );

  /// A [LinearGradient] for the bottom fade overlay, flowing top-to-bottom.
  ///
  /// Built from [bottomColors] and [stops]. Apply this gradient to a
  /// bottom-aligned overlay widget sized to [fadeDistance].
  LinearGradient get bottomGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: bottomColors,
    stops: stops,
  );

  /// Returns a copy of this configuration with the given fields replaced.
  ///
  /// Fields not provided retain their current values. Passing an empty list
  /// for [topColors], [bottomColors], or [stops] is valid but may produce
  /// unexpected gradient rendering.
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
