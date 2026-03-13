// lib/src/animated_checkbox/animated_checkbox.dart

import 'dart:async';

import 'package:animated_widgets/src/animated_checkbox/_checkmark_painter.dart';
import 'package:animated_widgets/src/animated_checkbox/_checkmark_path_builder.dart';
import 'package:animated_widgets/src/animated_checkbox/_dissolve_particle.dart';
import 'package:animated_widgets/src/animated_checkbox/_particle_generator.dart';
import 'package:flutter/material.dart';

part '_animated_checkbox_state.dart';

/// Animates a checkmark being drawn or dissolved with a particle effect.
class AnimatedCheckbox extends StatefulWidget {
  const AnimatedCheckbox({
    required this.draw,
    required this.onAnimationComplete,
    super.key,
    this.width = 100.0,
    this.background = Colors.transparent,
    this.strokeColor = Colors.purple,
    this.duration = const Duration(milliseconds: 850),
    this.startOffset = const Offset(0.05, 0.52),
    this.midOffset = const Offset(0.45, 0.95),
    this.finishOffset = const Offset(0.95, 0.06),
    this.curve = Curves.easeInOutQuart,
  }) : assert(width >= 5.0, 'Width must be at least 5.0');

  /// Width and height of the widget (minimum 5.0).
  final double width;

  /// Background color of the widget.
  final Color background;

  /// Color of the checkmark stroke.
  final Color strokeColor;

  /// When true the checkmark draws in; when false it dissolves out.
  final bool draw;

  /// Duration of the animation.
  final Duration duration;

  /// Normalized start point of the checkmark (0.0–1.0).
  final Offset startOffset;

  /// Normalized mid point of the checkmark (0.0–1.0).
  final Offset midOffset;

  /// Normalized finish point of the checkmark (0.0–1.0).
  final Offset finishOffset;

  /// Animation curve.
  final Curve curve;

  /// Called with the final [draw] state when the animation completes.
  final ValueChanged<bool> onAnimationComplete;

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}
