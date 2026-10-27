// packages/ext_datetime/test/src/datetime_unit_test.dart

import 'package:ext_datetime/ext_datetime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeUnit', () {
    test('declares exactly eight units, coarsest to finest', () {
      expect(DateTimeUnit.values, const [
        DateTimeUnit.year,
        DateTimeUnit.month,
        DateTimeUnit.day,
        DateTimeUnit.hour,
        DateTimeUnit.minute,
        DateTimeUnit.second,
        DateTimeUnit.msec,
        DateTimeUnit.usec,
      ]);
    });

    test('index increases monotonically with fineness', () {
      for (var i = 1; i < DateTimeUnit.values.length; i++) {
        expect(
          DateTimeUnit.values[i].index,
          greaterThan(DateTimeUnit.values[i - 1].index),
          reason:
              '${DateTimeUnit.values[i]} must be finer than '
              '${DateTimeUnit.values[i - 1]}',
        );
      }
    });

    test('year is index 0 and usec is the last index', () {
      expect(DateTimeUnit.year.index, 0);
      expect(DateTimeUnit.usec.index, DateTimeUnit.values.length - 1);
    });

    group('sublist', () {
      test('year yields every unit', () {
        expect(DateTimeUnit.year.sublist(), DateTimeUnit.values.toSet());
      });

      test('month yields month through usec', () {
        expect(DateTimeUnit.month.sublist(), {
          DateTimeUnit.month,
          DateTimeUnit.day,
          DateTimeUnit.hour,
          DateTimeUnit.minute,
          DateTimeUnit.second,
          DateTimeUnit.msec,
          DateTimeUnit.usec,
        });
      });

      test('day yields day through usec', () {
        expect(DateTimeUnit.day.sublist(), {
          DateTimeUnit.day,
          DateTimeUnit.hour,
          DateTimeUnit.minute,
          DateTimeUnit.second,
          DateTimeUnit.msec,
          DateTimeUnit.usec,
        });
      });

      test('hour yields hour through usec', () {
        expect(DateTimeUnit.hour.sublist(), {
          DateTimeUnit.hour,
          DateTimeUnit.minute,
          DateTimeUnit.second,
          DateTimeUnit.msec,
          DateTimeUnit.usec,
        });
      });

      test('minute yields minute through usec', () {
        expect(DateTimeUnit.minute.sublist(), {
          DateTimeUnit.minute,
          DateTimeUnit.second,
          DateTimeUnit.msec,
          DateTimeUnit.usec,
        });
      });

      test('second yields second through usec', () {
        expect(DateTimeUnit.second.sublist(), {
          DateTimeUnit.second,
          DateTimeUnit.msec,
          DateTimeUnit.usec,
        });
      });

      test('msec yields msec and usec', () {
        expect(DateTimeUnit.msec.sublist(), {
          DateTimeUnit.msec,
          DateTimeUnit.usec,
        });
      });

      test('usec yields only itself', () {
        expect(DateTimeUnit.usec.sublist(), {DateTimeUnit.usec});
      });

      test('every unit yields itself through usec, inclusive', () {
        for (final unit in DateTimeUnit.values) {
          expect(
            unit.sublist(),
            DateTimeUnit.values.skip(unit.index).toSet(),
            reason: 'sublist of $unit',
          );
        }
      });

      test('never contains a coarser unit than the receiver', () {
        for (final unit in DateTimeUnit.values) {
          for (final member in unit.sublist()) {
            expect(
              member.index,
              greaterThanOrEqualTo(unit.index),
              reason: '$member is coarser than $unit',
            );
          }
        }
      });

      test('always contains the receiver', () {
        for (final unit in DateTimeUnit.values) {
          expect(unit.sublist(), contains(unit));
        }
      });

      test('size shrinks by one per step toward usec', () {
        for (final unit in DateTimeUnit.values) {
          expect(
            unit.sublist().length,
            DateTimeUnit.values.length - unit.index,
            reason: 'sublist length of $unit',
          );
        }
      });

      test('returns a fresh set on each call', () {
        final first = DateTimeUnit.day.sublist();
        final second = DateTimeUnit.day.sublist();
        expect(identical(first, second), isFalse);
        expect(first, second);
      });
    });
  });
}
