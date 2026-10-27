// packages/sincewhen_screens/lib/src/util/timestamp_display.dart

import 'package:intl/intl.dart';

/// {@template timestamp_display}
/// Formats stored timestamps for display on the since-when screens.
///
/// The storage truth is an integer of microseconds since epoch (UTC by
/// definition); conversion to the device's local zone happens here, at
/// the display boundary, and nowhere else.
///
/// The display contract is `'Tue 14-Jul-2024 6:27:47 pm'`:
///
/// * abbreviated weekday and month
/// * zero-padded day, full year
/// * 12-hour clock with no leading zero on the hour
/// * lowercase meridian
///
/// The meridian is formatted separately and lowercased on its own —
/// lowercasing the whole string would corrupt the weekday and month
/// abbreviations.
/// {@endtemplate}
final class TimestampDisplay {
  const TimestampDisplay._();

  /// Placeholder shown when a nullable timestamp has no value.
  static const String noValue = '—';

  static final DateFormat _dateTimePart = DateFormat(
    'EEE dd-MMM-yyyy h:mm:ss',
  );

  static final DateFormat _meridianPart = DateFormat('a');

  /// Formats [microsecondsSinceEpoch] as a local date/time string in
  /// the `'Tue 14-Jul-2024 6:27:47 pm'` contract.
  static String format(int microsecondsSinceEpoch) {
    final local = DateTime.fromMicrosecondsSinceEpoch(
      microsecondsSinceEpoch,
    );
    final dateTime = _dateTimePart.format(local);
    final meridian = _meridianPart.format(local).toLowerCase();
    return '$dateTime $meridian';
  }

  /// Formats a nullable timestamp, substituting [placeholder] (default
  /// [noValue]) when [microsecondsSinceEpoch] is `null`.
  ///
  /// Exists so every widget shares one representation of "no value"
  /// instead of inventing its own.
  static String formatOrPlaceholder(
    int? microsecondsSinceEpoch, {
    String placeholder = noValue,
  }) {
    if (microsecondsSinceEpoch == null) {
      return placeholder;
    }
    return format(microsecondsSinceEpoch);
  }
}
