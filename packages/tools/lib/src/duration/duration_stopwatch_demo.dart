// packages/tools/lib/src/duration/duration_stopwatch_demo.dart

import 'dart:math' show Random;

import 'package:caption_switch/caption_switch.dart' show CaptionSwitch;
import 'package:ext_duration/ext_duration.dart' show ExtDuration;
import 'package:ext_widget/ext_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;

const TextStyle _textStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 16,
);
const TextStyle _subTitleStyle = TextStyle(
  fontWeight: FontWeight.normal,
  fontSize: 12,
);

///
class DurationStopwatchDemo extends StatefulWidget {
  ///
  const DurationStopwatchDemo({super.key});

  @override
  State<DurationStopwatchDemo> createState() => _DurationStopwatchDemo();
}

class _DurationStopwatchDemo extends State<DurationStopwatchDemo> {
  String stopWatch = '0 00:00:00';
  Duration duration = Duration.zero;
  final random = Random();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stopWatch,
            style: _textStyle,
          ).withPaddingAll(8).withBorder(color: Colors.green),
          const Gap(8),
          CaptionSwitch.text(
            caption: 'Toogle to change',
            textStyle: _textStyle,
            subtitle: 'Slide Switch',
            subtitleStyle: _subTitleStyle,
            value: true,
            onChanged: (_) {
              duration = random.nextDuration();
              setState(() => stopWatch = duration.toStopwatchDisplay());
            },
          ).withPaddingSymmetric(horizontal: 16),
        ],
      ),
    );
  }
}

///
extension RandomDuration on Random {
  /// Returns a random [Duration] in the range `[min, max]`, inclusive,
  /// with one-second granularity.
  ///
  /// Defaults to anywhere between zero and one year. Pass a negative
  /// [min] to allow negative durations.
  Duration nextDuration({
    Duration min = Duration.zero,
    Duration max = const Duration(days: 365),
  }) {
    assert(max >= min, 'max must not be less than min');

    final span = max.inSeconds - min.inSeconds;
    return min + Duration(seconds: nextInt(span + 1));
  }
}
