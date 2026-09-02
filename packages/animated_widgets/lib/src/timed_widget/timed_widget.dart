// packages/animated_widgets/lib/src/timed_widget/timed_widget.dart

import 'dart:async' show Timer;

import 'package:flutter/widgets.dart';

/// A widget that displays its [child] for a specified [duration], then
/// invokes [onFinish] when the duration elapses.
///
/// The timer starts when the widget is first inserted into the tree. If
/// [duration] changes during the widget's lifetime, the timer is reset
/// and restarted with the new duration.
class TimedWidget extends StatefulWidget {
  /// Creates a [TimedWidget] that waits for [duration] before firing
  /// the [onFinish] callback.
  const TimedWidget({
    required this.child,
    required this.onFinish,
    this.duration = const Duration(milliseconds: 1250),
    super.key,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// The amount of time to wait before triggering the [onFinish]
  /// callback.
  final Duration duration;

  /// The callback executed exactly once after [duration] has elapsed.
  final VoidCallback onFinish;

  @override
  State<TimedWidget> createState() => _TimedWidgetState();
}

class _TimedWidgetState extends State<TimedWidget> {
  /// The active timer counting down to the finish callback.
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  /// Starts a new [Timer] using the current widget's [duration].
  void _startTimer() {
    _timer = Timer(widget.duration, widget.onFinish);
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void didUpdateWidget(covariant TimedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart the timer only if the requested duration has changed.
    if (oldWidget.duration != widget.duration) {
      _timer?.cancel();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
