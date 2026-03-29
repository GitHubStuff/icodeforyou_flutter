// animated_widgets/lib/src/animated_checkbox/animated_checkbox.dart
import 'dart:async';

import 'package:animated_widgets/src/animated_checkbox/_animated_checkbox.dart';
import 'package:flutter/material.dart';

part '_animated_checkbox_state.dart';

/// Animates a checkmark being drawn in or dissolved out with a particle effect.
class AnimatedCheckbox extends StatefulWidget {
  /// Creates an [AnimatedCheckbox].
  ///
  /// When [draw] is `true` the checkmark animates in; when `false` it
  /// dissolves out with a particle effect. [onAnimationComplete] is called
  /// with the final [draw] state once the animation finishes.
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

  /// When `true` the checkmark draws in; when `false` it dissolves out.
  final bool draw;

  /// Duration of the full animation.
  final Duration duration;

  /// Normalised start point of the checkmark (0.0–1.0).
  final Offset startOffset;

  /// Normalised mid point of the checkmark apex (0.0–1.0).
  final Offset midOffset;

  /// Normalised finish point of the checkmark (0.0–1.0).
  final Offset finishOffset;

  /// Curve applied to the animation.
  final Curve curve;

  /// Called with the final [draw] state when the animation completes.
  final ValueChanged<bool> onAnimationComplete;

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}
