// packages/time_spans/test/src/calendar/month_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:time_spans/src/calendar/month.dart' show Month;

void main() {
  group('Month', () {
    test('contains exactly 12 months in the correct calendar order', () {
      expect(Month.values.length, 12);

      expect(Month.january.index, 0);
      expect(Month.february.index, 1);
      expect(Month.march.index, 2);
      expect(Month.april.index, 3);
      expect(Month.may.index, 4);
      expect(Month.june.index, 5);
      expect(Month.july.index, 6);
      expect(Month.august.index, 7);
      expect(Month.september.index, 8);
      expect(Month.october.index, 9);
      expect(Month.november.index, 10);
      expect(Month.december.index, 11);
    });

    test('initializes with the correct commonYearDays for each month', () {
      expect(Month.january.commonYearDays, 31);
      expect(Month.february.commonYearDays, 28); // 28 in a common year
      expect(Month.march.commonYearDays, 31);
      expect(Month.april.commonYearDays, 30);
      expect(Month.may.commonYearDays, 31);
      expect(Month.june.commonYearDays, 30);
      expect(Month.july.commonYearDays, 31);
      expect(Month.august.commonYearDays, 31);
      expect(Month.september.commonYearDays, 30);
      expect(Month.october.commonYearDays, 31);
      expect(Month.november.commonYearDays, 30);
      expect(Month.december.commonYearDays, 31);
    });

    test(
      'daysInMonth returns commonYearDays for all months when isLeapYear is false',
      () {
        for (final month in Month.values) {
          expect(
            month.daysInMonth(isLeapYear: false),
            month.commonYearDays,
            reason:
                '${month.name} should have its common year days in a non-leap year',
          );
        }
      },
    );

    test(
      'daysInMonth returns 29 for February in leap years, and commonYearDays for the rest',
      () {
        for (final month in Month.values) {
          if (month == Month.february) {
            expect(
              month.daysInMonth(isLeapYear: true),
              29,
              reason: 'February should have 29 days in a leap year',
            );
          } else {
            expect(
              month.daysInMonth(isLeapYear: true),
              month.commonYearDays,
              reason: '${month.name} should not change length in a leap year',
            );
          }
        }
      },
    );
  });
}
