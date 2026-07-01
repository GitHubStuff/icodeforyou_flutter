// packages/custom_widgets/lib/src/directional_slider/src/buttons/directional_slider_and_buttons.dart
// ignore_for_file: always_use_package_imports, comment_references

import 'package:custom_widgets/src/directional_slider/slider/directional_controller.dart'
    show DirectionalController;
import 'package:custom_widgets/src/directional_slider/slider/directional_slider.dart'
    show DirectionalSlider;

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:theme_manager/theme_manager.dart' show CrossFadeTheme;

import 'step_button.dart';

/// A stepper that wraps a [SliderDirectional] with a minus button on the
/// `min` side and a plus button on the `max` side, oriented to match
/// [direction].
///
/// Tap a button to step once; press-and-hold to auto-repeat. The slider
/// itself remains fully draggable.
class DirectionalSliderAndButtons extends StatelessWidget {
  /// Creates a [DirectionalSliderAndButtons].
  const DirectionalSliderAndButtons({
    required this.controller,
    required this.min,
    required this.max,
    required this.step,
    super.key,
    this.axis = Axis.horizontal,
    this.minValueFirst = true,
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
    this.haptics = HapticIntensity.selection,
  });

  final bool minValueFirst;

  /// Drives the underlying [DirectionalSlider] slider.
  final DirectionalController controller;

  /// Axis and which end represents the minimum value.
  final Axis axis;

  /// Inclusive minimum value.
  final double min;

  /// Inclusive maximum value.
  final double max;

  /// Increment applied on each tap / repeat tick.
  final double step;

  /// Called with the new value whenever the slider value changes.
  final ValueChanged<double>? onChanged;

  /// Active (filled) track colour, forwarded to [DirectionalSlider].
  final Color? activeColor;

  /// Inactive (empty) track colour, forwarded to [DirectionalSlider].
  final Color? inactiveColor;

  /// Thumb colour, forwarded to [DirectionalSlider].
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

  final HapticIntensity haptics;

  void _stepBy(double delta) {
    final next = (controller.value + delta).clamp(min, max);
    if (next == controller.value) return;
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
          haptic: haptics,
        );

        final plusButton = StepButton(
          icon: plusIcon,
          onPressed: canIncrement ? _increment : null,
          buttonSize: buttonSize ?? CrossFadeTheme.of(context).buttonSize,
          color: buttonColor,
          iconColor: buttonIconColor,
          tooltip: 'Increase',
          haptic: haptics,
        );

        final slider = DirectionalSlider(
          controller: controller,
          rotation: axis,
          min: minValueFirst ? min : max,
          max: minValueFirst ? max : min,
          step: step,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          thumbColor: thumbColor,
          onChanged: onChanged,
          hapticIntensity: haptics,
          enableHapticFeedback: haptics != HapticIntensity.none,
        );

        final gapBox = SizedBox(width: gap, height: gap);

        // Lay out so the `(−)` button always sits at the `min` end of the
        // slider and `(+)` at the `max` end, regardless of axis polarity.
        final firstButton = minValueFirst ? minusButton : plusButton;
        final secondButton = minValueFirst ? plusButton : minusButton;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            firstButton,
            gapBox,
            Expanded(child: slider),
            gapBox,
            secondButton,
          ],
        );
      },
    );
  }
}
