// packages/ext_duration/lib/src/ext_duration.dart

import 'package:ext_duration/ext_duration.dart' show composeFormat;
import 'package:ext_duration/src/formatter/duration_formatter.dart'
    show DurationFormatter;

/// Convenience extension so callers can write `duration.format(pattern)`.
extension ExtDuration on Duration {
  /// Formats this duration with a `sprintf`-style [pattern].
  ///
  /// See [DurationFormatter] for the supported conversions and flags.
  String format(String pattern) => DurationFormatter(pattern).format(this);

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
