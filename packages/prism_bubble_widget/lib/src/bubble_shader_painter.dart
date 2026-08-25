// packages/prism_bubble_widget/lib/src/bubble_shader_painter.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:prism_bubble_widget/src/bubble_shader_manager.dart'
    show BubbleShaderManager;

/// Custom painter that binds uniform variables to the target fragment shader.
class BubbleShaderPainter extends CustomPainter {
  /// Creates an instance of [BubbleShaderPainter].
  BubbleShaderPainter({
    required this.manager,
    this.isLight = false,
    this.tintColor = Colors.white,
    this.arcOpacity = 0.3,
    this.diffusion = 0.0,
    this.phaseAngle = 0.0,
  }) : super(repaint: null);

  /// The manager responsible for loading and supplying the fragment shaders.
  final BubbleShaderManager manager;

  /// Whether to use the light theme variant of the fragment shader.
  final bool isLight;

  /// The tint color applied to the bubble shader uniforms.
  final Color tintColor;

  /// The opacity of the highlight arc, clamped between `0.0` and `1.0`.
  final double arcOpacity;

  /// The diffusion factor of the shader, clamped between `0.0` and `1.0`.
  final double diffusion;

  /// The phase angle in radians used for animating shader effects.
  final double phaseAngle;

  @override
  void paint(Canvas canvas, Size size) {
    if (!manager.isLoaded) return;

    final ui.FragmentShader shader =
        isLight ? manager.lightShader : manager.darkShader
          ..setFloat(BubbleShaderManager.uSizeXPos, size.width)
          ..setFloat(BubbleShaderManager.uSizeYPos, size.height)
          ..setFloat(BubbleShaderManager.uTintRPos, tintColor.r)
          ..setFloat(BubbleShaderManager.uTintGPos, tintColor.g)
          ..setFloat(BubbleShaderManager.uTintBPos, tintColor.b)
          ..setFloat(BubbleShaderManager.uTintAPPos, tintColor.a)
          ..setFloat(
            BubbleShaderManager.uArcOpacityPos,
            arcOpacity.clamp(0.0, 1.0),
          )
          ..setFloat(
            BubbleShaderManager.uDiffusionPos,
            diffusion.clamp(0.0, 1.0),
          )
          ..setFloat(BubbleShaderManager.uPhaseAnglePos, phaseAngle);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant BubbleShaderPainter oldDelegate) =>
      oldDelegate.isLight != isLight ||
      oldDelegate.tintColor != tintColor ||
      oldDelegate.arcOpacity != arcOpacity ||
      oldDelegate.diffusion != diffusion ||
      oldDelegate.phaseAngle != phaseAngle;
}
