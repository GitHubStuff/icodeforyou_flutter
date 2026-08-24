// packages/prism_bubble_widget/lib/src/dynamic_prism_bubble.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:prism_bubble_widget/src/bubble_fluid_dynamic_enum.dart'
    show BubbleFluidDynamicEnum;
import 'package:prism_bubble_widget/src/prism_bubble_widget.dart'
    show PrismBubbleWidget;

part 'calculate_fluid_dynamics.dart';

/// An organically animated wrapper around [PrismBubbleWidget] that computes
/// dynamic fluid motion curves in real time.
///
/// Driven by a continuous animation clock, it resolves chromatic diffusion
/// and phase angles using the assigned [dynamicPreset] mathematical profile.
class DynamicPrismBubble extends StatefulWidget {
  /// Creates a dynamic prism bubble driven by organic fluid motion curves.
  ///
  /// The [width] and [height] arguments specify the rendered dimensions.
  const DynamicPrismBubble({
    required this.width,
    required this.height,
    super.key,
    this.child,
    this.dynamicPreset = BubbleFluidDynamicEnum.serene,
    this.tintColor = Colors.white,
    this.arcOpacity = 0.3,
    this.baseSpeed = 1.0,
  });

  /// The horizontal dimension of the bubble canvas.
  final double width;

  /// The vertical dimension of the bubble canvas.
  final double height;

  /// Optional widget displayed beneath the iridescent soap film.
  final Widget? child;

  /// The organic fluid dynamic curve preset applied to movement.
  ///
  /// Defaults to [BubbleFluidDynamicEnum.serene].
  final BubbleFluidDynamicEnum dynamicPreset;

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

  /// Opacity of the accent flourish arcs (0.0 to 1.0).
  ///
  /// Defaults to `0.3`.
  final double arcOpacity;

  /// Global speed multiplier for phase rotation and breathing cycles.
  ///
  /// Defaults to `1.0`.
  final double baseSpeed;

  @override
  State<DynamicPrismBubble> createState() => _DynamicPrismBubbleState();
}

class _DynamicPrismBubbleState extends State<DynamicPrismBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double t = _controller.value * 120.0 * widget.baseSpeed;
        final dynamics = calculateFluidDynamics(
          preset: widget.dynamicPreset,
          t: t,
        );

        return PrismBubbleWidget(
          width: widget.width,
          height: widget.height,
          tintColor: widget.tintColor,
          arcOpacity: widget.arcOpacity,
          diffusion: dynamics.diffusion,
          phaseAngle: dynamics.phaseAngle,
          child: widget.child,
        );
      },
    );
  }
}
