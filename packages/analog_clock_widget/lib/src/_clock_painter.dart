// clock_painter.dart
part of 'analog_clock.dart';

/// Private custom painter that renders the analog clock face and hands.
///
/// This painter handles all the visual rendering including:
/// - Different tick mark styles based on face style
/// - Hour numbers with style-appropriate fonts
/// - Clock hands with different visual styles
/// - Proper angle calculations for accurate time display
///
/// The painter is stateless and relies on the provided configuration
/// and current time to determine what to draw.
class _ClockPainter extends CustomPainter {
  _ClockPainter({required this.dateTime, required this.configuration});

  /// The current time to display on the clock.
  final DateTime dateTime;

  /// Complete configuration for colors, dimensions, and styles.
  final _ClockConfiguration configuration;

  // Computed properties set during paint() call
  late Offset _center;
  late double _radius;

  /// Initializes layout dimensions based on actual canvas size.
  void _initializeDimensions(Size size) {
    _center = Offset(size.width / 2, size.height / 2);
    _radius = min(size.width / 2, size.height / 2);
  }

  /// Gets tick configuration with style-specific measurements.
  _TickConfiguration get _tickConfig => _TickConfiguration.fromDimensions(
    _ClockDimensions.fromRadius(_radius),
    configuration.colors.tick,
    configuration.style.faceStyle,
  );

