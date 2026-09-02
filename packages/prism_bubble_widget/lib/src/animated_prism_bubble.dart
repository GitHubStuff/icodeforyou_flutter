// packages/prism_bubble_widget/lib/src/animated_prism_bubble.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:prism_bubble_widget/src/bubble_animation_enum.dart'
    show BubbleAnimationEnum;
import 'package:prism_bubble_widget/src/prism_bubble_widget.dart'
    show PrismBubbleWidget;

/// A wrapper widget that drives continuous animations over a
/// [PrismBubbleWidget].
///
/// Supports breathing (diffusion pulsing), liquid rotation (continuous phase
/// shifting), or both combined simultaneously according to the configured
/// [mode].
class AnimatedPrismBubble extends StatefulWidget {
  /// Creates an animated prism bubble wrapper.
  ///
  /// The [width] and [height] arguments must be provided.
  const AnimatedPrismBubble({
    required this.width,
    required this.height,
    super.key,
    this.child,
    this.mode = BubbleAnimationEnum.combined,
    this.tintColor = Colors.white,
    this.arcOpacity = 0.3,
    this.breathingDuration = const Duration(milliseconds: 2400),
    this.rotationDuration = const Duration(milliseconds: 6000),
    this.minDiffusion = 0.0,
    this.maxDiffusion = 1.0,
  });

  /// The total width of the rendered bubble.
  final double width;

  /// The total height of the rendered bubble.
  final double height;

  /// An optional widget to be placed inside or centered within the bubble.
  final Widget? child;

  /// The active animation style driving the bubble effects.
  ///
  /// Defaults to [BubbleAnimationEnum.combined].
  final BubbleAnimationEnum mode;

  /// The tint color applied to the rim boundary, flourish arcs, and
  /// spectral blend.
  ///
  /// * For dark backgrounds: Use [Colors.white] (default) or bright pastels
  ///   to produce luminous highlights.
  /// * For light or white backgrounds: Use a muted, semi-transparent tone
  ///   (such as `const Color(0x33000000)` or a subtle slate tint) to provide
  ///   perimeter contrast without washing out.
  ///
  /// The alpha channel of [tintColor] modulates how strongly the tint blends
  /// into the base pastel spectrum.
  final Color tintColor;

  /// Opacity multiplier for the bubble's reflective arcs and highlights.
  ///
  /// Defaults to `0.3`.
  final double arcOpacity;

  /// The duration of a single half-cycle of the breathing expansion or
  /// contraction.
  ///
  /// Defaults to `2400` milliseconds.
  final Duration breathingDuration;

  /// The duration for a complete 360-degree liquid phase rotation cycle.
  ///
  /// Defaults to `6000` milliseconds.
  final Duration rotationDuration;

  /// The minimum diffusion level applied at the bottom of a breathing cycle.
  ///
  /// Defaults to `0.0`.
  final double minDiffusion;

  /// The maximum diffusion level applied at the peak of a breathing cycle.
  ///
  /// Defaults to `1.0`.
  final double maxDiffusion;

  @override
  State<AnimatedPrismBubble> createState() => _AnimatedPrismBubbleState();
}

class _AnimatedPrismBubbleState extends State<AnimatedPrismBubble>
    with TickerProviderStateMixin {
  AnimationController? _breathingController;
  AnimationController? _rotationController;

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    if (widget.mode == BubbleAnimationEnum.breathing ||
        widget.mode == BubbleAnimationEnum.combined) {
      _breathingController = AnimationController(
        vsync: this,
        duration: widget.breathingDuration,
      )..repeat(reverse: true);
    }

    if (widget.mode == BubbleAnimationEnum.liquidRotation ||
        widget.mode == BubbleAnimationEnum.combined) {
      _rotationController = AnimationController(
        vsync: this,
        duration: widget.rotationDuration,
      )..repeat();
    }
  }

  @override
  void dispose() {
    _breathingController?.dispose();
    _rotationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Listenable animationListenable = Listenable.merge([
      if (_breathingController != null) _breathingController!,
      if (_rotationController != null) _rotationController!,
    ]);

    return AnimatedBuilder(
      animation: animationListenable,
      builder: (context, _) {
        final double breathingT = _breathingController?.value ?? 0.0;
        final double currentDiffusion =
            widget.minDiffusion +
            (widget.maxDiffusion - widget.minDiffusion) * breathingT;

        final double rotationT = _rotationController?.value ?? 0.0;
        final double currentPhase = rotationT * 2.0 * math.pi;

        return PrismBubbleWidget(
          width: widget.width,
          height: widget.height,
          tintColor: widget.tintColor,
          arcOpacity: widget.arcOpacity,
          diffusion: currentDiffusion,
          phaseAngle: currentPhase,
          child: widget.child,
        );
      },
    );
  }
}
