// lib/src/animated_checkbox/_animated_checkbox_state.dart

part of '../animated_checkbox.dart';

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

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldReinitialize(oldWidget)) {
      _initializeAnimation();
    } else if (oldWidget.duration != widget.duration) {
      _updateDuration();
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

  bool _shouldReinitialize(AnimatedCheckbox oldWidget) {
    return oldWidget.draw != widget.draw || oldWidget.curve != widget.curve;
  }

  void _updateDuration() {
    if (!_isAnimating) {
      _controller?.duration = widget.duration;
    }
  }

  void _initializeAnimation() {
    _controller?.dispose();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller!, curve: widget.curve),
    );

    _controller!.addStatusListener(_handleAnimationStatus);
    _startAnimation();
  }

  void _startAnimation() {
    if (_isAnimating) return;
    _isAnimating = true;
    if (!widget.draw) {
      _generateDissolveParticles();
    }
    unawaited(_controller!.forward(from: 0));
  }

  void _generateDissolveParticles() {
    final path = CheckmarkPathBuilder(
      width: widget.width,
      startOffset: widget.startOffset,
      midOffset: widget.midOffset,
      finishOffset: widget.finishOffset,
    ).buildCheckmarkPath();
    _particles = ParticleGenerator.generateFromPath(path);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _isAnimating = false;
      widget.onAnimationComplete(widget.draw);
    }
  }

  void _validateOffsets() {
    _assertOffset(widget.startOffset, 'startOffset');
    _assertOffset(widget.midOffset, 'midOffset');
    _assertOffset(widget.finishOffset, 'finishOffset');
  }

  void _assertOffset(Offset offset, String name) {
    assert(
      offset.dx >= 0.0 && offset.dx <= 1.0,
      '$name.dx must be 0.0–1.0, got: ${offset.dx}',
    );
    assert(
      offset.dy >= 0.0 && offset.dy <= 1.0,
      '$name.dy must be 0.0–1.0, got: ${offset.dy}',
    );
  }
}
