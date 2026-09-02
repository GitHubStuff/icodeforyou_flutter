// packages/prism_bubble_widget/lib/src/prism_bubble_widget.dart
import 'package:flutter/material.dart';
import 'package:prism_bubble_widget/src/bubble_shader_manager.dart'
    show BubbleShaderManager;
import 'package:prism_bubble_widget/src/bubble_shader_painter.dart'
    show BubbleShaderPainter;

/// A widget that renders a soap-bubble iridescent chromatic visual effect
/// using dedicated fragment shaders for dark and light surfaces.
class PrismBubbleWidget extends StatefulWidget {
  /// Creates a prism bubble widget.
  const PrismBubbleWidget({
    required this.width,
    required this.height,
    super.key,
    this.child,
    this.isLight = false,
    this.tintColor = Colors.white,
    this.arcOpacity = 0.3,
    this.diffusion = 0.0,
    this.phaseAngle = 0.0,
  });

  /// Creates a [PrismBubbleWidget] explicitly tailored for dark backgrounds.
  factory PrismBubbleWidget.dark({
    required double width,
    required double height,
    Key? key,
    Widget? child,
    Color tintColor = Colors.white,
    double arcOpacity = 0.3,
    double diffusion = 0.0,
    double phaseAngle = 0.0,
  }) {
    return PrismBubbleWidget(
      key: key,
      width: width,
      height: height,
      isLight: false,
      tintColor: tintColor,
      arcOpacity: arcOpacity,
      diffusion: diffusion,
      phaseAngle: phaseAngle,
      child: child,
    );
  }

  /// Creates a [PrismBubbleWidget] explicitly tailored for light backgrounds.
  factory PrismBubbleWidget.light({
    required double width,
    required double height,
    Key? key,
    Widget? child,
    Color tintColor = const Color(0xFFE2E8F0),
    double arcOpacity = 0.2,
    double diffusion = 0.25,
    double phaseAngle = 0.0,
  }) {
    return PrismBubbleWidget(
      key: key,
      width: width,
      height: height,
      isLight: true,
      tintColor: tintColor,
      arcOpacity: arcOpacity,
      diffusion: diffusion,
      phaseAngle: phaseAngle,
      child: child,
    );
  }

  /// The total width of the rendered bubble canvas.
  final double width;

  /// The total height of the rendered bubble canvas.
  final double height;

  /// An optional widget to be rendered beneath the chromatic overlay.
  final Widget? child;

  /// Whether to render using the light-background optical shader.
  final bool isLight;

  /// The tint color applied to the rim boundary, flourish arcs, and
  /// spectral blend.
  final Color tintColor;

  /// Opacity multiplier for the bubble's reflective arcs and highlights.
  final double arcOpacity;

  /// The chromatic diffusion expansion factor.
  final double diffusion;

  /// The rotation phase angle in radians for liquid animation shifts.
  final double phaseAngle;

  @override
  State<PrismBubbleWidget> createState() => _PrismBubbleWidgetState();
}

class _PrismBubbleWidgetState extends State<PrismBubbleWidget> {
  final BubbleShaderManager _manager = BubbleShaderManager.instance;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _manager.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Tooltip(
              message: snapshot.error.toString(),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
              ),
            ),
          );
        }

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.child != null) widget.child!,
              CustomPaint(
                painter: BubbleShaderPainter(
                  manager: _manager,
                  isLight: widget.isLight,
                  tintColor: widget.tintColor,
                  arcOpacity: widget.arcOpacity,
                  diffusion: widget.diffusion,
                  phaseAngle: widget.phaseAngle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
