// packages/ext_duration/test/ext_duration_test.dart

import 'package:ext_duration/ext_duration.dart';
import 'package:test/test.dart';

void main() {
  group('ext_duration barrel', () {
    test('exports DurationUnits', () {
      expect(DurationUnits.values, hasLength(6));
      expect(DurationUnits.seconds.inMicroseconds, Duration.microsecondsPerSecond);
    });

    test('exports ExtDuration', () {
      const duration = Duration(hours: 1, minutes: 2, seconds: 3);

      expect(duration.format('%02h:%02m:%02s'), '01:02:03');
      expect(
        duration.composeFormat(
          showPlusSign: false,
          showLeaderZero: false,
          padHours: false,
        ),
        '%h:%02m:%02s',
      );
      expect(duration.toStopwatchDisplay(), '0 01:02:03');
    });
  });
}
