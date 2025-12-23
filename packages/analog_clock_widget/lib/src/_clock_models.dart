// clock_models.dart
part of 'analog_clock.dart';

/// Private value object containing all resolved colors for the clock.
///
/// This class takes user-provided colors and theme colors, resolving
/// them into a complete color scheme for all clock elements.
/// Immutable for performance and predictable caching.
@immutable
class _ClockColors {
  const _ClockColors({
    required this.face,
    required this.border,
    required this.hour,
    required this.minute,
    required this.second,
    required this.tick,
    required this.numbers,
  });

  /// Background color of the clock face.
  final Color face;

  /// Color of the outer border and main structural elements.
  final Color border;

  /// Color of the hour hand.
  final Color hour;

  /// Color of the minute hand.
  final Color minute;

  /// Color of the second hand.
  final Color second;

  /// Color of tick marks around the clock edge.
  final Color tick;

  /// Color of the hour numbers (1-12).
  final Color numbers;

  /// Factory constructor that resolves colors from style and theme.
  ///
  /// Takes user-provided colors from [style] and fills in any null
  /// values with appropriate colors from the [colorScheme].
  factory _ClockColors.fromTheme({
    required ColorScheme colorScheme,
    required ClockStyle style,
  }) {
    final resolvedBorder = style.borderColor ?? colorScheme.secondary;
    final resolvedHour = style.hourHandColor ?? colorScheme.secondary;

    return _ClockColors(
      face: style.faceColor ?? colorScheme.primaryFixed,
      border: resolvedBorder,
      hour: resolvedHour,
      minute: style.minuteHandColor ?? resolvedHour,
      second: style.secondHandColor ?? resolvedHour,
      tick: resolvedBorder,
      numbers: resolvedHour,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ClockColors &&
        other.face == face &&
        other.border == border &&
        other.hour == hour &&
        other.minute == minute &&
        other.second == second &&
        other.tick == tick &&
        other.numbers == numbers;
  }

  @override
  int get hashCode {
    return Object.hash(face, border, hour, minute, second, tick, numbers);
  }
}

/// Private value object containing all computed dimensions for the clock.
///
/// This class calculates pixel-perfect measurements based on the clock
/// radius, ensuring consistent proportions across all clock sizes.
@immutable
class _ClockDimensions {
  const _ClockDimensions({
    required this.radius,
    required this.fontSize,
    required this.numberOffset,
    required this.strokeWidth,
  });

  /// The radius of the clock face in pixels.
  final double radius;

  /// Font size for hour numbers, scaled to clock size.
  final double fontSize;

  /// Distance from clock edge to place hour numbers.
  final double numberOffset;

  /// Stroke width for lines and borders.
  final double strokeWidth;

  /// Factory constructor that computes all dimensions from radius.
  ///
  /// Uses the constants from [_ClockConstants] to maintain consistent
  /// proportions regardless of clock size.
  factory _ClockDimensions.fromRadius(double radius) {
    return _ClockDimensions(
      radius: radius,
      fontSize: radius * _ClockConstants.fontMultiplier,
      numberOffset: radius * _ClockConstants.hourOffsetMultiplier,
      strokeWidth: _ClockConstants.tickStroke,
    );
  }

  /// The full diameter of the clock (radius * 2).
  double get diameter => radius * 2;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ClockDimensions &&
        other.radius == radius &&
        other.fontSize == fontSize &&
        other.numberOffset == numberOffset &&
        other.strokeWidth == strokeWidth;
  }

  @override
  int get hashCode {
    return Object.hash(radius, fontSize, numberOffset, strokeWidth);
  }
}

/// Private configuration object containing all settings for clock rendering.
///
/// This combines dimensions, colors, and style into a single immutable
/// object that can be efficiently cached and compared for performance.
/// Used by the painter to render the clock.
@immutable
class _ClockConfiguration {
  const _ClockConfiguration({
    required this.dimensions,
    required this.colors,
    required this.style,
  });

