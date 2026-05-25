// lib/src/slider_stepper.dart
// ignore_for_file: always_use_package_imports, comment_references

import 'package:flutter/material.dart';
import 'package:slider_directional/slider_directional.dart';
import 'package:widget_themes/widget_themes.dart' show CrossFadeTheme;

import 'src/step_button.dart';

/// A stepper that wraps a [SliderDirectional] with a minus button on the
/// `min` side and a plus button on the `max` side, oriented to match
/// [direction].
///
/// Tap a button to step once; press-and-hold to auto-repeat. The slider
/// itself remains fully draggable.
class SliderStepper extends StatelessWidget {
  /// Creates a [SliderStepper].
  const SliderStepper({
    required this.controller,
    required this.min,
    required this.max,
    required this.step,
    super.key,
    this.direction = SliderDirection.left,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.buttonColor,
    this.buttonIconColor,
    this.buttonSize,
    this.gap = 8,
    this.minusIcon = Icons.remove,
    this.plusIcon = Icons.add,
  });

  /// Drives the underlying [Directional] slider.
  final DirectionalController controller;

  /// Axis and which end represents the minimum value.
  final SliderDirection direction;

  /// Inclusive minimum value.
  final double min;

  /// Inclusive maximum value.
  final double max;

  /// Increment applied on each tap / repeat tick.
  final double step;

  /// Called with the new value whenever the slider value changes.
  final ValueChanged<double>? onChanged;

  /// Active (filled) track colour, forwarded to [Directional].
  final Color? activeColor;

  /// Inactive (empty) track colour, forwarded to [Directional].
  final Color? inactiveColor;

  /// Thumb colour, forwarded to [Directional].
  final Color? thumbColor;

  /// Background colour of the `(−)` / `(+)` buttons.
  final Color? buttonColor;

  /// Icon colour of the `(−)` / `(+)` buttons.
  final Color? buttonIconColor;

  /// Diameter of the `(−)` / `(+)` buttons.
  final double? buttonSize;

  /// Spacing between each button and the slider.
  final double gap;

  /// Icon shown on the decrement button.
  final IconData minusIcon;

  /// Icon shown on the plus button.
  final IconData plusIcon;

  void _stepBy(double delta) {
    final next = (controller.value + delta).clamp(min, max);
    // Defensive: buttons are disabled at the exact clamp point, so this never
    // fires through the widget — kept as a precondition for direct callers.
    if (next == controller.value) return; // coverage:ignore-line
    controller.value = next;
    onChanged?.call(next);
  }

  void _decrement() => _stepBy(-step);
  void _increment() => _stepBy(step);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: controller,
      builder: (context, value, _) {
        final canDecrement = value > min;
        final canIncrement = value < max;

        final minusButton = StepButton(
          icon: minusIcon,
          onPressed: canDecrement ? _decrement : null,
          buttonSize: buttonSize ?? CrossFadeTheme.of(context).buttonSize,
          color: buttonColor,
          iconColor: buttonIconColor,
          tooltip: 'Decrease',
        );

        final plusButton = StepButton(
          icon: plusIcon,
          onPressed: canIncrement ? _increment : null,
          buttonSize: buttonSize ?? CrossFadeTheme.of(context).buttonSize,
          color: buttonColor,
          iconColor: buttonIconColor,
          tooltip: 'Increase',
        );

        final slider = Directional(
          controller: controller,
          direction: direction,
          min: min,
          max: max,
          step: step,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          thumbColor: thumbColor,
          onChanged: onChanged,
        );

        final gapBox = SizedBox(width: gap, height: gap);

        // Lay out so the `(−)` button always sits at the `min` end of the
        // slider and `(+)` at the `max` end, regardless of axis polarity.
        return switch (direction) {
          SliderDirection.left => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              minusButton,
              gapBox,
              Expanded(child: slider),
              gapBox,
              plusButton,
            ],
          ),
          SliderDirection.right => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              plusButton,
              gapBox,
              Expanded(child: slider),
              gapBox,
              minusButton,
            ],
          ),
          SliderDirection.top => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              minusButton,
              gapBox,
              Expanded(child: slider),
              gapBox,
              plusButton,
            ],
          ),
          SliderDirection.bottom => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              plusButton,
              gapBox,
              Expanded(child: slider),
              gapBox,
              minusButton,
            ],
          ),
        };
      },
    );
  }
}
