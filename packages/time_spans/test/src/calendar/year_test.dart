// packages/time_spans/test/src/calendar/year_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:time_spans/src/calendar/year.dart';

void main() {
  group('Year', () {
    test('stores the calendar year number correctly', () {
      expect(const Year(2026).year, 2026);
      expect(const Year(-1).year, -1);
    });

    group('isLeapYear', () {
      test('returns false for years not divisible by 4', () {
        expect(const Year(2023).isLeapYear, isFalse);
        expect(const Year(2025).isLeapYear, isFalse);
      });

      test('returns true for years divisible by 4 but not by 100', () {
        expect(const Year(2024).isLeapYear, isTrue);
        expect(const Year(2028).isLeapYear, isTrue);
      });

      test('returns false for century years not divisible by 400', () {
        expect(const Year(1800).isLeapYear, isFalse);
        expect(const Year(1900).isLeapYear, isFalse);
        expect(const Year(2100).isLeapYear, isFalse);
      });

      test('returns true for century years divisible by 400', () {
        expect(const Year(1600).isLeapYear, isTrue);
        expect(const Year(2000).isLeapYear, isTrue);
        expect(const Year(2400).isLeapYear, isTrue);
      });

      test(
        'applies proleptic leap rules correctly for zero and negative years',
        () {
          expect(const Year(0).isLeapYear, isTrue); // 0 is divisible by 400
          expect(const Year(-4).isLeapYear, isTrue);
          expect(const Year(-100).isLeapYear, isFalse);
          expect(const Year(-400).isLeapYear, isTrue);
        },
      );
    });

    group('inDays', () {
      test('returns 366 for a leap year', () {
        expect(const Year(2024).inDays, 366);
        expect(const Year(2000).inDays, 366);
      });

      test('returns 365 for a common year', () {
        expect(const Year(2023).inDays, 365);
        expect(const Year(1900).inDays, 365);
      });
    });
  });
}
