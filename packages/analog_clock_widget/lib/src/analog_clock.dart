// lib/src/analog_clock.dart
// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:math';

import 'package:abstractions/abstractions.dart' show ExtendedStatefulWidget;
import 'package:analog_clock_widget/src/clock_style.dart' show ClockStyle;
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';

part '_clock_constants.dart';
part '_clock_models.dart';
part '_clock_painter.dart';
part '_clock_services.dart';
part '_clock_state.dart';

const double defaultRadius = 30;

enum ClockFaceStyle { classic, modern, minimal }

enum HandStyle { traditional, modern, sleek }

abstract class TimeProvider {
  DateTime get now;
}

typedef ThemeProvider = ColorScheme Function(BuildContext context);

class SystemTimeProvider implements TimeProvider {
  @override
  DateTime get now => DateTime.now();
}

ColorScheme flutterThemeProvider(BuildContext context) =>
    Theme.of(context).colorScheme;

/// A customizable analog clock widget that displays the current time
/// with moving hands.
///
/// The [AnalogClock] widget displays a traditional analog clock face with
/// hour, minute, and optionally second hands that update in real-time.
/// The clock can be customized with colors, size, timezone offset, and
/// visual features.
///
/// ## Basic Usage
///
/// ```dart
/// // Simple clock with default settings
/// AnalogClock()
///
/// // Customized clock with style object
/// AnalogClock(
///   radius: 100,
///   style: ClockStyle(
///     faceColor: Colors.white,
///     hourHandColor: Colors.black,
///     showNumbers: true,
///     faceStyle: ClockFaceStyle.modern,
///   ),
/// )
/// ```
///
/// ## Timezone Support
///
/// The clock can display time for different timezones using
/// [utcMinuteOffset]:
///
/// ```dart
/// // New York time (UTC-5)
/// AnalogClock(utcMinuteOffset: -300)
///
/// // Tokyo time (UTC+9)
/// AnalogClock(utcMinuteOffset: 540)
/// ```
class AnalogClock extends StatefulWidget {
  /// Creates an analog clock widget.
  ///
  /// The [radius] must be at least 30 pixels. The [style] parameter
  /// controls all visual aspects of the clock. For testing,
  /// [timeProvider] and [themeProvider] can be injected.
  ///
  /// Throws [ArgumentError] if [radius] is less than the minimum
  /// required size.
  AnalogClock({
    super.key,
    this.radius = defaultRadius,
    this.utcMinuteOffset,
    this.style = ClockStyle.defaultStyle,
    TimeProvider? timeProvider,
    ThemeProvider? themeProvider,
  })  : timeProvider = timeProvider ?? SystemTimeProvider(),
        themeProvider = themeProvider ?? flutterThemeProvider {
    if (radius < _ClockConstants.minimumRadius) {
      throw ArgumentError(
        'radius must be >= ${_ClockConstants.minimumRadius}px. vs: ${radius}px',
      );
    }
  }

  /// The radius of the clock in pixels.
  ///
  /// Must be at least 30 pixels. Defaults to [defaultRadius].
  final double radius;

  /// The timezone offset from UTC in minutes.
  ///
  /// Positive values are east of UTC, negative values are west.
  /// If null, uses the system's local timezone.
  final int? utcMinuteOffset;

  /// The visual style configuration for the clock.
  ///
  /// Controls colors, visibility of elements, and visual styles.
  /// Defaults to [ClockStyle.defaultStyle].
  final ClockStyle style;

  /// Provider for current time. Mainly used for testing.
  final TimeProvider timeProvider;

  /// Provider for theme colors. Mainly used for testing.
  final ThemeProvider themeProvider;

  @override
  State<AnalogClock> createState() => _AnalogClockState();
}
