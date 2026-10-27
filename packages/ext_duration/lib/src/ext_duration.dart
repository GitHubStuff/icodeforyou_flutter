// packages/ext_duration/lib/src/ext_duration.dart

import 'package:ext_duration/src/formatter/duration_formatter.dart'
    show DurationFormatter;

part 'formatter/compose_format.dart';

/// Convenience extension so callers can write `duration.format(pattern)`.
extension ExtDuration on Duration {
  /// Formats this duration with a `sprintf`-style [pattern].
  ///
  /// See [DurationFormatter] for the supported conversions and flags.
  String format(String pattern) => DurationFormatter(pattern).format(this);

  /// Builds a **format string** describing how this duration should be
  /// rendered, using the placeholder vocabulary consumed by
  /// [DurationFormatter].
  ///
  /// This method does **not** produce the final human-readable text. It
  /// produces a *template* — a sequence of placeholder tokens — which [format]
  /// later expands by substituting the actual duration components. Separating
  /// the two steps keeps the layout logic (which components appear, in what
  /// order, with what padding) independent of the value-substitution logic.
  ///
  /// ## Placeholder vocabulary
  ///
  /// | Token   | Meaning                                                   |
  /// |---------|-----------------------------------------------------------|
  /// | `%n`    | Negative sign (emitted only when this duration is negative)|
  /// | `+`     | Literal plus sign (emitted only when [showPlusSign])      |
  /// | `%d`    | Whole days                                                |
  /// | `%h`    | Hours within the day, unpadded                            |
  /// | `%02h`  | Hours within the day, zero-padded to two digits           |
  /// | `%m`    | Minutes within the hour, unpadded                         |
  /// | `%02m`  | Minutes within the hour, zero-padded to two digits        |
  /// | `%s`    | Seconds within the minute, unpadded                       |
  /// | `%02s`  | Seconds within the minute, zero-padded to two digits      |
  ///
  /// ## Component selection
  ///
  /// The template body is determined entirely by the **leading unit** — the
  /// largest unit present in this duration, or days when [showLeaderZero] is
  /// `true`. Every unit smaller than the leading unit is always emitted, even
  /// when zero. This guarantees an unambiguous, left-anchored layout:
  /// `1d 0:00:05` rather than `1d 5`.
  ///
  /// Seconds are always emitted, so the resulting template is never empty.
  ///
  /// ## Padding rules
  ///
  /// - **Days** are never padded.
  /// - **Hours** are padded only when [padHours] is `true`. Hours are the
  ///   leading unit in the common case (sub-day durations), so callers decide
  ///   whether they want `1:05:09` or `01:05:09`. Note that this applies even
  ///   when days precede hours — `2 3:00:00`, not `2 03:00:00`, unless
  ///   [padHours] is set.
  /// - **Minutes** and **seconds** are padded to two digits whenever a larger
  ///   unit precedes them (so `1:05:09`, not `1:5:9`). When they are the
  ///   leading unit they are left unpadded (`5:09`, `9`).
  ///
  /// ## Leading-zero behaviour
  ///
  /// When [showLeaderZero] is `true`, days become the leading unit regardless
  /// of the duration's magnitude, forcing every component into the template.
  /// A duration of five seconds therefore yields `%d %h:%02m:%02s` (or
  /// `%d %02h:%02m:%02s` with [padHours]), which [format] renders as
  /// `0 0:00:05`. This is useful for fixed-width displays such as countdown
  /// timers.
  ///
  /// ## Sign handling
  ///
  /// The sign is derived from this duration's own sign; the leading unit is
  /// determined from its absolute value so that negative durations select
  /// exactly the same components as their positive counterparts.
  ///
  /// - Negative durations always emit `%n` as the first token.
  /// - Non-negative durations emit a literal `+` only when [showPlusSign] is
  ///   `true`. [Duration.zero] is treated as non-negative and *does* receive
  ///   the plus sign — unlike [toStopwatchDisplay], which never signs zero.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// const Duration(seconds: 9).composeFormat(
  ///   showPlusSign: false,
  ///   showLeaderZero: false,
  ///   padHours: false,
  /// ); // '%s'
  ///
  /// const Duration(minutes: 5, seconds: 9).composeFormat(
  ///   showPlusSign: false,
  ///   showLeaderZero: false,
  ///   padHours: false,
  /// ); // '%m:%02s'
  ///
  /// const Duration(hours: 1, minutes: 5, seconds: 9).composeFormat(
  ///   showPlusSign: true,
  ///   showLeaderZero: false,
  ///   padHours: true,
  /// ); // '+%02h:%02m:%02s'
  ///
  /// const Duration(days: 2).composeFormat(
  ///   showPlusSign: false,
  ///   showLeaderZero: false,
  ///   padHours: false,
  /// ); // '%d %h:%02m:%02s'
  ///
  /// const Duration(seconds: -9).composeFormat(
  ///   showPlusSign: true,
  ///   showLeaderZero: true,
  ///   padHours: false,
  /// ); // '%n%d %h:%02m:%02s'  (plus sign is ignored for negatives)
  /// ```
  ///
  /// ## Parameters
  ///
  /// - [showPlusSign]: Whether to prefix non-negative durations with `+`.
  ///   Has no effect on negative durations.
  /// - [showLeaderZero]: Whether to force all components (days through
  ///   seconds) into the template regardless of the duration's magnitude.
  /// - [padHours]: Whether the hours component uses the zero-padded `%02h`
  ///   token instead of `%h`.
  ///
  /// Returns the composed template string. The result is deterministic and
  /// side-effect free, and is drawn from a fixed set of at most twenty
  /// distinct strings.
  ///
  /// See also:
  ///
  /// - [format], which expands the returned template.
  /// - [Duration.abs], used to normalise the sign before determining the
  ///   leading unit.
  String composeFormat({
    required bool showPlusSign,
    required bool showLeaderZero,
    required bool padHours,
  }) {
    final sign = _templateSign(showPlusSign: showPlusSign);
    final unit = abs()._leadingUnit(showLeaderZero: showLeaderZero);
    return '$sign${_templateBody(unit, padHours: padHours)}';
  }

  /// Formats this duration as `d hh:mm:ss`.
  ///
  /// Days are unpadded; hours, minutes and seconds are zero-padded to
  /// two digits. Examples: `146 23:17:14`, `0 07:15:04`.
  ///
  /// Negative durations are prefixed with `-`. Positive durations are
  /// prefixed with `+` only when [showPlusSign] is `true`; zero never
  /// gets a sign.
  String toStopwatchDisplay({bool showPlusSign = false}) {
    final magnitude = abs();
    final days = magnitude.inDays;
    final hours = magnitude.inHours.remainder(Duration.hoursPerDay);
    final minutes = magnitude.inMinutes.remainder(Duration.minutesPerHour);
    final seconds = magnitude.inSeconds.remainder(Duration.secondsPerMinute);

    return '${_sign(showPlusSign)}$days '
        '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  String _sign(bool showPlusSign) {
    if (isNegative) return '-';
    return (showPlusSign && this > Duration.zero) ? '+' : '';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
