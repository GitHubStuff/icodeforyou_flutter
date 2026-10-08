// packages/duration_widget/lib/src/ticking_duration_widget.dart
import 'package:duration_widget/src/duration_widget.dart' show DurationWidget;
import 'package:duration_widget/src/ticking_clock_cubit.dart'
    show TickingClockCubit;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A [DurationWidget] that keeps itself up to date.
///
/// Takes the same parameters as [DurationWidget]. [currentTime] seeds an
/// internal [TickingClockCubit], which advances by [interval] on every
/// tick; each emitted [DateTime] rebuilds the underlying [DurationWidget]
/// with that value as its `currentTime`, so the displayed duration moves
/// on its own while [eventTime] stays fixed.
///
/// The widget owns the cubit: it is created when the widget is inserted
/// into the tree and closed when the widget is removed.
///
/// ### Example
///
/// ```dart
/// TickingDurationWidget(
///   eventTime: DateTime(2026, 1, 1, 12, 0),
///   currentTime: DateTime.now(),
///   showLeadingZero: true,
/// )
/// ```
///
/// See also:
///
///  * [DurationWidget], the stateless widget rebuilt on every tick.
///  * [TickingClockCubit], the periodic source of `currentTime`.
class TickingDurationWidget extends StatelessWidget {
  /// Creates a [TickingDurationWidget].
  ///
  /// The [eventTime] and [currentTime] arguments must not be null.
  /// [showLeadingZero] defaults to `false` and [interval] to one second.
  const TickingDurationWidget({
    required this.eventTime,
    required this.currentTime,
    required this.textStyle,
    super.key,
    this.showLeadingZero = false,
    this.interval = const Duration(seconds: 1),
  });

  /// The target timestamp of the event being measured against.
  ///
  /// Depending on whether this timestamp is before or after the ticking
  /// current time, the displayed value is an elapsed duration or a
  /// countdown.
  final DateTime eventTime;

  /// The point in time the internal clock starts from.
  ///
  /// This is the cubit's initial state. Typically [DateTime.now].
  final DateTime currentTime;

  /// Text style to control display
  final TextStyle textStyle;

  /// Whether numeric units less than 10 should be padded with a leading zero.
  ///
  /// Defaults to `false` (e.g., outputs `"5m"` instead of `"05m"`).
  final bool showLeadingZero;

  /// How often the displayed duration advances.
  ///
  /// Defaults to one second. Must be strictly greater than [Duration.zero].
  final Duration interval;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TickingClockCubit>(
      create: (_) => TickingClockCubit(currentTime, interval),
      child: BlocBuilder<TickingClockCubit, DateTime>(
        builder: (context, tickedTime) => DurationWidget(
          eventTime: eventTime,
          currentTime: tickedTime,
          textStyle: textStyle,
          showLeadingZero: showLeadingZero,
        ),
      ),
    );
  }
}
