// packages/sliders/lib/src/horizontal_slider.dart
import 'package:flutter/material.dart';

/// A horizontal slider that reports value changes to its parent.
///
/// This widget is intentionally stateless: the owner holds the value and
/// passes it back in, keeping the slider a pure, easily testable view.
///
/// ## Range
///
/// The contract is lenient: a [value] outside `[min, max]` is accepted and
/// displayed at the nearest bound. The caller's state is left untouched;
/// the first [onChanged] callback after a drag reports an in-range value.
///
/// [divisions] snaps drags to `(max - min) / divisions` increments and
/// limits [onChanged] to those values. Leave it `null` for a continuous
/// slider, which reports on every pointer move during a drag.
///
/// ## Appearance
///
/// The slider always renders with a round thumb on a continuous, tick-free
/// track (see [defaultShapes]) rather than the Material 3 handle-and-gap
/// design, regardless of the ambient [SliderThemeData]. Its horizontal
/// padding is tightened so it sits close to neighbouring widgets.
///
/// Theming is resolved in four layers, each overriding the last:
///
/// 1. the ambient [SliderTheme] (or [ThemeData.sliderTheme]);
/// 2. [defaultShapes];
/// 3. a tint derived from [color], when one is given;
/// 4. [sliderTheme], for anything finer.
///
/// ## Enabled state
///
/// A `null` [onChanged] disables the slider, following the convention of
/// [Slider] itself.
///
/// ## Example
///
/// ```dart
/// HorizontalSlider(
///   value: _volume,
///   min: 0,
///   max: 10,
///   divisions: 10,
///   color: Colors.deepOrange,
///   onChanged: (value) => setState(() => _volume = value),
/// )
/// ```
///
/// See also:
///
/// * [HSliderWithButtons], which flanks this slider with step buttons.
class HorizontalSlider extends StatelessWidget {
  /// Creates a [HorizontalSlider].
  ///
  /// [min] must be less than [max]; this is enforced by an assertion in
  /// debug builds.
  const HorizontalSlider({
    required this.value,
    this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.color,
    this.sliderTheme,
    super.key,
  }) : assert(min < max, 'min must be less than max');

  /// Shape defaults applied on top of the ambient theme.
  ///
  /// A round thumb on a continuous rounded track with no gap and no tick
  /// marks. These replace the Material 3 handle thumb and gapped track
  /// (with its trailing stop indicator), which the ambient theme supplies
  /// by default, and suppress the tick marks Material draws whenever
  /// [divisions] is set.
  ///
  /// The horizontal padding is tightened to the thumb radius. Material's
  /// default reserves room for the full press halo, which leaves a large
  /// gap next to neighbouring widgets.
  ///
  /// A caller can still override any of these through [sliderTheme].
  static final SliderThemeData defaultShapes = SliderThemeData(
    thumbShape: const RoundSliderThumbShape(),
    trackShape: const RoundedRectSliderTrackShape(),
    overlayShape: const RoundSliderOverlayShape(),
    tickMarkShape: SliderTickMarkShape.noTickMark,
    trackGap: 0,
    padding: const EdgeInsets.symmetric(horizontal: 10),
  );

  /// Opacity of the press halo when it is derived from [color].
  static const double _overlayAlpha = 0.15;

  /// The current value of the slider.
  ///
  /// Values outside `[min, max]` are clamped for display only; the
  /// caller's value is never modified.
  final double value;

  /// Called whenever the user moves the slider to a new value.
  ///
  /// `null` disables the slider.
  final ValueChanged<double>? onChanged;

  /// The lowest selectable value. Must be less than [max].
  final double min;

  /// The highest selectable value. Must be greater than [min].
  final double max;

  /// The number of discrete positions a drag snaps to.
  ///
  /// When set, the thumb snaps to multiples of `(max - min) / divisions`
  /// and [onChanged] only reports those values. `null` makes the slider
  /// continuous.
  final int? divisions;

  /// Tint applied to the active and inactive track, the thumb and the
  /// press halo.
  ///
  /// `null` leaves those on their ambient theme colours. A [sliderTheme]
  /// colour wins over this tint for the fields it sets.
  final Color? color;

  /// Theme override for this slider only.
  ///
  /// Merged last, on top of the ambient [SliderThemeData], [defaultShapes]
  /// and the [color] tint, so only the fields you set are overridden.
  final SliderThemeData? sliderTheme;

  /// The colour layer derived from [color].
  ///
  /// Every field is `null` when [color] is `null`, which makes merging it
  /// a no-op.
  SliderThemeData get _tint => SliderThemeData(
    activeTrackColor: color,
    inactiveTrackColor: color,
    thumbColor: color,
    overlayColor: color?.withValues(alpha: _overlayAlpha),
  );

  /// Resolves the four theme layers described in the class documentation.
  SliderThemeData _resolveTheme(BuildContext context) {
    return SliderTheme.of(context)
        .merge(defaultShapes)
        .merge(_tint)
        .merge(sliderTheme ?? const SliderThemeData());
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: _resolveTheme(context),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}

/// Non-null-field merge for [SliderThemeData], which the SDK does not
/// provide.
extension _SliderThemeDataMerge on SliderThemeData {
  /// Returns a copy of `this` with every non-null field of [other] applied.
  ///
  /// `copyWith` treats `null` as "keep the current value", so forwarding
  /// each field of [other] verbatim yields exactly the desired overlay
  /// semantics.
  SliderThemeData merge(SliderThemeData other) {
    return copyWith(
      activeTickMarkColor: other.activeTickMarkColor,
      activeTrackColor: other.activeTrackColor,
      allowedInteraction: other.allowedInteraction,
      disabledActiveTickMarkColor: other.disabledActiveTickMarkColor,
      disabledActiveTrackColor: other.disabledActiveTrackColor,
      disabledInactiveTickMarkColor: other.disabledInactiveTickMarkColor,
      disabledInactiveTrackColor: other.disabledInactiveTrackColor,
      disabledSecondaryActiveTrackColor:
          other.disabledSecondaryActiveTrackColor,
      disabledThumbColor: other.disabledThumbColor,
      inactiveTickMarkColor: other.inactiveTickMarkColor,
      inactiveTrackColor: other.inactiveTrackColor,
      minThumbSeparation: other.minThumbSeparation,
      mouseCursor: other.mouseCursor,
      overlappingShapeStrokeColor: other.overlappingShapeStrokeColor,
      overlayColor: other.overlayColor,
      overlayShape: other.overlayShape,
      padding: other.padding,
      rangeThumbShape: other.rangeThumbShape,
      rangeTickMarkShape: other.rangeTickMarkShape,
      rangeTrackShape: other.rangeTrackShape,
      rangeValueIndicatorShape: other.rangeValueIndicatorShape,
      secondaryActiveTrackColor: other.secondaryActiveTrackColor,
      showValueIndicator: other.showValueIndicator,
      thumbColor: other.thumbColor,
      thumbSelector: other.thumbSelector,
      thumbShape: other.thumbShape,
      thumbSize: other.thumbSize,
      tickMarkShape: other.tickMarkShape,
      trackGap: other.trackGap,
      trackHeight: other.trackHeight,
      trackShape: other.trackShape,
      valueIndicatorColor: other.valueIndicatorColor,
      valueIndicatorShape: other.valueIndicatorShape,
      valueIndicatorStrokeColor: other.valueIndicatorStrokeColor,
      valueIndicatorTextStyle: other.valueIndicatorTextStyle,
    );
  }
}
