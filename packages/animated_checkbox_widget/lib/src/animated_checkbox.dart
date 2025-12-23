// lib/src/animated_checkbox.dart
import 'package:flutter/material.dart';

import '_dissolve_particle.dart';
import '_particle_generator.dart';
import '_checkmark_path_builder.dart';
import '_checkmark_painter.dart';

/// A widget that animates a checkmark drawing or dissolving effect
class AnimatedCheckbox extends StatefulWidget {
  /// Width and height of the checkbox widget (minimum 5.0)
  final double width;

  /// Background color of the widget
  final Color background;

  /// Color of the checkmark stroke
  final Color strokeColor;

  /// Whether to draw (true) or dissolve (false) the checkmark
  final bool draw;

  /// Duration of the animation
  final Duration duration;

  /// Starting point of checkmark (normalized 0.0-1.0)
  final Offset startOffset;

  /// Middle point of checkmark (normalized 0.0-1.0)
  final Offset midOffset;

  /// Ending point of checkmark (normalized 0.0-1.0)
  final Offset finishOffset;

  /// Animation curve for drawing effect
  final Curve curve;

  /// Callback fired when animation completes with the final draw state
  final ValueChanged<bool> onAnimationComplete;

  const AnimatedCheckbox({
    super.key,
    this.width = 100.0,
    this.background = Colors.transparent,
    this.strokeColor = Colors.purple,
    required this.draw,
    this.duration = const Duration(milliseconds: 850),
    this.startOffset = const Offset(0.05, 0.52),
    this.midOffset = const Offset(0.45, 0.95),
    this.finishOffset = const Offset(0.95, 0.06),
    this.curve = Curves.easeInOutQuart,
    required this.onAnimationComplete,
  }) : assert(width >= 5.0, 'Width must be at least 5.0');

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _animation;
  List<DissolveParticle> _particles = [];
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _validateOffsets();
    _initializeAnimation();
  }

  void _validateOffsets() {
    assert(
      widget.startOffset.dx >= 0.0 && widget.startOffset.dx <= 1.0,
      'startOffset.dx must be 0.0-1.0, got: ${widget.startOffset.dx}',
    );
    assert(
      widget.startOffset.dy >= 0.0 && widget.startOffset.dy <= 1.0,
      'startOffset.dy must be 0.0-1.0, got: ${widget.startOffset.dy}',
    );
    assert(
      widget.midOffset.dx >= 0.0 && widget.midOffset.dx <= 1.0,
      'midOffset.dx must be 0.0-1.0, got: ${widget.midOffset.dx}',
    );
    assert(
      widget.midOffset.dy >= 0.0 && widget.midOffset.dy <= 1.0,
      'midOffset.dy must be 0.0-1.0, got: ${widget.midOffset.dy}',
    );
    assert(
      widget.finishOffset.dx >= 0.0 && widget.finishOffset.dx <= 1.0,
      'finishOffset.dx must be 0.0-1.0, got: ${widget.finishOffset.dx}',
    );
    assert(
      widget.finishOffset.dy >= 0.0 && widget.finishOffset.dy <= 1.0,
      'finishOffset.dy must be 0.0-1.0, got: ${widget.finishOffset.dy}',
    );
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldReinitialize(oldWidget)) {
      _initializeAnimation();
    } else if (oldWidget.duration != widget.duration) {
      // Update controller duration without full reinitialization
      _updateDuration();
    }
  }

  bool _shouldReinitialize(AnimatedCheckbox oldWidget) {
    // Only reinitialize if draw state changes or curve changes
    return oldWidget.draw != widget.draw || oldWidget.curve != widget.curve;
  }

  void _updateDuration() {
    if (_controller != null && !_isAnimating) {
      // Only update duration if not currently animating
      _controller!.duration = widget.duration;
    }
  }

  void _initializeAnimation() {
    _controller?.dispose();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller!, curve: widget.curve));

    _controller!.addStatusListener(_handleAnimationComplete);
    _startAnimation();
  }

  void _startAnimation() {
    if (_isAnimating) return;

    _isAnimating = true;

    if (!widget.draw) {
      _generateDissolveParticles();
    }

    _controller!.forward(from: 0.0);
  }

  void _generateDissolveParticles() {
    final pathBuilder = CheckmarkPathBuilder(
      width: widget.width,
      startOffset: widget.startOffset,
      midOffset: widget.midOffset,
      finishOffset: widget.finishOffset,
    );
    final path = pathBuilder.buildCheckmarkPath();
    _particles = ParticleGenerator.generateFromPath(path);
  }

  void _handleAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _isAnimating = false;
      widget.onAnimationComplete(widget.draw);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.width,
      color: widget.background,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.width, widget.width),
            painter: CheckmarkPainter(
              progress: _animation.value,
              strokeColor: widget.strokeColor,
              isDraw: widget.draw,
              particles: _particles,
              width: widget.width,
              startOffset: widget.startOffset,
              midOffset: widget.midOffset,
              finishOffset: widget.finishOffset,
            ),
          );
        },
      ),
    );
  }
}
