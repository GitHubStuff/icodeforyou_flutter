// clock_constants.dart
part of 'analog_clock.dart';

/// Private constants used throughout the clock implementation.
///
/// These values control the visual proportions, timing, and layout
/// of the analog clock. All constants are tuned for optimal appearance
/// across different clock sizes.
class _ClockConstants {
  // ═══════════════════════════════════════════════════════════════════════════
  // CLOCK GEOMETRY
  // ═══════════════════════════════════════════════════════════════════════════

  /// Total tick marks around the clock face (one per minute).
  static const int totalTicks = 60;

  /// Number of tick marks between each hour position.
  static const int ticksPerHour = 5;

  /// Tick marks between cardinal positions (12, 3, 6, 9).
  static const int ticksPerQuarter = 15;

  /// Total hours displayed on the clock face.
  static const int hoursOnFace = 12;

  /// Tick offset to position 12 o'clock at the top.
  /// 
  /// Clock angles start at 3 o'clock (0°), so we subtract 15 ticks
  /// (90° or π/2) to rotate 12 to the top position.
  static const int topPositionTickOffset = 15;

  // ─────────────────────────────────────────────────────────────────────────────
  // RADIAN CONSTANTS (final because pi is not compile-time const)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Radians per tick mark (2π / 60 ticks = π / 30).
  static final double radiansPerTick = pi / 30;

  /// Radians per hour for the hour hand (2π / 12 hours = π / 6).
  static final double radiansPerHour = pi / 6;

  /// Radians the hour hand moves per minute (π/6 per hour / 60 minutes).
  static final double radiansPerMinuteForHourHand = pi / 360;

  /// Rotation offset to convert from 3 o'clock reference to 12 o'clock reference.
  /// 
  /// Standard trig starts at 3 o'clock (east), but clocks start at 12 o'clock (north).
  /// Subtracting π/2 (90°) rotates the coordinate system appropriately.
  static final double twelveOClockRotationOffset = pi / 2;

  // ═══════════════════════════════════════════════════════════════════════════
  // SIZING & LAYOUT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Minimum allowed radius for readable clock display.
  static const double minimumRadius = 30.0;

  /// Stroke width for tick marks and borders.
  static const double tickStroke = 1.1;

  /// Font size multiplier relative to clock radius.
  static const double fontMultiplier = 0.24;

  /// Hour number offset multiplier from edge.
  static const double hourOffsetMultiplier = 0.15;

  /// Padding inside the clock border for the painted content.
  static const double borderPadding = 4.0;

  /// Divisor to calculate base stroke width from radius.
  static const double strokeWidthDivisor = 20.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // HAND LENGTH RATIOS (relative to radius)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Hour hand length as fraction of radius.
  static const double hourHandLengthRatio = 0.5;

  /// Minute hand length as fraction of radius.
  static const double minuteHandLengthRatio = 0.75;

  /// Second hand length as fraction of radius.
  static const double secondHandLengthRatio = 0.8;

  // ═══════════════════════════════════════════════════════════════════════════
  // HAND STROKE WIDTH MULTIPLIERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Base multiplier for hour hand thickness.
  static const double hourHandWidthMultiplier = 0.7;

  /// Base multiplier for minute hand thickness.
  static const double minuteHandWidthMultiplier = 0.5;

  /// Modern style makes hands thicker by this factor.
  static const double modernHandThicknessFactor = 1.5;

  /// Sleek style makes hands thinner by this factor.
  static const double sleekHandThicknessFactor = 0.6;

  /// Second hand width divisors by style.
  static const double traditionalSecondHandDivisor = 3.0;
  static const double modernSecondHandDivisor = 2.5;
  static const double sleekSecondHandDivisor = 4.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // MODERN HAND SHAPE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Tip width as fraction of base width for tapered modern hands.
  static const double modernHandTipRatio = 0.3;

  // ═══════════════════════════════════════════════════════════════════════════
  // CENTER DOT SIZE MULTIPLIERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Center dot size for traditional style.
  static const double traditionalDotMultiplier = 0.8;

  /// Center dot size for modern style (larger).
  static const double modernDotMultiplier = 1.2;

  /// Center dot size for sleek style (smaller).
  static const double sleekDotMultiplier = 0.5;

  // ═══════════════════════════════════════════════════════════════════════════
  // MINIMAL STYLE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Multiplier for dot distance from edge in minimal style.
  static const double minimalDotDistanceMultiplier = 2.0;

  /// Multiplier for dot radius in minimal style.
  static const double minimalDotRadiusMultiplier = 2.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // TICK CONFIGURATION BY STYLE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Base offset from clock edge for tick marks.
  static const double tickDeltaBase = 4.0;

  // Classic style tick proportions
  static const double classicShortTickMultiplier = 0.025;
  static const double classicLongTickMultiplier = 0.05;
  static const double classicStrokeMultiplier = 1.0;

  // Modern style tick proportions (bolder)
  static const double modernShortTickMultiplier = 0.04;
  static const double modernLongTickMultiplier = 0.08;
  static const double modernTickStrokeMultiplier = 1.5;

  // Minimal style tick proportions (thinner)
  static const double minimalShortTickMultiplier = 0.015;
  static const double minimalLongTickMultiplier = 0.03;
  static const double minimalTickStrokeMultiplier = 0.8;

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sweep offset for smooth minute hand movement.
  /// 
  /// This creates a slight anticipation effect where the minute hand
  /// begins moving toward the next position before the full minute.
  static const double minuteSweepOffset = 0.16;

  /// Seconds in a minute (for sweep calculation).
  static const double secondsPerMinute = 60.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // TIMING
  // ═══════════════════════════════════════════════════════════════════════════

  /// How frequently the clock updates.
  static const Duration tickInterval = Duration(seconds: 1);
}
