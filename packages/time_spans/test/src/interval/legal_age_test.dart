// packages/time_spans/test/src/interval/legal_age_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:time_spans/src/interval/legal_age.dart';
import 'package:time_spans/src/policy/leap_day_policy.dart';

void main() {
  group('LegalAge', () {
    group('Basic Age Calculation', () {
      final birth = DateTime(2000, 8, 15);

      test('returns 0 if asOf is before birth year', () {
        final age = LegalAge.of(birth: birth, asOf: DateTime(1999, 8, 15));
        expect(age.years, 0);
      });

      test('returns 0 if asOf is in birth year but before birthday', () {
        final age = LegalAge.of(birth: birth, asOf: DateTime(2000, 8, 14));
        expect(age.years, 0);
      });

      test('returns age - 1 if asOf is month before birthday', () {
        final age = LegalAge.of(birth: birth, asOf: DateTime(2020, 7, 15));
        expect(age.years, 19);
      });

      test('returns age - 1 if asOf is day before birthday', () {
        final age = LegalAge.of(birth: birth, asOf: DateTime(2020, 8, 14));
        expect(age.years, 19);
      });

      test('returns full age if asOf is exact birthday', () {
        final age = LegalAge.of(birth: birth, asOf: DateTime(2020, 8, 15));
        expect(age.years, 20);
      });

      test('returns full age if asOf is day after birthday', () {
        final age = LegalAge.of(birth: birth, asOf: DateTime(2020, 8, 16));
        expect(age.years, 20);
      });

      test('returns full age if asOf is month after birthday', () {
        final age = LegalAge.of(birth: birth, asOf: DateTime(2020, 9, 15));
        expect(age.years, 20);
      });
    });

    group('Leaplings (Born Feb 29)', () {
      final leapling = DateTime(2000, 2, 29);

      test('in a subsequent leap year, birthday is Feb 29', () {
        // 2004 is a leap year
        final ageBefore = LegalAge.of(
          birth: leapling,
          asOf: DateTime(2004, 2, 28),
        );
        final ageOn = LegalAge.of(birth: leapling, asOf: DateTime(2004, 2, 29));

        expect(ageBefore.years, 3);
        expect(ageOn.years, 4);
      });

      test('in a century leap year (e.g. 2400), birthday is Feb 29', () {
        // Testing _isLeapYear century modulus behavior
        final ageBefore = LegalAge.of(
          birth: leapling,
          asOf: DateTime(2400, 2, 28),
        );
        final ageOn = LegalAge.of(birth: leapling, asOf: DateTime(2400, 2, 29));

        expect(ageBefore.years, 399);
        expect(ageOn.years, 400);
      });

      group('in a common year', () {
        test('with LeapDayPolicy.feb28 (default), birthday is Feb 28', () {
          // 2001 is a common year
          final ageBefore = LegalAge.of(
            birth: leapling,
            asOf: DateTime(2001, 2, 27),
            leapDayPolicy: LeapDayPolicy.feb28,
          );
          final ageOn = LegalAge.of(
            birth: leapling,
            asOf: DateTime(2001, 2, 28),
            leapDayPolicy: LeapDayPolicy.feb28,
          );

          expect(ageBefore.years, 0);
          expect(ageOn.years, 1);
        });

        test('with LeapDayPolicy.mar1, birthday is Mar 1', () {
          final ageBefore = LegalAge.of(
            birth: leapling,
            asOf: DateTime(2001, 2, 28),
            leapDayPolicy: LeapDayPolicy.mar1,
          );
          final ageOn = LegalAge.of(
            birth: leapling,
            asOf: DateTime(2001, 3, 1),
            leapDayPolicy: LeapDayPolicy.mar1,
          );

          expect(ageBefore.years, 0);
          expect(ageOn.years, 1);
        });

        test(
          'with century common year (e.g. 2100), applies policy correctly',
          () {
            // 2100 is not a leap year (divisible by 100, not 400)
            final ageBefore = LegalAge.of(
              birth: leapling,
              asOf: DateTime(2100, 2, 27),
              leapDayPolicy: LeapDayPolicy.feb28,
            );
            final ageOn = LegalAge.of(
              birth: leapling,
              asOf: DateTime(2100, 2, 28),
              leapDayPolicy: LeapDayPolicy.feb28,
            );

            expect(ageBefore.years, 99);
            expect(ageOn.years, 100);
          },
        );
      });
    });

    group('isAtLeast', () {
      test('returns true when exact age', () {
        final age = LegalAge.of(
          birth: DateTime(2000, 1, 1),
          asOf: DateTime(2018, 1, 1),
        );
        expect(age.years, 18);
        expect(age.isAtLeast(18), isTrue);
      });

      test('returns true when over age', () {
        final age = LegalAge.of(
          birth: DateTime(2000, 1, 1),
          asOf: DateTime(2018, 1, 1),
        );
        expect(age.isAtLeast(17), isTrue);
      });

      test('returns false when under age', () {
        final age = LegalAge.of(
          birth: DateTime(2000, 1, 1),
          asOf: DateTime(2018, 1, 1),
        );
        expect(age.isAtLeast(19), isFalse);
      });
    });
  });
}
