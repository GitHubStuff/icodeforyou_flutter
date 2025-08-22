// clock_constants.dart
part of 'analog_clock.dart';

/// Private constants used throughout the clock implementation.
///
/// These values control the visual proportions, timing, and layout
/// of the analog clock. All constants are tuned for optimal appearance
/// across different clock sizes.
class _ClockConstants {
  /// Default radius when none is specified.
  static const double defaultRadius = 50.0;

  /// Minimum allowed radius for readable clock display.
  static const double minimumRadius = 30.0;

  /// Stroke width for tick marks and borders.
  static const double tickStroke = 1.1;

  /// Font size multiplier relative to clock radius.
  ///
  /// Font size = radius * fontMultiplier
  /// This ensures numbers scale proportionally with clock size.
  static const double fontMultiplier = 0.24;

  /// Hour number offset multiplier from edge.
  ///
  /// Number distance from edge = radius * hourOffsetMultiplier
  /// This creates proper spacing between numbers and clock border.
  static const double hourOffsetMultiplier = 0.15;

  /// Padding inside the clock border for the painted content.
  static const double borderPadding = 4.0;

  /// How frequently the clock updates.
  ///
  /// The second hand and time display refresh at this interval.
  /// One second provides smooth movement without excessive CPU usage.
  static const Duration tickInterval = Duration(seconds: 1);
}
