// analog_clock.dart
import 'dart:async';
import 'dart:math';

import 'package:abstractions/abstractions.dart' show ObservingStatefulWidget;
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';

part 'clock_painter.dart';

/// A customizable analog clock widget that displays the current time with moving hands.
///
/// The [AnalogClock] widget displays a traditional analog clock face with hour,
/// minute, and optionally second hands that update in real-time. The clock can be
/// customized with colors, size, timezone offset, and visual features.
///
/// ## Basic Usage
///
/// ```dart
/// // Simple clock with default settings
/// AnalogClock()
///
/// // Customized clock
/// AnalogClock(
///   radius: 100,
///   faceColor: Colors.white,
///   hourHandColor: Colors.black,
///   showNumbers: true,
/// )
/// ```
///
/// ## Timezone Support
///
/// The clock can display time for different timezones using [utcMinuteOffset]:
///
/// ```dart
/// // New York time (UTC-5)
/// AnalogClock(utcMinuteOffset: -300)
///
/// // Tokyo time (UTC+9)
/// AnalogClock(utcMinuteOffset: 540)
/// ```
///
/// ## Theme Integration
///
/// When colors are not specified, the widget automatically uses colors from
/// the current [Theme]. This ensures the clock integrates well with your app's
/// design system.
///
/// ## Performance
///
/// The clock updates every second using an efficient stream that automatically
/// manages resources. The widget properly disposes of timers when removed from
/// the widget tree to prevent memory leaks.
class AnalogClock extends StatefulWidget {
  /// Creates an analog clock widget.
  ///
  /// The [radius] must be at least 30 pixels. All color parameters are optional
  /// and will use theme colors when not specified.
  const AnalogClock({
    super.key,
    this.utcMinuteOffset,
    this.radius = _ClockConstants.defaultRadius,
    this.faceColor,
    this.borderColor,
    this.hourHandColor,
    this.minuteHandColor,
    this.secondHandColor,
    this.showNumbers = true,
    this.showSecondHand = true,
  }) : assert(
         radius >= _ClockConstants.minimumRadius,
         'radius must be greater than or equal to ${_ClockConstants.minimumRadius}px',
       );

  /// The color of the clock border and tick marks.
  ///
  /// If null, uses [ColorScheme.secondary] from the current theme.
  final Color? borderColor;

  /// The background color of the clock face.
  ///
  /// If null, uses [ColorScheme.primaryFixed] from the current theme.
  final Color? faceColor;

  /// The color of the hour hand.
  ///
  /// If null, uses [ColorScheme.secondary] from the current theme.
  final Color? hourHandColor;

  /// The color of the minute hand.
  ///
  /// If null, uses the same color as [hourHandColor].
  final Color? minuteHandColor;

  /// The color of the second hand.
  ///
  /// If null, uses the same color as [hourHandColor].
  /// Has no effect if [showSecondHand] is false.
  final Color? secondHandColor;

  /// The radius of the clock in pixels.
  ///
  /// Must be at least 30 pixels. The total size of the widget will be
  /// [radius] * 2 plus some padding for the border.
  ///
  /// Defaults to 50 pixels.
  final double radius;

  /// The timezone offset from UTC in minutes.
  ///
  /// Positive values are east of UTC, negative values are west of UTC.
  /// For example:
  /// - 0: UTC time
  /// - -300: US Eastern Time (UTC-5)
  /// - 540: Japan Standard Time (UTC+9)
  ///
  /// If null, uses the system's local timezone.
  final int? utcMinuteOffset;

  /// Whether to show hour numbers (1-12) around the clock face.
  ///
  /// Defaults to true. Numbers are automatically hidden on very small clocks
  /// to prevent visual clutter.
  final bool showNumbers;

  /// Whether to show the second hand.
  ///
  /// Defaults to true. The second hand updates every second and provides
  /// visual feedback that the clock is running.
  final bool showSecondHand;

  @override
  State<AnalogClock> createState() => _AnalogClockState();
}

// PRIVATE IMPLEMENTATION BELOW - All internal classes hidden from users

// Constants
class _ClockConstants {
  static const double defaultRadius = 50.0;
  static const double minimumRadius = 30.0;
  static const double tickStroke = 1.1;
  static const double fontMultiplier = 0.24;
  static const double hourOffsetMultiplier = 0.15;
  static const double borderPadding = 4.0;
  static const Duration tickInterval = Duration(seconds: 1);
}

