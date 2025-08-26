part of 'analog_clock.dart';

/// Private state management for the [AnalogClock] widget.
///
/// Handles configuration caching, dependency injection, lifecycle management,
/// and efficient rebuilds. Only recreates configuration when actually needed.
class _AnalogClockState extends ObservingStatefulWidget<AnalogClock> {
  late _TimeService _timeService;
  late _ClockConfiguration _configuration;
  bool _isConfigurationValid = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  /// Initializes the time service with current timezone offset.
  void _initializeServices() {
    final offset =
        widget.utcMinuteOffset ?? DateTime.now().timeZoneOffset.inMinutes;
    _timeService = _UtcTimeService(
      offsetMinutes: offset,
      timeProvider: widget.timeProvider,
    );
  }

  /// Creates or updates the cached clock configuration.
  ///
  /// Only recreates the configuration if it has actually changed,
  /// preventing unnecessary rebuilds and improving performance.
  void _createConfiguration(BuildContext context) {
    final colorScheme = widget.themeProvider.getColorScheme(context);
    final dimensions = _ClockDimensions.fromRadius(widget.radius);
    final colors = _ClockColors.fromTheme(
      colorScheme: colorScheme,
      style: widget.style,
    );

    final newConfiguration = _ClockConfiguration(
      dimensions: dimensions,
      colors: colors,
      style: widget.style,
    );

    // Only update if configuration actually changed
    if (!_isConfigurationValid || _configuration != newConfiguration) {
      _configuration = newConfiguration;
      _isConfigurationValid = true;
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    super.afterFirstLayout(context);
    setState(() {
      _createConfiguration(context);
    });
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if we need to recreate the time service
    final oldOffset =
        oldWidget.utcMinuteOffset ?? DateTime.now().timeZoneOffset.inMinutes;
    final newOffset =
        widget.utcMinuteOffset ?? DateTime.now().timeZoneOffset.inMinutes;

    if (oldOffset != newOffset ||
        oldWidget.timeProvider != widget.timeProvider) {
      _timeService.dispose();
      _initializeServices();
    }

    // Check if configuration needs updating
    if (oldWidget.radius != widget.radius ||
        oldWidget.style != widget.style ||
        oldWidget.themeProvider != widget.themeProvider) {
      _isConfigurationValid = false;
      // Configuration will be recreated in next build
    }
  }

  @override
  void dispose() {
    _timeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create configuration if not valid
    if (!_isConfigurationValid) {
      _createConfiguration(context);
    }

    return _ClockWidget(
      configuration: _configuration,
      timeService: _timeService,
    );
  }
}
