// packages/custom_widgets/lib/src/directional_slider/buttons/directional_slider_and_buttons.dart

import 'package:custom_widgets/custom_widgets.dart' show StepperTheme;
import 'package:custom_widgets/src/directional_slider/slider/directional_controller.dart'
    show DirectionalController;
import 'package:custom_widgets/src/directional_slider/slider/directional_slider.dart'
    show DirectionalSlider;
import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';

import 'step_button.dart';

/// {@template custom_widgets.directional_slider_and_buttons}
/// A stepper that wraps a [DirectionalSlider] with a `(−)` button on the
/// `min` side and a `(+)` button on the `max` side.
///
/// Tap a button to step once by [step]; press-and-hold to auto-repeat. The
/// slider itself remains fully draggable, and every change — button, repeat
/// tick, or drag — reports through [onChanged].
/// {@endtemplate}
///
/// ## Layout invariant
///
/// The `(−)` button always sits at the `min` end of the slider and `(+)` at
/// the `max` end, whatever the polarity. [minValueFirst] flips which end
/// `min` is: `true` (the default) puts `min` — and therefore `(−)` — first
/// in the row; `false` mirrors the whole arrangement, buttons included.
/// The buttons are reordered *and* the slider's endpoints are swapped
/// together, so the two can never disagree.
///
/// ## Bounds
///
/// Values are clamped to `[min, max]`. At a bound, the button that would
/// step past it is disabled ([StepButton] renders it at reduced opacity and
/// ignores presses); the opposite button and the slider stay live. Steps
/// that would not change the value fire no [onChanged] and no haptic.
///
/// ## Theming
///
/// [buttonSize] falls back to [StepperTheme.buttonSize] when null,
/// resolved via [StepperTheme.of] — register a [StepperTheme] on
/// [ThemeData.extensions] to size every stepper in the app at once. Colours
/// left null defer to [DirectionalSlider] and [StepButton] defaults, which
/// derive from the ambient [ColorScheme].
///
/// ## Rebuild scope
///
/// The widget listens to [controller] through a [ValueListenableBuilder],
/// so value changes rebuild only this stepper's row — enabled state tracks
/// the live value without the host widget rebuilding.
///
/// See also:
///
///  * [StepButton], the tap-and-hold repeat button used at each end.
///  * [DirectionalSlider], the slider between the buttons.
///  * [DirectionalController], the [ValueNotifier] driving both.
class DirectionalSliderAndButtons extends StatelessWidget {
  /// Creates a [DirectionalSliderAndButtons].
  ///
  /// [controller], [min], [max], and [step] are required; [min] must not
  /// exceed [max]. Everything else is optional and cosmetic or behavioral
  /// sugar.
  ///
  /// {@macro custom_widgets.directional_slider_and_buttons.min_value_first}
  ///
  /// {@macro custom_widgets.directional_slider_and_buttons.button_size}
  ///
  /// {@macro custom_widgets.directional_slider_and_buttons.haptics}
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

  /// {@template custom_widgets.directional_slider_and_buttons.min_value_first}
  /// Whether the `min` end of the range comes first in the row.
  ///
  /// When `true` (the default), `min` — and with it the `(−)` button — sits
  /// at the leading edge and values grow toward the trailing edge. When
  /// `false`, the entire arrangement is mirrored: slider endpoints swap and
  /// the buttons reorder with them, preserving the invariant that `(−)`
  /// always sits at the `min` end.
  /// {@endtemplate}
  final bool minValueFirst;

  /// The [ValueNotifier] driving the underlying [DirectionalSlider].
  ///
  /// The stepper reads the live value from it (to compute button enablement)
  /// and writes stepped values back to it. Owned by the caller — this widget
  /// never disposes it.
  final DirectionalController controller;

  /// Orientation of the slider track, forwarded to
  /// [DirectionalSlider.rotation].
  ///
  /// Defaults to [Axis.horizontal]. Which end represents `min` is governed
  /// separately by [minValueFirst], not by this.
  final Axis axis;

  /// Inclusive minimum value. Stepping and clamping never go below it.
  final double min;

  /// Inclusive maximum value. Stepping and clamping never go above it.
  final double max;

  /// Increment applied on each button tap and each hold-to-repeat tick.
  final double step;

  /// Called with the new value whenever it actually changes — via button,
  /// repeat tick, or slider drag.
  ///
  /// Not called for steps clamped into a no-op at a bound.
  final ValueChanged<double>? onChanged;

  /// Active (filled) track colour, forwarded to [DirectionalSlider].
  ///
  /// When null, [DirectionalSlider]'s theme-derived default applies.
  final Color? activeColor;

  /// Inactive (empty) track colour, forwarded to [DirectionalSlider].
  ///
  /// When null, [DirectionalSlider]'s theme-derived default applies.
  final Color? inactiveColor;

  /// Thumb colour, forwarded to [DirectionalSlider].
  ///
  /// When null, [DirectionalSlider]'s theme-derived default applies.
  final Color? thumbColor;

  /// Background colour of the `(−)` / `(+)` buttons.
  ///
  /// When null, [StepButton] falls back to [ColorScheme.primaryContainer].
  final Color? buttonColor;

  /// Icon colour of the `(−)` / `(+)` buttons.
  ///
  /// When null, [StepButton] falls back to [ColorScheme.onPrimaryContainer].
  final Color? buttonIconColor;

  /// {@template custom_widgets.directional_slider_and_buttons.button_size}
  /// Diameter of the `(−)` / `(+)` buttons, in logical pixels.
  ///
  /// When null, resolves from [StepperTheme.buttonSize] via
  /// [StepperTheme.of].
  /// {@endtemplate}
  final double? buttonSize;

  /// Spacing between each button and the slider, in logical pixels.
  ///
  /// Applied symmetrically on both sides. Defaults to 8.
  final double gap;

  /// Icon shown on the decrement button. Defaults to [Icons.remove].
  final IconData minusIcon;

  /// Icon shown on the increment button. Defaults to [Icons.add].
  final IconData plusIcon;

  /// {@template custom_widgets.directional_slider_and_buttons.haptics}
  /// Haptic feedback intensity, applied uniformly to button steps, repeat
  /// ticks, and slider drags.
  ///
  /// Defaults to [HapticIntensity.selection], the semantic for incremental
  /// value changes. Pass [HapticIntensity.none] to silence feedback across
  /// the whole stepper — buttons and slider alike.
  /// {@endtemplate}
  final HapticIntensity haptics;

  /// Steps the controller by [delta], clamped to `[min, max]`.
  ///
  /// No-ops (steps clamped back to the current value) emit nothing: the
  /// controller is not touched and [onChanged] is not called, so bound
  /// mashing produces no listener churn and no haptics.
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
          buttonSize: buttonSize ?? StepperTheme.of(context).buttonSize,
          color: buttonColor,
          iconColor: buttonIconColor,
          tooltip: 'Decrease',
          haptic: haptics,
        );

        final plusButton = StepButton(
          icon: plusIcon,
          onPressed: canIncrement ? _increment : null,
          buttonSize: buttonSize ?? StepperTheme.of(context).buttonSize,
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