  /// All computed size and layout measurements.
  final _ClockDimensions dimensions;

  /// All resolved colors for clock elements.
  final _ClockColors colors;

  /// The user-provided style configuration.
  final ClockStyle style;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ClockConfiguration &&
        other.dimensions == dimensions &&
        other.colors == colors &&
        other.style == style;
  }

  @override
  int get hashCode {
    return Object.hash(dimensions, colors, style);
  }
}

/// Private configuration for drawing individual clock hands.
///
/// Contains all the information needed to render a single hand
/// (hour, minute, or second) with the appropriate style.
@immutable
class _HandConfiguration {
  const _HandConfiguration({
    required this.color,
    required this.length,
    required this.strokeWidth,
    required this.style,
  });

  /// Color to draw this hand.
  final Color color;

  /// Length of the hand from center to tip, in pixels.
  final double length;

  /// Width/thickness of the hand stroke.
  final double strokeWidth;

  /// Visual style for rendering this hand.
  final HandStyle style;
}

/// Private configuration for drawing tick marks around the clock edge.
///
/// Contains all the information needed to render tick marks with
/// the appropriate style, including different lengths for hour vs minute marks.
@immutable
class _TickConfiguration {
  const _TickConfiguration({
    required this.color,
    required this.strokeWidth,
    required this.shortLength,
    required this.longLength,
    required this.delta,
    required this.style,
  });

  /// Color to draw tick marks.
  final Color color;

  /// Width of tick mark strokes.
  final double strokeWidth;

  /// Length of minute tick marks (shorter).
  final double shortLength;

  /// Length of hour tick marks (longer).
  final double longLength;

  /// Distance from clock edge to start drawing ticks.
  final double delta;

  /// Visual style that determines tick appearance.
  final ClockFaceStyle style;

  /// Factory constructor that computes tick dimensions and style.
  ///
  /// Different face styles get different tick proportions:
  /// - Classic: Standard proportions with all ticks
  /// - Modern: Larger, bolder ticks with rounded caps
  /// - Minimal: Tiny ticks that become dots
  factory _TickConfiguration.fromDimensions(
    _ClockDimensions dimensions,
    Color color,
    ClockFaceStyle style,
  ) {
    // Different tick sizes based on style
    double shortMultiplier, longMultiplier, strokeMultiplier;

    switch (style) {
      case ClockFaceStyle.classic:
        shortMultiplier = 0.025;
        longMultiplier = 0.05;
        strokeMultiplier = 1.0;
        break;
      case ClockFaceStyle.modern:
        shortMultiplier = 0.04;
        longMultiplier = 0.08;
        strokeMultiplier = 1.5;
        break;
      case ClockFaceStyle.minimal:
        shortMultiplier = 0.015;
        longMultiplier = 0.03;
        strokeMultiplier = 0.8;
        break;
    }

    return _TickConfiguration(
      color: color,
      strokeWidth: dimensions.strokeWidth * strokeMultiplier,
      shortLength: dimensions.radius * shortMultiplier,
      longLength: dimensions.radius * longMultiplier,
      delta: 4.0 + dimensions.strokeWidth,
      style: style,
    );
  }
}

/// Special testing helpers
///
@visibleForTesting
int debugClockColorsHash({
  required ColorScheme colorScheme,
  required ClockStyle style,
}) {
  final c = _ClockColors.fromTheme(colorScheme: colorScheme, style: style);
  return c.hashCode;
}

@visibleForTesting
int debugClockDimensionsHash(double radius) {
  final d = _ClockDimensions.fromRadius(radius);
  return d.hashCode;
}

@visibleForTesting
int debugClockConfigurationHash({
  required double radius,
  required ColorScheme colorScheme,
  required ClockStyle style,
}) {
  final dims = _ClockDimensions.fromRadius(radius);
  final cols = _ClockColors.fromTheme(colorScheme: colorScheme, style: style);
  final cfg = _ClockConfiguration(dimensions: dims, colors: cols, style: style);
  return cfg.hashCode;
}
