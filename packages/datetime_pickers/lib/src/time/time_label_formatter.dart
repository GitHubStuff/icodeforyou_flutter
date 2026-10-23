// packages/datetime_pickers/lib/src/time/time_label_formatter.dart

import 'package:intl/intl.dart' show DateFormat;

/// Formats a [DateTime] as a 12-hour clock time string with AM/PM
/// (e.g. `1:47:22 AM` or `1:47 AM`).
///
/// Use [showSeconds] to determine whether seconds are included in the output.
class TimeLabelFormatter {
  /// Creates a [TimeLabelFormatter].
  ///
  /// Set [showSeconds] to `true` to include seconds in the output
  /// (`h:mm:ss a`), or `false` to omit them (`h:mm a`).
  const TimeLabelFormatter({required this.showSeconds});

  /// Whether seconds are included in the formatted output.
  final bool showSeconds;

  /// Internal date formatter pattern when seconds are included (`h:mm:ss a`).
  static final DateFormat _withSeconds = DateFormat('h:mm:ss a');

  /// Internal date formatter pattern when seconds are omitted (`h:mm a`).
  static final DateFormat _withoutSeconds = DateFormat('h:mm a');

  /// Formats [time] into a 12-hour time string with an AM/PM marker.
  ///
  /// Returns a string formatted as `h:mm:ss a` if [showSeconds] is `true`,
  /// or `h:mm a` if [showSeconds] is `false`.
  String format(DateTime time) =>
      (showSeconds ? _withSeconds : _withoutSeconds).format(time);
}
