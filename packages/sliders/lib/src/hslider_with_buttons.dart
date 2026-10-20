// packages/sliders/lib/src/hslider_with_buttons.dart
import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:sliders/sliders.dart'
    show Constants, HorizontalSlider, SliderButton;

/// A [HorizontalSlider] flanked by a decrease and an increase
/// [SliderButton].
///
/// The buttons move the value by a fixed [step]; the slider is dragged
/// freely, or snapped to [divisions] when they are set. Both paths report
/// through the same [onChanged] callback, so the parent never needs to
/// know which control the user touched.
///
/// ## Value ownership
///
/// The widget is *uncontrolled*: it owns its value. [initialValue] seeds
/// it once, when the state is created, and is ignored thereafter. A
/// parent that must reset the value remounts the widget with a new [Key].
///
/// If the parent later changes [min] or [max] so that the current value
/// falls outside the new range, the value is clamped silently; [onChanged]
/// is not called because the parent, not the user, caused the change.
///
/// ## Enabled and disabled states
///
/// * `onChanged == null` disables everything: the slider and both
///   buttons.
/// * While enabled, the decrease button is disabled when the value is at
///   [min], and the increase button when it is at [max]. The slider
///   itself stays interactive at both bounds.
///
/// ## Stepping
///
/// [step] applies to the buttons only. A tap moves the value by exactly
/// [step], clamped to `[min, max]`, regardless of [divisions]. A coarse
/// drag grid and a fine button nudge are both common, so the two are
/// deliberately decoupled and the caller decides.
///
/// ## Example
///
/// A volume control from 0 to 10 that nudges by one per tap:
///
/// ```dart
/// HSliderWithButtons(
///   min: 0,
///   max: 10,
///   step: 1,
///   divisions: 10,
///   initialValue: 5,
///   color: Colors.deepOrange,
///   onChanged: (value) => debugPrint('volume: $value'),
/// )
/// ```
///
/// See also:
///
/// * [HorizontalSlider], the slider in the middle.
/// * [SliderButton], the buttons on either side.
/// * [HapticIntensity], the feedback the buttons give on tap.
class HSliderWithButtons extends StatefulWidget {
  /// Creates an [HSliderWithButtons].
  ///
  /// [min] must be less than [max], and [step] must be positive; both are
  /// enforced by assertions in debug builds.
  const HSliderWithButtons({
    required this.step,
    this.initialValue,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChanged,
    this.color,
    this.haptic = .light,
    this.sliderThemeData,
    super.key,
  }) : assert(min < max, 'min must be less than max'),
       assert(step > 0, 'step must be positive');

  /// The value the widget starts at.
  ///
  /// Read once, when the state is created, and clamped to `[min, max]`.
  /// `null` starts at the midpoint of the range. Later changes to this
  /// field are ignored; see the class documentation for why.
  final double? initialValue;

  /// How far one button tap moves the value.
  ///
  /// Must be positive. The result of a tap is clamped to `[min, max]`,
  /// so a step that would overshoot lands exactly on the bound.
  final double step;

  /// The lowest value the slider can hold.
  ///
  /// The decrease button is disabled while the value is here.
  final double min;

  /// The highest value the slider can hold.
  ///
  /// The increase button is disabled while the value is here.
  final double max;

  /// The number of discrete positions a drag snaps to.
  ///
  /// Forwarded to [HorizontalSlider.divisions]. `null` makes the slider
  /// continuous. Has no effect on the buttons, which always move by
  /// [step].
  final int? divisions;

  /// Called with the new value after every drag movement and every
  /// button tap.
  ///
  /// `null` disables the slider and both buttons. A continuous slider
  /// reports on every pointer move during a drag; set [divisions] if
  /// you only want to hear about discrete changes.
  final ValueChanged<double>? onChanged;

  /// Tint applied to both button icons and to the slider's track, thumb
  /// and overlay.
  ///
  /// `null` leaves every part on its ambient theme colour.
  final Color? color;

  /// The haptic feedback each button gives when tapped.
  ///
  /// Forwarded to [SliderButton.haptic]. Defaults to a light impact;
  /// use [HapticIntensity.none] to silence it.
  final HapticIntensity haptic;

  /// Theme override for the slider only.
  ///
  /// Forwarded to [HorizontalSlider.sliderTheme], where it is merged on
  /// top of the ambient theme and the slider's own defaults. Set only
  /// the fields you want to change.
  final SliderThemeData? sliderThemeData;

  @override
  State<HSliderWithButtons> createState() => _HSliderWithButtonsState();
}

class _HSliderWithButtonsState extends State<HSliderWithButtons> {
  /// The value the slider shows and the buttons step from.
  late double currentValue = _clamp(widget.initialValue ?? midpoint);

  /// The centre of `[min, max]`; the default starting value.
  double get midpoint => widget.min + (widget.max - widget.min) / 2;

  /// Whether the parent is listening. `false` disables every control.
  bool get isEnabled => widget.onChanged != null;

  bool get _canDecrease => isEnabled && currentValue > widget.min;

  bool get _canIncrease => isEnabled && currentValue < widget.max;

  double _clamp(double value) => value.clamp(widget.min, widget.max);

  @override
  void didUpdateWidget(HSliderWithButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The parent may have moved the range out from under the value. Keep
    // the slider's `[min, max]` invariant without notifying: the parent
    // caused this change, not the user.
    currentValue = _clamp(currentValue);
  }

  /// Applies [newValue], clamped to the range, and notifies the parent.
  void _update(double newValue) {
    setState(() => currentValue = _clamp(newValue));
    widget.onChanged?.call(currentValue);
  }

  void _decrease() => _update(currentValue - widget.step);

  void _increase() => _update(currentValue + widget.step);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        assert(
          constraints.maxWidth >= Constants.sliderWidth,
          '\nHSliderWithButtons requires a minimum width of '
          ' ${Constants.sliderWidth} dp to avoid track/button overflow. '
          'Currently received maxWidth: ${constraints.maxWidth}.\n',
        );

        return _content(context);
      },
    );
  }

  Widget _content(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SliderButton(
        icon: Icon(Icons.remove_circle_outline, color: widget.color),
        hint: 'Decrease',
        haptic: widget.haptic,
        onTap: _canDecrease ? _decrease : null,
      ),
      HorizontalSlider(
        value: currentValue,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        color: widget.color,
        sliderTheme: widget.sliderThemeData,
        onChanged: isEnabled ? _update : null,
      ),
      SliderButton(
        icon: Icon(Icons.add_circle_outline, color: widget.color),
        hint: 'Increase',
        haptic: widget.haptic,
        onTap: _canIncrease ? _increase : null,
      ),
    ],
  );
}
