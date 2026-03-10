// lib/src/step_slider.dart
import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '_haptic_feedback_type.dart';
part '_slider_cubit.dart';
part '_step_button.dart';
part '_step_slider_body.dart';

/// A slider widget with increment/decrement buttons and optional haptic feedback.
///
/// Each [StepSlider] instance manages its own state via an internal [Cubit],
/// ensuring isolated rebuilds and no parent widget interference.
class StepSlider extends StatelessWidget {
  /// Creates a [StepSlider].
  const StepSlider({
    super.key,
    this.initialValue = 0.0,
    this.min = 0.0,
    this.max = 100.0,
    this.step = 1.0,
    this.divisions,
    this.label,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.buttonColor,
    this.buttonIconColor,
    this.buttonSize = 36.0,
    this.enableHapticFeedback = false,
    this.hapticFeedbackType = HapticFeedbackType.light,
  });

  /// The initial value of the slider.
  final double initialValue;

  /// The minimum value the slider can have.
  final double min;

  /// The maximum value the slider can have.
  final double max;

  /// The amount to increment/decrement when buttons are pressed.
  final double step;

  /// The number of discrete divisions for the slider.
  final int? divisions;

  /// The label to display above the thumb.
  final String? label;

  /// Called when the slider value changes.
  final ValueChanged<double>? onChanged;

  /// The color of the active portion of the track.
  final Color? activeColor;

  /// The color of the inactive portion of the track.
  final Color? inactiveColor;

  /// The color of the slider thumb.
  final Color? thumbColor;

  /// The background color of the step buttons.
  final Color? buttonColor;

  /// The icon color of the step buttons.
  final Color? buttonIconColor;

  /// The size of the step buttons.
  final double buttonSize;

  /// Whether to enable haptic feedback on button press.
  final bool enableHapticFeedback;

  /// The type of haptic feedback to use.
  final HapticFeedbackType hapticFeedbackType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _SliderCubit(initial: initialValue),
      child: _StepSliderBody(
        min: min,
        max: max,
        step: step,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        thumbColor: thumbColor,
        buttonColor: buttonColor,
        buttonIconColor: buttonIconColor,
        buttonSize: buttonSize,
        enableHapticFeedback: enableHapticFeedback,
        hapticFeedbackType: hapticFeedbackType,
      ),
    );
  }
}
