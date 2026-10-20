// packages/tools/lib/src/duration/duration_demo.dart
import 'package:caption_switch/caption_switch.dart' show CaptionSwitch;
import 'package:ext_duration/ext_duration.dart'
    show DurationUnits, composeFormat;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:sliders/sliders.dart' show HSliderWithButtons;

const TextStyle _textStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 24,
);
const TextStyle _subTitleStyle = TextStyle(
  fontWeight: FontWeight.normal,
  fontSize: 12,
);

const Color _sliderColor = Colors.deepOrange;

/// Interactive demo: four unit sliders drive a single [Duration].
///
/// Each unit is hard-bounded to its natural range (hours 0–23,
/// minutes/seconds 0–59); units never roll over into their neighbour.
class DurationDemo extends StatefulWidget {
  /// Creates the demo.
  const DurationDemo({super.key});

  @override
  State<DurationDemo> createState() => _DurationDemoState();
}

class _DurationDemoState extends State<DurationDemo> {
  // Single source of truth. Every displayed unit is derived from this.
  Duration duration = Duration.zero;

  String formatString = '%S';

  int get days => duration.inDays;
  int get hours => duration.inHours % Duration.hoursPerDay;
  int get minutes => duration.inMinutes % Duration.minutesPerHour;
  int get seconds => duration.inSeconds % Duration.secondsPerMinute;

  bool negativeDuration = false;

  String get outputString => '0';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          labelledValue('FMT:', formatString),
          const Gap(4),
          labelledValue('OUT:', outputString),
          const Gap(4),
          CaptionSwitch.text(
            caption: 'Negative duration',
            value: negativeDuration,
            textStyle: _textStyle,
            subtitle: 'toggle sign of duration',
            subtitleStyle: _subTitleStyle,
            onChanged: (isPlus) {
              final abs = duration.inMicroseconds.abs();
              negativeDuration = isPlus;
              debugPrint('pre-duration is negative: $negativeDuration');
              setState(
                () => duration = Duration(microseconds: isPlus ? abs : -abs),
              );
               debugPrint('post-duration is negative: $negativeDuration');
             debugPrint('Duration $duration');
            },
          ),
          unitSlider(
            label: 'Days',
            value: days,
            max: 20,
            unit: .days,
          ),
          unitSlider(
            label: 'Hours',
            value: hours,
            max: Duration.hoursPerDay - 1,
            unit: .hours,
          ),
          unitSlider(
            label: 'Minutes',
            value: minutes,
            max: Duration.minutesPerHour - 1,
            unit: .minutes,
          ),
          unitSlider(
            label: 'Seconds',
            value: seconds,
            max: Duration.secondsPerMinute - 1,
            unit: .seconds,
          ),
        ],
      ),
    );
  }

  Widget labelledValue(String label, String value) => Row(
    children: [
      Text(label, style: _textStyle),
      const Gap(8),
      Text(value, style: _textStyle),
    ],
  );

  /// One unit's heading and slider. `divisions == max - min` so every
  /// notch lands on an integer.
  Widget unitSlider({
    required String label,
    required int value,
    required int max,
    required DurationUnits unit,
  }) => Column(
    children: [
      Text('$label: $value', style: _textStyle),
      HSliderWithButtons(
        min: 0,
        max: max.toDouble(),
        step: 1,
        divisions: max,
        initialValue: value.toDouble(),
        color: _sliderColor,
        onChanged: (v) => update(unit, v.round()),
      ),
    ],
  );

  void update(DurationUnits unit, int value) {
    setState(() {
      duration = Duration(
        days: unit == .days ? value : days,
        hours: unit == .hours ? value : hours,
        minutes: unit == .minutes ? value : minutes,
        seconds: unit == .seconds ? value : seconds,
      );
      final abs = duration.abs();
      duration = negativeDuration ? -abs : abs;
      formatString = composeFormat(
        duration,
        showLeaderZero: true,
        showPlusSign: false,
        padHours: false,
      );
    });
    debugPrint('Duration $duration $formatString');
  }
}
