// lib/src/animated_checkbox.dart
import 'package:flutter/material.dart';

import 'dissolve_particle.dart';
import 'particle_generator.dart';
import 'checkmark_path_builder.dart';
import 'checkmark_painter.dart';

/// A widget that animates a checkmark drawing or dissolving effect
///
/// Follows Open/Closed Principle - open for extension, closed for modification
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

  /// Callback fired when animation completes with the final draw state
  final ValueChanged<bool> onAnimationComplete;

  const AnimatedCheckbox({
    super.key,
    this.width = 100.0,
    this.background = Colors.transparent,
    this.strokeColor = Colors.purple,
    required this.draw,
    this.duration = const Duration(seconds: 1),
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
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldReinitialize(oldWidget)) {
      _initializeAnimation();
    }
  }

  bool _shouldReinitialize(AnimatedCheckbox oldWidget) {
    return oldWidget.draw != widget.draw ||
        oldWidget.duration != widget.duration;
  }

  void _initializeAnimation() {
    _controller?.dispose();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));

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
    final pathBuilder = CheckmarkPathBuilder(widget.width);
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
            ),
          );
        },
      ),
    );
  }
}
