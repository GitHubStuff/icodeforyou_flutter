import 'package:flutter/foundation.dart' show visibleForTesting;

extension DateTimeHelper on DateTime {
  static int _lastMicroseconds = 0;
  static int maxDrift = 0;

  static Future<DateTime> unique() async {
    int currentMicros = DateTime.now().microsecondsSinceEpoch;
    if (currentMicros <= _lastMicroseconds) {
      currentMicros = _lastMicroseconds + 1;
      final drift = currentMicros - DateTime.now().microsecondsSinceEpoch;
      if (maxDrift < drift) {
        maxDrift = drift;
      }
      if (drift > 500) {
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
  }
}
