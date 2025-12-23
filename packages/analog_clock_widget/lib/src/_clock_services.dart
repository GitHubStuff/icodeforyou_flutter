// clock_services.dart
part of 'analog_clock.dart';

/// Private abstract interface for time services within the clock.
///
/// Wraps the injected [TimeProvider] and provides streaming time updates
/// with proper resource management. Different implementations can handle
/// different timezone and update strategies.
abstract class _TimeService {
  /// Stream that emits the current time approximately once per second.
  Stream<DateTime> get timeStream;

  /// Gets the current time synchronously.
  DateTime get currentTime;

  /// Cleans up resources and cancels any active timers.
  void dispose();
}

/// Private implementation of [_TimeService] that handles UTC offset and streaming.
///
/// Takes a [TimeProvider] and timezone offset, then provides a stream of
/// time updates that automatically handles timezone conversion and resource cleanup.
class _UtcTimeService implements _TimeService {
  _UtcTimeService({required this.offsetMinutes, required this.timeProvider});

  /// Timezone offset from UTC in minutes.
  final int offsetMinutes;

  /// The injected time provider for getting current time.
  final TimeProvider timeProvider;

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
    return timeProvider.now.toUtc().add(Duration(minutes: offsetMinutes));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }
}

/// Private presentation widget that renders the clock UI.
///
/// Pure presentation component that takes a configuration and time service,
/// then renders the actual clock widget with proper decoration and painting.
/// Separated from state management for clean architecture.
class _ClockWidget extends StatelessWidget {
  const _ClockWidget({required this.configuration, required this.timeService});

  /// Complete configuration for rendering the clock.
  final _ClockConfiguration configuration;

  /// Service providing time updates.
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
