// extensions/lib/src/datetime_ext/datetime_extension.dart
import 'package:extensions/datetime_ext/datetime_unit.dart' show DateTimeUnit;
import 'package:flutter/foundation.dart';

/// Extension on [DateTime] providing uniqueness guarantees, formatting,
/// and precision truncation utilities.
extension DateTimeExt on DateTime {
  static int _lastMicroseconds = 0;

  /// Tracks the maximum observed clock drift in microseconds.
  static int maxDrift = 0;

  /// The microsecond drift threshold above which the method waits for the
  /// system clock to catch up. Configurable for testing.
  @visibleForTesting
  static int driftThreshold = 500;

  /// Returns a [DateTime] guaranteed to be unique across successive calls.
  ///
  /// If the system clock has not advanced since the last call, the returned
  /// value is incremented by one microsecond. When drift exceeds
  /// [driftThreshold], the method yields until the clock catches up.
  static Future<DateTime> unique() async {
    int currentMicros = DateTime.now().microsecondsSinceEpoch;
    if (currentMicros <= _lastMicroseconds) {
      currentMicros = _lastMicroseconds + 1;
      final drift = currentMicros - DateTime.now().microsecondsSinceEpoch;
      if (maxDrift < drift) {
        maxDrift = drift;
      }
      if (drift > driftThreshold) {
        while (DateTime.now().microsecondsSinceEpoch < currentMicros) {
          await Future<void>.delayed(const Duration(milliseconds: 1));
        }
        currentMicros = DateTime.now().microsecondsSinceEpoch;
      }
    }
    _lastMicroseconds = currentMicros;
    return DateTime.fromMicrosecondsSinceEpoch(_lastMicroseconds);
  }

  /// Resets all static state to defaults. Intended for use in tests only.
  @visibleForTesting
  static void reset() {
    _lastMicroseconds = 0;
    maxDrift = 0;
    driftThreshold = 500;
  }

  /// Returns a formatted timestamp string in `HH:mm:ss.SSS` format.
  String timeStamp() {
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:'
        '${second.toString().padLeft(2, '0')}.'
        '${millisecond.toString().padLeft(3, '0')}';
  }

  /// Truncates this [DateTime] to the precision of [atDateTimeUnit].
  ///
  /// All units finer than [atDateTimeUnit] are zeroed (or set to their
  /// minimum valid value). Preserves UTC vs. local time.
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
