import 'package:flutter/material.dart';

import 'transparency_range.dart';

/// Plays an opacity transition from [range.begin] to [range.end].
class AnimatedTransparency extends StatefulWidget {
  const AnimatedTransparency({
    super.key,
    required this.range,
    required this.duration,
    this.curve = Curves.linear,
    this.onEnd,
    required this.child,
  });

  final TransparencyRange range;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onEnd;
  final Widget child;

  @override
  State<AnimatedTransparency> createState() => _AnimatedTransparencyState();
}

class _AnimatedTransparencyState extends State<AnimatedTransparency>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _setupAnimation();
    _attachEndListener();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedTransparency oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _opacity = Tween<double>(
      begin: widget.range.begin,
      end: widget.range.end,
    ).animate(curved);
  }

  void _attachEndListener() {
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onEnd?.call();
      }
    });
  }

  void _syncController(AnimatedTransparency oldWidget) {
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    final rangeChanged = oldWidget.range != widget.range;
    final curveChanged = oldWidget.curve != widget.curve;

    if (rangeChanged || curveChanged) {
      _setupAnimation();
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }
}
