// packages/extensions/test/datetime_extension_truncate_2_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:extensions/datetime_ext/datetime_extension.dart'; // brings DateTimeExt into scope
import 'package:extensions/datetime_ext/datetime_unit.dart';

void main() {
  group('DateTimeExt.truncate (explicit extension invocation)', () {
    test('local: covers all units + DateTime.new path', () {
      final d = DateTime(2025, 8, 30, 23, 59, 58, 987, 654);

      Map<DateTimeUnit, List<int>> cases = {
        DateTimeUnit.usec: [2025, 8, 30, 23, 59, 58, 987, 654],
        DateTimeUnit.msec: [2025, 8, 30, 23, 59, 58, 987, 0],
        DateTimeUnit.second: [2025, 8, 30, 23, 59, 58, 0, 0],
        DateTimeUnit.minute: [2025, 8, 30, 23, 59, 0, 0, 0],
        DateTimeUnit.hour: [2025, 8, 30, 23, 0, 0, 0, 0],
        DateTimeUnit.day: [2025, 8, 30, 0, 0, 0, 0, 0],
        DateTimeUnit.month: [2025, 8, 1, 0, 0, 0, 0, 0],
        DateTimeUnit.year: [2025, 1, 1, 0, 0, 0, 0, 0],
      };

      for (final entry in cases.entries) {
        final u = entry.key;
        final exp = entry.value;

        // EXPLICIT extension call ensures THIS method is invoked for coverage.
        final t = DateTimeExt(d).truncate(atDateTimeUnit: u);

        expect(t.isUtc, isFalse, reason: 'local must remain local for $u');
        expect(
          [
            t.year,
            t.month,
            t.day,
            t.hour,
            t.minute,
            t.second,
            t.millisecond,
            t.microsecond,
          ],
          exp,
          reason: 'unexpected truncation for $u',
        );
      }
    });

    test('UTC: preserves UTC + DateTime.utc constructor path', () {
      final d = DateTime.utc(2025, 8, 30, 23, 59, 58, 987, 654);

      // pick a couple of units to drive both branches inside the return call
      final t1 = DateTimeExt(d).truncate(atDateTimeUnit: DateTimeUnit.minute);
      expect(t1.isUtc, isTrue);
      expect(
        [
          t1.year,
          t1.month,
          t1.day,
          t1.hour,
          t1.minute,
          t1.second,
          t1.millisecond,
          t1.microsecond,
        ],
        [2025, 8, 30, 23, 59, 0, 0, 0],
      );

      final t2 = DateTimeExt(d).truncate(atDateTimeUnit: DateTimeUnit.day);
      expect(t2.isUtc, isTrue);
      expect(
        [
          t2.year,
          t2.month,
          t2.day,
          t2.hour,
          t2.minute,
          t2.second,
          t2.millisecond,
          t2.microsecond,
        ],
        [2025, 8, 30, 0, 0, 0, 0, 0],
      );
    });

    test('leap-day month/year truncation', () {
      final leap = DateTime(2024, 2, 29, 12, 34, 56, 789, 123);

      final monthTrunc = DateTimeExt(
        leap,
      ).truncate(atDateTimeUnit: DateTimeUnit.month);
      expect(
        [
          monthTrunc.year,
          monthTrunc.month,
          monthTrunc.day,
          monthTrunc.hour,
          monthTrunc.minute,
          monthTrunc.second,
          monthTrunc.millisecond,
          monthTrunc.microsecond,
        ],
        [2024, 2, 1, 0, 0, 0, 0, 0],
      );

      final yearTrunc = DateTimeExt(
        leap,
      ).truncate(atDateTimeUnit: DateTimeUnit.year);
      expect(
        [
          yearTrunc.year,
          yearTrunc.month,
          yearTrunc.day,
          yearTrunc.hour,
          yearTrunc.minute,
          yearTrunc.second,
          yearTrunc.millisecond,
          yearTrunc.microsecond,
        ],
        [2024, 1, 1, 0, 0, 0, 0, 0],
      );
    });

    test(
      'idempotence: already aligned stays identical for all units (local & UTC)',
      () {
        final alignedLocal = DateTime(2030, 1, 1, 0, 0, 0, 0, 0);
        final alignedUtc = DateTime.utc(2030, 1, 1, 0, 0, 0, 0, 0);

        final units = <DateTimeUnit>[
          DateTimeUnit.year,
          DateTimeUnit.month,
          DateTimeUnit.day,
          DateTimeUnit.hour,
          DateTimeUnit.minute,
          DateTimeUnit.second,
          DateTimeUnit.msec,
          DateTimeUnit.usec,
        ];

        for (final u in units) {
          expect(
            DateTimeExt(alignedLocal).truncate(atDateTimeUnit: u),
            equals(alignedLocal),
          );
          expect(
            DateTimeExt(alignedUtc).truncate(atDateTimeUnit: u),
            equals(alignedUtc),
          );
        }
      },
    );
  });
}
