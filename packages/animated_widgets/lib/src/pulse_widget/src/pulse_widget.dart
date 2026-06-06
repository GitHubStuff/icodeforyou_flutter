// animated_widgets/lib/src/pulse_widget/pulse_widget.dart
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/widgets.dart';

/// Applies a scale-bounce animation to [child] when [trigger] changes to true.
@deprecated
class PulseWidget extends StatefulWidget {
  /// Creates a [PulseWidget] that pulses [child] when [trigger] becomes true.
  const PulseWidget({
    required this.trigger,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.startPct = 0.75,
    this.middlePct = 1.25,
    this.finishPct = 1,
    super.key,
  });

  final double startPct;
  final double middlePct;
  final double finishPct;

  /// When this flips to true the pulse animation fires.
  final bool trigger;

  /// The duration of the scale-bounce cycle.
  final Duration duration;

  /// The widget to animate.
  final Widget child;

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

//+
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
          TweenSequenceItem(
            tween: Tween(begin: widget.startPct, end: widget.middlePct),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween(begin: widget.middlePct, end: widget.finishPct),
            weight: 50,
          ),
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
