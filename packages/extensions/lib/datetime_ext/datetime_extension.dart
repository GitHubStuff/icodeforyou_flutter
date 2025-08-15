// datetime_ext.dart
import 'package:flutter/foundation.dart';

import 'datetime_unit.dart' show DateTimeUnit;

extension DateTimeExt on DateTime {
  static int _lastMicroseconds = 0;
  static int maxDrift = 0;

  // Make drift threshold configurable for testing
  @visibleForTesting
  static int driftThreshold = 500;

  static Future<DateTime> unique() async {
    int currentMicros = DateTime.now().microsecondsSinceEpoch;
    if (currentMicros <= _lastMicroseconds) {
      currentMicros = _lastMicroseconds + 1;
      final drift = currentMicros - DateTime.now().microsecondsSinceEpoch;
      if (maxDrift < drift) {
        maxDrift = drift;
      }
      if (drift > driftThreshold) {
        // Use configurable threshold
        while (DateTime.now().microsecondsSinceEpoch < currentMicros) {
          await Future.delayed(Duration(milliseconds: 1));
        }
        currentMicros = DateTime.now().microsecondsSinceEpoch;
      }
    }
    _lastMicroseconds = currentMicros;
    return DateTime.fromMicrosecondsSinceEpoch(_lastMicroseconds);
  }

  @visibleForTesting
  static void reset() {
    _lastMicroseconds = 0;
    maxDrift = 0;
    driftThreshold = 500; // Reset to default
  }

  // Returns formatted timestamp string as HH:mm:ss.SSS
  String timeStamp() {
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:'
        '${second.toString().padLeft(2, '0')}.'
        '${millisecond.toString().padLeft(3, '0')}';
  }

  // static int daysIn({required int month, required int year}) {
  //   if (month == 2) return isLeap(year: year) ? 29 : 28;
  //   return [4, 6, 9, 11].contains(month) ? 30 : 31;
  // }

  // int daysInMonth() => daysIn(month: month, year: year);

  // static bool isLeap({required int year}) =>
  //     year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  // bool isLeapYear() => isLeap(year: year);

  /// Truncates the DateTime to the specified DateTimeUnit precision.
  DateTime truncate({DateTimeUnit atDateTimeUnit = DateTimeUnit.second}) {
    final skipUnits = atDateTimeUnit.next?.sublist() ?? {};
    final m = isUtc ? DateTime.utc : DateTime.new;
    return m(
      skipUnits.contains(DateTimeUnit.year) ? 0 : year,
      skipUnits.contains(DateTimeUnit.month) ? 1 : month,
      skipUnits.contains(DateTimeUnit.day) ? 1 : day,
      skipUnits.contains(DateTimeUnit.hour) ? 0 : hour,
      skipUnits.contains(DateTimeUnit.minute) ? 0 : minute,
      skipUnits.contains(DateTimeUnit.second) ? 0 : second,
      skipUnits.contains(DateTimeUnit.msec) ? 0 : millisecond,
      skipUnits.contains(DateTimeUnit.usec) ? 0 : microsecond,
    );
  }
}
