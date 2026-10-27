// packages/demo/lib/src/duration/duration_demo.dart

import 'package:caption_switch/caption_switch.dart' show CaptionSwitch;
import 'package:ext_duration/ext_duration.dart' show DurationUnits, ExtDuration;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sliders/sliders.dart' show HSliderWithButtons;

/// Style for every heading and read-out in the demo.
///
/// Deliberately oversized so the values are legible from across a room
/// when the demo is projected; this is not meant to follow the ambient
/// [TextTheme].
const TextStyle _textStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 24,
);

/// Style for the secondary line under the sign switch.
const TextStyle _subTitleStyle = TextStyle(
  fontWeight: FontWeight.normal,
  fontSize: 12,
);

/// Tint for every slider track, thumb and button.
const Color _sliderColor = Colors.deepOrange;

/// Upper bound of the days slider.
///
/// Days have no natural wrap-around, so the bound is a UX choice: large
/// enough to show multi-digit day counts, small enough that one notch on
/// the slider is still a useful increment.
const int _maxDays = 20;

/// Describes one unit slider: its heading, the [DurationUnits] it edits,
/// and the highest value it can reach.
///
/// The lower bound is always zero. Sign is handled separately by the
/// switch, so every slider works on the magnitude only.
typedef _SliderSpec = ({String label, DurationUnits unit, int max});

/// The sliders shown, in display order.
///
/// Every unit is bounded to its natural range so that the sliders are
/// *independent*: moving one never changes what another one displays.
/// Adding a slider is a single entry here — [_DurationDemoState] derives
/// everything else (read-outs, decomposition, recomposition) from this
/// table.
const List<_SliderSpec> _sliderSpecs = [
  (label: 'Days', unit: DurationUnits.days, max: _maxDays),
  (label: 'Hours', unit: DurationUnits.hours, max: Duration.hoursPerDay - 1),
  (
    label: 'Minutes',
    unit: DurationUnits.minutes,
    max: Duration.minutesPerHour - 1,
  ),
  (
    label: 'Seconds',
    unit: DurationUnits.seconds,
    max: Duration.secondsPerMinute - 1,
  ),
];

/// Interactive demo: a row of unit sliders and a sign switch drive a single
/// [Duration], which is rendered through `ExtDuration.composeFormat` and
/// `ExtDuration.format`.
///
/// ## What it shows
///
/// Two read-outs at the top:
///
/// * **FMT** — the template `composeFormat` produced for the current
///   duration (always day-led, because `showLeaderZero` is on).
/// * **OUT** — that template expanded by `format`.
///
/// Below them a [CaptionSwitch] flips the sign, and one slider per entry in
/// the unit table edits that unit of the magnitude.
///
/// ## Behaviour
///
/// * Each unit is hard-bounded to its natural range (hours 0–23,
///   minutes/seconds 0–59, days 0–[_maxDays]). Units never roll over into
///   their neighbour, so the sliders are independent.
/// * The sign switch negates the duration without touching its magnitude;
///   the per-unit read-outs therefore never show a negative number.
/// * Negating zero leaves zero, so flipping the switch at zero changes the
///   switch but not the output.
///
/// ## State
///
/// The only mutable state is the signed [Duration] and the switch
/// position. Every displayed string is derived from those on each build.
///
/// ## Example
///
/// ```dart
/// Scaffold(body: DurationDemo())
/// ```
///
/// See also:
///
/// * [DurationUnits], which supplies the unit arithmetic.
/// * [HSliderWithButtons], the slider used for each unit.
class DurationDemo extends StatefulWidget {
  /// Creates the demo.
  const DurationDemo({super.key});

  @override
  State<DurationDemo> createState() => _DurationDemoState();
}

/// State for [DurationDemo].
///
/// Holds the signed [duration] and the [negativeDuration] switch position,
/// and derives everything else from them. The decomposition into per-unit
/// components and the recomposition after a slider move are both generic
/// over [_sliderSpecs], so this class never names an individual unit.
class _DurationDemoState extends State<DurationDemo> {
  /// Single source of truth. Every displayed value is derived from this.
  Duration duration = Duration.zero;

  /// Position of the sign switch.
  ///
  /// Kept separately from `duration.isNegative` because `-Duration.zero`
  /// is still zero: at zero the switch can be on while the duration is
  /// not negative, and the switch must still render as on.
  bool negativeDuration = false;

