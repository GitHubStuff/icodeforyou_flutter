// lib/src/pulse_widget/pulse_widget.dart

import 'dart:async';

import 'package:flutter/widgets.dart';

/// Applies a scale-bounce animation to [child] when [trigger] changes to true.
class PulseWidget extends StatefulWidget {
  const PulseWidget({
    required this.trigger,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    super.key,
  });

  final bool trigger;
  final Duration duration;
  final Widget child;

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scale =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1, end: 1.2), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.2, end: 1), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(PulseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scale,
    child: widget.child,
  );
}