// Value Objects
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

  final Color face;
  final Color border;
  final Color hour;
  final Color minute;
  final Color second;
  final Color tick;
  final Color numbers;

  factory _ClockColors.fromTheme({
    required ThemeData theme,
    Color? faceColor,
    Color? borderColor,
    Color? hourHandColor,
    Color? minuteHandColor,
    Color? secondHandColor,
  }) {
    final resolvedBorder = borderColor ?? theme.colorScheme.secondary;
    final resolvedHour = hourHandColor ?? theme.colorScheme.secondary;

    return _ClockColors(
      face: faceColor ?? theme.colorScheme.primaryFixed,
      border: resolvedBorder,
      hour: resolvedHour,
      minute: minuteHandColor ?? resolvedHour,
      second: secondHandColor ?? resolvedHour,
      tick: resolvedBorder,
      numbers: resolvedHour,
    );
  }
}

@immutable
class _ClockDimensions {
  const _ClockDimensions({
    required this.radius,
    required this.fontSize,
    required this.numberOffset,
    required this.strokeWidth,
  });

  final double radius;
  final double fontSize;
  final double numberOffset;
  final double strokeWidth;

  factory _ClockDimensions.fromRadius(double radius) {
    return _ClockDimensions(
      radius: radius,
      fontSize: radius * _ClockConstants.fontMultiplier,
      numberOffset: radius * _ClockConstants.hourOffsetMultiplier,
      strokeWidth: _ClockConstants.tickStroke,
    );
  }

  double get diameter => radius * 2;
}

// Time Service
abstract class _TimeService {
  Stream<DateTime> get timeStream;
  DateTime get currentTime;
}

class _UtcTimeService implements _TimeService {
  _UtcTimeService({required this.offsetMinutes});

  final int offsetMinutes;
  StreamController<DateTime>? _controller;
  Timer? _timer;

  @override
  Stream<DateTime> get timeStream {
    if (_controller == null) {
      _controller = StreamController<DateTime>.broadcast();
      _timer = Timer.periodic(_ClockConstants.tickInterval, (_) {
        if (_controller != null && !_controller!.isClosed) {
          _controller!.add(currentTime);
        }
      });
    }
    return _controller!.stream;
  }

  @override
  DateTime get currentTime {
    return DateTime.now().toUtc().add(Duration(minutes: offsetMinutes));
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }
}

// Configuration object
@immutable
class _ClockConfiguration {
  const _ClockConfiguration({
    required this.dimensions,
    required this.colors,
    required this.showNumbers,
    required this.showSecondHand,
  });

  final _ClockDimensions dimensions;
  final _ClockColors colors;
  final bool showNumbers;
  final bool showSecondHand;
}

// State class
class _AnalogClockState extends ObservingStatefulWidget<AnalogClock> {
  late final _TimeService _timeService;
  late final _ClockDimensions _dimensions;
  _ClockColors? _colors;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _dimensions = _ClockDimensions.fromRadius(widget.radius);
  }

  void _initializeServices() {
    final offset =
        widget.utcMinuteOffset ?? DateTime.now().timeZoneOffset.inMinutes;
    _timeService = _UtcTimeService(offsetMinutes: offset);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    super.afterFirstLayout(context);
    setState(() {
      _colors = _ClockColors.fromTheme(
        theme: Theme.of(context),
        faceColor: widget.faceColor,
        borderColor: widget.borderColor,
        hourHandColor: widget.hourHandColor,
        minuteHandColor: widget.minuteHandColor,
        secondHandColor: widget.secondHandColor,
      );
    });
  }

  @override
  void dispose() {
    if (_timeService is _UtcTimeService) {
      (_timeService).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure colors are initialized
    _colors ??= _ClockColors.fromTheme(
      theme: Theme.of(context),
      faceColor: widget.faceColor,
      borderColor: widget.borderColor,
      hourHandColor: widget.hourHandColor,
      minuteHandColor: widget.minuteHandColor,
      secondHandColor: widget.secondHandColor,
    );

    final configuration = _ClockConfiguration(
      dimensions: _dimensions,
      colors: _colors!,
      showNumbers: widget.showNumbers,
      showSecondHand: widget.showSecondHand,
    );

    return _ClockWidget(
      configuration: configuration,
      timeService: _timeService,
    );
  }
}

// Presentational Widget
class _ClockWidget extends StatelessWidget {
  const _ClockWidget({required this.configuration, required this.timeService});

  final _ClockConfiguration configuration;
  final _TimeService timeService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: timeService.timeStream,
      initialData: timeService.currentTime,
      builder: (context, snapshot) {
        return Container(
          height: configuration.dimensions.diameter,
          width: configuration.dimensions.diameter,
          decoration: BoxDecoration(
            color: configuration.colors.face,
            shape: BoxShape.circle,
            border: Border.all(
              color: configuration.colors.border,
              width: configuration.dimensions.strokeWidth,
            ),
          ),
          child: CustomPaint(
            painter: _ClockPainter(
              dateTime: snapshot.data ?? timeService.currentTime,
              configuration: configuration,
            ),
          ).withPaddingAll(_ClockConstants.borderPadding),
        );
      },
    );
  }
}
