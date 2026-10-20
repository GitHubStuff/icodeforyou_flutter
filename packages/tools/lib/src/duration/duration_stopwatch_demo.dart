// packages/tools/lib/src/duration/duration_stopwatch_demo.dart

import 'dart:math' show Random;

import 'package:caption_switch/caption_switch.dart' show CaptionSwitch;
import 'package:ext_duration/ext_duration.dart' show ExtDuration;
import 'package:ext_widget/ext_widget.dart' show ExtWidget;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;

/// Style for the stopwatch read-out and the switch caption.
const TextStyle _textStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 16,
);

/// Style for the secondary line under the switch caption.
const TextStyle _subTitleStyle = TextStyle(
  fontWeight: FontWeight.normal,
  fontSize: 12,
);

/// Outline colour of the box around the stopwatch read-out.
const Color _displayBorderColor = Colors.green;

/// Demo: every flip of the switch draws a fresh random [Duration] and shows
/// it through `ExtDuration.toStopwatchDisplay`.
///
/// ## What it shows
///
/// A single read-out in the `d hh:mm:ss` stopwatch layout, starting at
/// `0 00:00:00`, inside a green outline. Below it a [CaptionSwitch] whose
/// only job is to be flipped: each flip replaces the duration with a random
/// one between zero and one year and re-renders the read-out.
///
/// The switch's on/off position carries no meaning; it is tracked only so
/// the control animates like a real switch rather than snapping back.
///
/// ## Randomness
///
/// Durations come from [RandomDuration.nextDuration] on [random]. Pass a
/// seeded [Random] to make the sequence reproducible — useful in widget
/// tests and in a Widgetbook use case that should look the same every
/// time. `null` uses an unseeded `Random()`.
///
/// ## Example
///
/// ```dart
/// // Production: unseeded.
/// const DurationStopwatchDemo()
///
/// // Deterministic: the same durations on every run.
/// DurationStopwatchDemo(random: Random(42))
/// ```
///
/// See also:
///
/// * `ExtDuration.toStopwatchDisplay`, which produces the read-out.
/// * [RandomDuration], the extension that generates the durations.
class DurationStopwatchDemo extends StatefulWidget {
  /// Creates the demo.
  ///
  /// [random] seeds the duration sequence; see the class documentation.
  const DurationStopwatchDemo({this.random, super.key});

  /// Source of random durations, or `null` for an unseeded [Random].
  ///
  /// Read once, when the state is created; later changes are ignored.
  final Random? random;

  @override
  State<DurationStopwatchDemo> createState() => _DurationStopwatchDemoState();
}

/// State for [DurationStopwatchDemo].
///
/// Holds the current [duration] and the switch position; the read-out is
/// derived from [duration] on every build rather than stored alongside it.
class _DurationStopwatchDemoState extends State<DurationStopwatchDemo> {
  /// The duration currently shown. Starts at zero.
  Duration duration = Duration.zero;

  /// Position of the switch, tracked so it animates on every flip.
  bool switchValue = false;

  /// Random source, resolved once from the widget.
  late final Random random = widget.random ?? Random();

  /// [duration] in `d hh:mm:ss` form.
  String get stopWatch => duration.toStopwatchDisplay();

  /// Records the new switch position and draws a new random duration.
  ///
  /// Wired to the [CaptionSwitch]; [value] is the switch's new position.
  void randomise(bool value) {
    setState(() {
      switchValue = value;
      duration = random.nextDuration();
    });
  }

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
          ).withPaddingAll(8).withBorder(color: _displayBorderColor),
          const Gap(8),
          CaptionSwitch.text(
            caption: 'Toggle to change',
            textStyle: _textStyle,
            subtitle: 'Slide Switch',
            subtitleStyle: _subTitleStyle,
            value: switchValue,
            onChanged: randomise,
          ).withPaddingSymmetric(horizontal: 16),
        ],
      ),
    );
  }
}

/// Random [Duration] generation on top of [Random].
///
/// ```dart
/// final random = Random(7);
///
/// random.nextDuration();                               // 0 … 365 days
/// random.nextDuration(max: const Duration(hours: 1));  // 0 … 1 hour
/// random.nextDuration(
///   min: const Duration(seconds: -30),
///   max: const Duration(seconds: 30),
/// );                                                   // may be negative
/// ```
extension RandomDuration on Random {
  /// Default upper bound of [nextDuration]: one (non-leap) year.
  static const Duration defaultMax = Duration(days: 365);

  /// Returns a random [Duration] in the range `[min, max]`, inclusive,
  /// with one-second granularity.
  ///
  /// Sub-second parts of [min] and [max] are truncated: the result is
  /// `min + n seconds` for a uniformly chosen integer `n` in
  /// `[0, max.inSeconds - min.inSeconds]`, so the result always carries
  /// [min]'s sub-second part exactly.
  ///
  /// Defaults to anywhere between [Duration.zero] and [defaultMax]. Pass a
  /// negative [min] to allow negative durations. [max] must not be less
  /// than [min]; this is enforced by an assertion in debug builds.
  Duration nextDuration({
    Duration min = Duration.zero,
    Duration max = defaultMax,
  }) {
    assert(max >= min, 'max must not be less than min');

    final span = max.inSeconds - min.inSeconds;
    return min + Duration(seconds: nextInt(span + 1));
  }
}
