// clock_painter.dart
part of 'analog_clock.dart';

// Hand configuration - following SRP and ISP (PRIVATE)
@immutable
class _HandConfiguration {
  const _HandConfiguration({
    required this.color,
    required this.length,
    required this.strokeWidth,
  });

  final Color color;
  final double length;
  final double strokeWidth;
}

// Tick configuration - following SRP (PRIVATE)
@immutable
class _TickConfiguration {
  const _TickConfiguration({
    required this.color,
    required this.strokeWidth,
    required this.shortLength,
    required this.longLength,
    required this.delta,
  });

  final Color color;
  final double strokeWidth;
  final double shortLength;
  final double longLength;
  final double delta;

  factory _TickConfiguration.fromDimensions(
    _ClockDimensions dimensions,
    Color color,
  ) {
    return _TickConfiguration(
      color: color,
      strokeWidth: dimensions.strokeWidth,
      shortLength: dimensions.radius * 0.025,
      longLength: dimensions.radius * 0.05,
      delta: 4.0 + dimensions.strokeWidth,
    );
  }
}

// Improved Clock Painter - following SRP and cleaner methods (PRIVATE)
class _ClockPainter extends CustomPainter {
  _ClockPainter({required this.dateTime, required this.configuration});

  final DateTime dateTime;
  final _ClockConfiguration configuration;

  // Computed properties for better readability - FIXED: use actual canvas size
  late Offset _center;
  late double _radius;

  void _initializeDimensions(Size size) {
    _center = Offset(size.width / 2, size.height / 2);
    _radius = min(size.width / 2, size.height / 2);
  }

  _TickConfiguration get _tickConfig => _TickConfiguration.fromDimensions(
    _ClockDimensions.fromRadius(_radius), // Use actual canvas radius
    configuration.colors.tick,
  );

  @override
  void paint(Canvas canvas, Size size) {
    _initializeDimensions(size);

    if (_radius >= _ClockConstants.minimumRadius) {
      _drawTicks(canvas);
    }

    if (configuration.showNumbers) {
      _drawNumbers(canvas);
    }

    _drawHands(canvas);
  }

  // Tick drawing - extracted to separate method for SRP
  void _drawTicks(Canvas canvas) {
    final tickPaint = Paint()
      ..color = _tickConfig.color
      ..strokeWidth = _tickConfig.strokeWidth;

    for (int i = 0; i < 60; i++) {
      final isHourTick = i % 5 == 0;
      final tickLength = isHourTick
          ? _tickConfig.longLength
          : _tickConfig.shortLength;

      final angle = i * pi / 30;
      final tickStart = _calculateTickStart(angle);
      final tickEnd = _calculateTickEnd(angle, tickLength);

      canvas.drawLine(tickStart, tickEnd, tickPaint);
    }
  }

  Offset _calculateTickStart(double angle) {
    return Offset(
      _center.dx + (_radius + _tickConfig.delta) * cos(angle),
      _center.dy + (_radius + _tickConfig.delta) * sin(angle),
    );
  }

  Offset _calculateTickEnd(double angle, double tickLength) {
    return Offset(
      _center.dx + (_radius - tickLength) * cos(angle),
      _center.dy + (_radius - tickLength) * sin(angle),
    );
  }

  // Number drawing - extracted and simplified
  void _drawNumbers(Canvas canvas) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 60; i += 5) {
      final hourNumber = _getHourNumber(i);
      final numberPosition = _calculateNumberPosition(i);

      _paintNumber(canvas, textPainter, hourNumber, numberPosition);
    }
  }

  int _getHourNumber(int tickIndex) {
    final hour = tickIndex ~/ 5;
    return hour == 0 ? 12 : hour;
  }

  Offset _calculateNumberPosition(int tickIndex) {
    final angle =
        (tickIndex - 15) * pi / 30; // FIXED: -15 to position 12 at top
    final numberRadius =
        _radius -
        (_radius * _ClockConstants.hourOffsetMultiplier); // Use actual radius

    return Offset(
      _center.dx + numberRadius * cos(angle),
      _center.dy + numberRadius * sin(angle),
    );
  }

  void _paintNumber(
    Canvas canvas,
    TextPainter textPainter,
    int number,
    Offset position,
  ) {
    textPainter
      ..text = TextSpan(
        text: number.toString(),
        style: TextStyle(
          fontSize:
              _radius * _ClockConstants.fontMultiplier, // Use actual radius
          color: configuration.colors.numbers,
        ),
      )
      ..layout();

    final centeredPosition = Offset(
      position.dx - textPainter.width / 2,
      position.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, centeredPosition);
  }

  // Hand drawing - extracted and organized
  void _drawHands(Canvas canvas) {
    final baseStrokeWidth = _radius / 20;

    _drawHourHand(canvas, baseStrokeWidth);
    _drawMinuteHand(canvas, baseStrokeWidth);

    if (configuration.showSecondHand) {
      _drawSecondHand(canvas, baseStrokeWidth);
    }
  }

  void _drawHourHand(Canvas canvas, double baseStrokeWidth) {
    final handConfig = _HandConfiguration(
      color: configuration.colors.hour,
      length: _radius / 2,
      strokeWidth: baseStrokeWidth / 2,
    );

    final angle = _calculateHourAngle();
    _drawHand(canvas, handConfig, angle);
  }

  void _drawMinuteHand(Canvas canvas, double baseStrokeWidth) {
    final handConfig = _HandConfiguration(
      color: configuration.colors.minute,
      length: _radius * 3 / 4,
      strokeWidth: baseStrokeWidth / 2,
    );

    final angle = _calculateMinuteAngle();
    _drawHand(canvas, handConfig, angle);
  }

  void _drawSecondHand(Canvas canvas, double baseStrokeWidth) {
    final handConfig = _HandConfiguration(
      color: configuration.colors.second,
      length: _radius * 4 / 5,
      strokeWidth: baseStrokeWidth / 3,
    );

    final angle = _calculateSecondAngle();
    _drawHand(canvas, handConfig, angle);
  }

  void _drawHand(Canvas canvas, _HandConfiguration config, double angle) {
    final handPosition = Offset(
      _center.dx + config.length * cos(angle - pi / 2),
      _center.dy + config.length * sin(angle - pi / 2),
    );

    final paint = Paint()
      ..color = config.color
      ..strokeWidth = config.strokeWidth;

    canvas.drawLine(_center, handPosition, paint);
  }

  // Angle calculations - extracted for clarity and testability
  double _calculateHourAngle() {
    return dateTime.hour * pi / 6 +
        dateTime.minute * pi / 360; // Keep exactly like original
  }

  double _calculateMinuteAngle() {
    final minuteSweep = _radius < _ClockConstants.minimumRadius
        ? 0.0
        : (dateTime.second / 60 - 0.16);
    return (dateTime.minute + minuteSweep) * pi / 30;
  }

  double _calculateSecondAngle() {
    return dateTime.second * pi / 30;
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return dateTime != oldDelegate.dateTime ||
        configuration != oldDelegate.configuration;
  }
}
