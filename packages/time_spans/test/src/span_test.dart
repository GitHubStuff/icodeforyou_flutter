// packages/time_spans/test/src/span_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:time_spans/src/span.dart';

void main() {
  group('Span', () {
    test('can be instantiated to cover implicit constructor', () {
      final span = Span();
      expect(span, isA<Span>());
    });

    test('calendar index and offset constants hold exact values', () {
      expect(Span.kFebruary, 2);
      expect(Span.kMarch, 3);
      expect(Span.kLeapDay, 29);
      expect(Span.kFeb28, 28);
      expect(Span.kMar1, 1);
      expect(Span.kZeroYears, 0);
      expect(Span.kOneYear, 1);
      expect(Span.kMonthAfterFebruary, 1);
      expect(Span.kNextMonthOffset, 1);
      expect(Span.kDayBeforeFirst, 0);
    });

    test('average month length constants hold highly precise values', () {
      expect(Span.kCommonYearAvg, 30.416667);
      expect(Span.kJulianCycleAvg, 30.437500);
      expect(Span.kCenturyAvg, 30.436667);
      expect(Span.kGregorianCycleAvg, 30.436875);
    });

    test('standard time division constants hold correct values', () {
      expect(Span.kMonthsPerYear, 12);
      expect(Span.kDaysPerWeek, 7);
      expect(Span.kHoursPerDay, 24);
      expect(Span.kMinutesPerHour, 60);
      expect(Span.kSecondsPerMinute, 60);
      expect(Span.kMillisecondsPerSecond, 1000);
      expect(Span.kMicrosecondsPerMillisecond, 1000);
    });
  });
}
