// packages/animated_widgets/lib/src/timed_widget/timed_widget.dart

import 'dart:async' show Timer;

import 'package:flutter/widgets.dart';

/// A widget that displays its [child] for a specified [duration], then invokes
/// [onFinish] when the duration elapses.
///
/// The timer starts when the widget is first inserted into the tree. If
/// [duration] changes during the widget's lifetime, the timer is reset and
/// restarted with the new duration.
class TimedWidget extends StatefulWidget {
  const TimedWidget({
    required this.child,
    required this.onFinish,
    this.duration = const Duration(milliseconds: 1250),
    super.key,
  });

  final Widget child;
  final Duration duration;
  final VoidCallback onFinish;

  @override
  State<TimedWidget> createState() => _TimedWidgetState();
}

class _TimedWidgetState extends State<TimedWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(widget.duration, widget.onFinish);
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void didUpdateWidget(covariant TimedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
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