  @override
  void paint(Canvas canvas, Size size) {
    _initializeDimensions(size);

    // Only draw ticks if clock is large enough to be readable
    if (_radius >= _ClockConstants.minimumRadius) {
      _drawTicks(canvas);
    }

    // Draw numbers if enabled and style permits
    if (configuration.style.showNumbers) {
      _drawNumbers(canvas);
    }

    // Always draw hands
    _drawHands(canvas);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TICK MARK RENDERING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Draws tick marks around the clock edge based on face style.
  void _drawTicks(Canvas canvas) {
    switch (configuration.style.faceStyle) {
      case ClockFaceStyle.classic:
        _drawClassicTicks(canvas);
        break;
      case ClockFaceStyle.modern:
        _drawModernTicks(canvas);
        break;
      case ClockFaceStyle.minimal:
        _drawMinimalTicks(canvas);
        break;
    }
  }

  /// Draws traditional tick marks - all 60 ticks with hour marks longer.
  void _drawClassicTicks(Canvas canvas) {
    final tickPaint = Paint()
      ..color = _tickConfig.color
      ..strokeWidth = _tickConfig.strokeWidth;

    for (int i = 0; i < _ClockConstants.totalTicks; i++) {
      final isHourTick = i % _ClockConstants.ticksPerHour == 0;
      final tickLength = isHourTick
          ? _tickConfig.longLength
          : _tickConfig.shortLength;

      final angle = i * _ClockConstants.radiansPerTick;
      final tickStart = _calculateTickStart(angle);
      final tickEnd = _calculateTickEnd(angle, tickLength);

      canvas.drawLine(tickStart, tickEnd, tickPaint);
    }
  }

  /// Draws modern tick marks - only hour marks with rounded caps.
  void _drawModernTicks(Canvas canvas) {
    final tickPaint = Paint()
      ..color = _tickConfig.color
      ..strokeWidth = _tickConfig.strokeWidth
      ..strokeCap = StrokeCap.round;

    // Only draw hour ticks for modern style
    for (int i = 0; i < _ClockConstants.totalTicks; i += _ClockConstants.ticksPerHour) {
      final angle = i * _ClockConstants.radiansPerTick;
      final tickStart = _calculateTickStart(angle);
      final tickEnd = _calculateTickEnd(angle, _tickConfig.longLength);

      canvas.drawLine(tickStart, tickEnd, tickPaint);
    }
  }

  /// Draws minimal tick marks - only dots at 12, 3, 6, 9 o'clock.
  void _drawMinimalTicks(Canvas canvas) {
    final dotPaint = Paint()
      ..color = _tickConfig.color
      ..style = PaintingStyle.fill;

    // Only draw dots at cardinal positions for minimal style
    for (int i = 0; i < _ClockConstants.totalTicks; i += _ClockConstants.ticksPerQuarter) {
      final angle = i * _ClockConstants.radiansPerTick;
      final dotDistance = _radius - _tickConfig.longLength * _ClockConstants.minimalDotDistanceMultiplier;
      final dotCenter = Offset(
        _center.dx + dotDistance * cos(angle),
        _center.dy + dotDistance * sin(angle),
      );

      final dotRadius = _tickConfig.strokeWidth * _ClockConstants.minimalDotRadiusMultiplier;
      canvas.drawCircle(dotCenter, dotRadius, dotPaint);
    }
  }

  /// Calculates the outer starting point for a tick mark.
  Offset _calculateTickStart(double angle) {
    return Offset(
      _center.dx + (_radius + _tickConfig.delta) * cos(angle),
      _center.dy + (_radius + _tickConfig.delta) * sin(angle),
    );
  }

  /// Calculates the inner ending point for a tick mark.
  Offset _calculateTickEnd(double angle, double tickLength) {
    return Offset(
      _center.dx + (_radius - tickLength) * cos(angle),
      _center.dy + (_radius - tickLength) * sin(angle),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HOUR NUMBER RENDERING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Draws hour numbers (1-12) around the clock face.
  void _drawNumbers(Canvas canvas) {
    // Don't show numbers for minimal style
    if (configuration.style.faceStyle == ClockFaceStyle.minimal) {
      return;
    }

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < _ClockConstants.totalTicks; i += _ClockConstants.ticksPerHour) {
      final hourNumber = _getHourNumber(i);
      final numberPosition = _calculateNumberPosition(i);

      _paintNumber(canvas, textPainter, hourNumber, numberPosition);
    }
  }

  /// Converts tick index to hour number (1-12).
  int _getHourNumber(int tickIndex) {
    final hour = tickIndex ~/ _ClockConstants.ticksPerHour;
    return hour == 0 ? _ClockConstants.hoursOnFace : hour;
  }

  /// Calculates position for an hour number.
  Offset _calculateNumberPosition(int tickIndex) {
    // Subtract topPositionTickOffset to rotate 12 o'clock to top
    final angle = (tickIndex - _ClockConstants.topPositionTickOffset) * _ClockConstants.radiansPerTick;
    final numberRadius = _radius - (_radius * _ClockConstants.hourOffsetMultiplier);

    return Offset(
      _center.dx + numberRadius * cos(angle),
      _center.dy + numberRadius * sin(angle),
    );
  }

  /// Paints a single hour number at the specified position.
  void _paintNumber(
    Canvas canvas,
    TextPainter textPainter,
    int number,
    Offset position,
  ) {
    final fontWeight = configuration.style.faceStyle == ClockFaceStyle.modern
        ? FontWeight.w300 // Light weight for modern style
        : FontWeight.normal;

    textPainter
      ..text = TextSpan(
        text: number.toString(),
        style: TextStyle(
          fontSize: _radius * _ClockConstants.fontMultiplier,
          color: configuration.colors.numbers,
          fontWeight: fontWeight,
        ),
      )
      ..layout();

    final centeredPosition = Offset(
      position.dx - textPainter.width / 2,
      position.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, centeredPosition);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLOCK HAND RENDERING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Draws all clock hands (hour, minute, second, center dot).
  void _drawHands(Canvas canvas) {
    final baseStrokeWidth = _radius / _ClockConstants.strokeWidthDivisor;

    _drawHourHand(canvas, baseStrokeWidth);
    _drawMinuteHand(canvas, baseStrokeWidth);

    if (configuration.style.showSecondHand) {
      _drawSecondHand(canvas, baseStrokeWidth);
    }

    _drawCenterDot(canvas, baseStrokeWidth);
  }

  /// Draws the hour hand.
  void _drawHourHand(Canvas canvas, double baseStrokeWidth) {
    final handConfig = _HandConfiguration(
      color: configuration.colors.hour,
      length: _radius * _ClockConstants.hourHandLengthRatio,
      strokeWidth: _getHandStrokeWidth(baseStrokeWidth, isHourHand: true),
      style: configuration.style.handStyle,
    );

    final angle = _calculateHourAngle();
    _drawHand(canvas, handConfig, angle, isHourHand: true);
  }

  /// Draws the minute hand.
  void _drawMinuteHand(Canvas canvas, double baseStrokeWidth) {
    final handConfig = _HandConfiguration(
      color: configuration.colors.minute,
      length: _radius * _ClockConstants.minuteHandLengthRatio,
      strokeWidth: _getHandStrokeWidth(baseStrokeWidth, isHourHand: false),
      style: configuration.style.handStyle,
    );

    final angle = _calculateMinuteAngle();
    _drawHand(canvas, handConfig, angle, isHourHand: false);
  }

  /// Draws the second hand.
  void _drawSecondHand(Canvas canvas, double baseStrokeWidth) {
    final handConfig = _HandConfiguration(
      color: configuration.colors.second,
      length: _radius * _ClockConstants.secondHandLengthRatio,
      strokeWidth: _getSecondHandStrokeWidth(baseStrokeWidth),
      style: configuration.style.handStyle,
    );

    final angle = _calculateSecondAngle();
    _drawSecondHandShape(canvas, handConfig, angle);
  }

  /// Gets stroke width for hour/minute hands based on style.
  double _getHandStrokeWidth(
    double baseStrokeWidth, {
    required bool isHourHand,
  }) {
    final multiplier = isHourHand
        ? _ClockConstants.hourHandWidthMultiplier
        : _ClockConstants.minuteHandWidthMultiplier;

    switch (configuration.style.handStyle) {
      case HandStyle.traditional:
        return baseStrokeWidth * multiplier;
      case HandStyle.modern:
        return baseStrokeWidth * multiplier * _ClockConstants.modernHandThicknessFactor;
      case HandStyle.sleek:
        return baseStrokeWidth * multiplier * _ClockConstants.sleekHandThicknessFactor;
    }
  }

  /// Gets stroke width for second hand based on style.
  double _getSecondHandStrokeWidth(double baseStrokeWidth) {
    switch (configuration.style.handStyle) {
      case HandStyle.traditional:
        return baseStrokeWidth / _ClockConstants.traditionalSecondHandDivisor;
      case HandStyle.modern:
        return baseStrokeWidth / _ClockConstants.modernSecondHandDivisor;
      case HandStyle.sleek:
        return baseStrokeWidth / _ClockConstants.sleekSecondHandDivisor;
    }
  }

  /// Draws a clock hand with the specified style.
  void _drawHand(
    Canvas canvas,
    _HandConfiguration config,
    double angle, {
    required bool isHourHand,
  }) {
    switch (config.style) {
      case HandStyle.traditional:
        _drawTraditionalHand(canvas, config, angle);
        break;
      case HandStyle.modern:
        _drawModernHand(canvas, config, angle, isHourHand: isHourHand);
        break;
      case HandStyle.sleek:
        _drawSleekHand(canvas, config, angle);
        break;
    }
  }

  /// Draws a traditional simple line hand.
  void _drawTraditionalHand(
    Canvas canvas,
    _HandConfiguration config,
    double angle,
  ) {
    final handPosition = _calculateHandEndPosition(config.length, angle);

    final paint = Paint()
      ..color = config.color
      ..strokeWidth = config.strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(_center, handPosition, paint);
  }

  /// Draws a modern tapered hand with filled shape.
  void _drawModernHand(
    Canvas canvas,
    _HandConfiguration config,
    double angle, {
    required bool isHourHand,
  }) {
    final handEnd = _calculateHandEndPosition(config.length, angle);

    final paint = Paint()
      ..color = config.color
      ..style = PaintingStyle.fill;

    // Create a tapered hand shape that gets wider at the base
    final baseWidth = config.strokeWidth;
    final tipWidth = config.strokeWidth * _ClockConstants.modernHandTipRatio;
    final perpAngle = angle; // Perpendicular to hand direction

    final path = Path();

    // Calculate the four corners of the tapered hand
    final baseLeft = Offset(
      _center.dx + baseWidth * cos(perpAngle),
      _center.dy + baseWidth * sin(perpAngle),
    );
    final baseRight = Offset(
      _center.dx - baseWidth * cos(perpAngle),
      _center.dy - baseWidth * sin(perpAngle),
    );
    final tipLeft = Offset(
      handEnd.dx + tipWidth * cos(perpAngle),
      handEnd.dy + tipWidth * sin(perpAngle),
    );
    final tipRight = Offset(
      handEnd.dx - tipWidth * cos(perpAngle),
      handEnd.dy - tipWidth * sin(perpAngle),
    );

    // Build the tapered path
    path.moveTo(baseLeft.dx, baseLeft.dy);
    path.lineTo(tipLeft.dx, tipLeft.dy);
    path.lineTo(tipRight.dx, tipRight.dy);
    path.lineTo(baseRight.dx, baseRight.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  /// Draws a sleek minimal hand.
  void _drawSleekHand(Canvas canvas, _HandConfiguration config, double angle) {
    final handPosition = _calculateHandEndPosition(config.length, angle);

    final paint = Paint()
      ..color = config.color
      ..strokeWidth = config.strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(_center, handPosition, paint);
  }

  /// Draws the second hand (always simple line regardless of style).
  void _drawSecondHandShape(
    Canvas canvas,
    _HandConfiguration config,
    double angle,
  ) {
    final handPosition = _calculateHandEndPosition(config.length, angle);

    final paint = Paint()
      ..color = config.color
      ..strokeWidth = config.strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(_center, handPosition, paint);
  }

  /// Calculates the end position of a hand given its length and angle.
  Offset _calculateHandEndPosition(double length, double angle) {
    // Subtract rotation offset to convert from 3 o'clock to 12 o'clock reference
    final adjustedAngle = angle - _ClockConstants.twelveOClockRotationOffset;
    return Offset(
      _center.dx + length * cos(adjustedAngle),
      _center.dy + length * sin(adjustedAngle),
    );
  }

  /// Draws the center dot with size based on hand style.
  void _drawCenterDot(Canvas canvas, double baseStrokeWidth) {
    final centerPaint = Paint()
      ..color = configuration.colors.hour
      ..style = PaintingStyle.fill;

    final dotRadius = switch (configuration.style.handStyle) {
      HandStyle.traditional => baseStrokeWidth * _ClockConstants.traditionalDotMultiplier,
      HandStyle.modern => baseStrokeWidth * _ClockConstants.modernDotMultiplier,
      HandStyle.sleek => baseStrokeWidth * _ClockConstants.sleekDotMultiplier,
    };

    canvas.drawCircle(_center, dotRadius, centerPaint);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ANGLE CALCULATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculates the current angle for the hour hand.
  double _calculateHourAngle() {
    return dateTime.hour * _ClockConstants.radiansPerHour +
           dateTime.minute * _ClockConstants.radiansPerMinuteForHourHand;
  }

  /// Calculates the current angle for the minute hand.
  double _calculateMinuteAngle() {
    final minuteSweep = _radius < _ClockConstants.minimumRadius
        ? 0.0
        : (dateTime.second / _ClockConstants.secondsPerMinute - _ClockConstants.minuteSweepOffset);
    return (dateTime.minute + minuteSweep) * _ClockConstants.radiansPerTick;
  }

  /// Calculates the current angle for the second hand.
  double _calculateSecondAngle() {
    return dateTime.second * _ClockConstants.radiansPerTick;
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return dateTime != oldDelegate.dateTime ||
        configuration != oldDelegate.configuration;
  }
}