  /// The unsigned part of [duration].
  ///
  /// Used for every per-unit read-out so a negative duration never
  /// produces a negative day count or a wrapped hour.
  Duration get _magnitude => duration.abs();

  /// The template `composeFormat` produces for the current [duration].
  ///
  /// `showLeaderZero` is on so the template is always day-led and the
  /// output keeps a fixed shape as the sliders move.
  String get template => duration.composeFormat(
    showLeaderZero: true,
    showPlusSign: false,
    padHours: false,
  );

  /// [template] expanded with the current [duration].
  String get output => duration.format(template);

  /// The value of [unit] within [_magnitude], wrapped at the next larger
  /// unit.
  ///
  /// For the largest unit in [DurationUnits] there is nothing to wrap at,
  /// so the whole count is returned. For every other unit the result lies
  /// in `[0, parent / unit)`, e.g. hours in `[0, 24)`.
  int _componentOf(DurationUnits unit) {
    final count = _magnitude.inMicroseconds ~/ unit.inMicroseconds;
    final index = DurationUnits.values.indexOf(unit);
    if (index == 0) return count;

    final parent = DurationUnits.values[index - 1];
    return count % (parent.inMicroseconds ~/ unit.inMicroseconds);
  }

  /// [duration] with the sign the switch dictates.
  Duration _signed(Duration magnitude) =>
      negativeDuration ? -magnitude : magnitude;

  /// Flips the sign of [duration] without changing its magnitude.
  ///
  /// Wired to the [CaptionSwitch]; [isNegative] is the switch's new value.
  void toggleSign(bool isNegative) {
    setState(() {
      negativeDuration = isNegative;
      duration = _signed(_magnitude);
    });
  }

  /// Replaces the [unit] component of [duration] with [value], keeping
  /// every other component and the sign.
  ///
  /// The magnitude is rebuilt from the slider table rather than from the
  /// old [Duration], so a unit that has no slider cannot leak in.
  void update(DurationUnits unit, int value) {
    setState(() {
      var magnitude = Duration.zero;
      for (final spec in _sliderSpecs) {
        final component = spec.unit == unit ? value : _componentOf(spec.unit);
        magnitude += spec.unit.times(component);
      }
      duration = _signed(magnitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LabelledValue(label: 'FMT:', value: template),
          const Gap(4),
          _LabelledValue(label: 'OUT:', value: output),
          const Gap(4),
          CaptionSwitch.text(
            caption: 'Negative duration',
            value: negativeDuration,
            textStyle: _textStyle,
            subtitle: 'toggle sign of duration',
            subtitleStyle: _subTitleStyle,
            onChanged: toggleSign,
          ),
          for (final spec in _sliderSpecs)
            _UnitSlider(
              key: ValueKey(spec.unit),
              spec: spec,
              value: _componentOf(spec.unit),
              onChanged: update,
            ),
        ],
      ),
    );
  }
}

/// A bold `label value` pair on one line.
class _LabelledValue extends StatelessWidget {
  const _LabelledValue({required this.label, required this.value});

  /// Short prefix, e.g. `FMT:`.
  final String label;

  /// The value shown after [label].
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(label, style: _textStyle),
      const Gap(8),
      Text(value, style: _textStyle),
    ],
  );
}

/// One unit's heading (`Label: value`) and its [HSliderWithButtons].
///
/// `divisions == max` with `min == 0` and `step == 1`, so every notch and
/// every button tap lands on an integer.
///
/// [HSliderWithButtons] is uncontrolled: it reads `initialValue` once and
/// thereafter owns its own position. That is fine here because the only
/// thing that moves a unit is its own slider, so the slider and [value]
/// never disagree. If the demo ever changes a unit by another route (a
/// reset button, say), the slider must be remounted with a new [Key].
class _UnitSlider extends StatelessWidget {
  const _UnitSlider({
    required this.spec,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Which unit this slider edits, and its label and upper bound.
  final _SliderSpec spec;

  /// The unit's current value, shown in the heading and used to seed the
  /// slider.
  final int value;

  /// Called with [spec]'s unit and the new integer value on every move.
  final void Function(DurationUnits unit, int value) onChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('${spec.label}: $value', style: _textStyle),
      HSliderWithButtons(
        min: 0,
        max: spec.max.toDouble(),
        step: 1,
        divisions: spec.max,
        initialValue: value.toDouble(),
        color: _sliderColor,
        onChanged: (v) => onChanged(spec.unit, v.round()),
      ),
    ],
  );
}
