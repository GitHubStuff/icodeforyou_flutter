// packages/extensions/test/datetime_extension_truncate_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:extensions/datetime_ext/datetime_unit.dart';

void main() {
  group('DateTimeExt.truncate', () {
    late DateTime local;
    late DateTime utc;

    setUp(() {
      local = DateTime(2024, 8, 24, 15, 30, 45, 123, 456);
      utc = DateTime.utc(2024, 8, 24, 15, 30, 45, 123, 456);
    });

    // --- Defaults & core behavior ------------------------------------------------

    test('default (second) zeros ms/usec only', () {
      final t = local.truncate(atDateTimeUnit: DateTimeUnit.second); // default is DateTimeUnit.second
      expect(t.isUtc, false);
      expect(t.year, 2024);
      expect(t.month, 8);
      expect(t.day, 24);
      expect(t.hour, 15);
      expect(t.minute, 30);
      expect(t.second, 45);
      expect(t.millisecond, 0);
      expect(t.microsecond, 0);
    });

    test('usec: no-op (edge: next == null)', () {
      final t = local.truncate(atDateTimeUnit: DateTimeUnit.usec);
      expect(t.year, 2024);
      expect(t.month, 8);
      expect(t.day, 24);
      expect(t.hour, 15);
      expect(t.minute, 30);
      expect(t.second, 45);
      expect(t.millisecond, 123);
      expect(t.microsecond, 456);
      expect(t.isUtc, false);
    });

    test('msec: zero microseconds only', () {
      final t = local.truncate(atDateTimeUnit: DateTimeUnit.msec);
      expect(t.millisecond, 123);
      expect(t.microsecond, 0);
      expect(t.isUtc, false);
    });

    // --- Truncation at each unit (local) ----------------------------------------

    test('minute: zero below minute', () {
      final t = local.truncate(atDateTimeUnit: DateTimeUnit.minute);
      expect(t.year, 2024);
      expect(t.month, 8);
      expect(t.day, 24);
      expect(t.hour, 15);
      expect(t.minute, 30);
      expect(t.second, 0);
      expect(t.millisecond, 0);
      expect(t.microsecond, 0);
      expect(t.isUtc, false);
    });

    test('hour: zero below hour', () {
      final t = local.truncate(atDateTimeUnit: DateTimeUnit.hour);
      expect(t.year, 2024);
      expect(t.month, 8);
      expect(t.day, 24);
      expect(t.hour, 15);
      expect(t.minute, 0);
      expect(t.second, 0);
      expect(t.millisecond, 0);
      expect(t.microsecond, 0);
      expect(t.isUtc, false);
    });

    test('day: zero time', () {
      final t = local.truncate(atDateTimeUnit: DateTimeUnit.day);
      expect(t.year, 2024);
      expect(t.month, 8);
      expect(t.day, 24);
      expect(t.hour, 0);
      expect(t.minute, 0);
      expect(t.second, 0);
      expect(t.millisecond, 0);
      expect(t.microsecond, 0);
      expect(t.isUtc, false);
    });

    test('month: set day=1 and zero time', () {
      final t = local.truncate(atDateTimeUnit: DateTimeUnit.month);
      expect(t.year, 2024);
      expect(t.month, 8);
      expect(t.day, 1);
      expect(t.hour, 0);
      expect(t.minute, 0);
      expect(t.second, 0);
      expect(t.millisecond, 0);
      expect(t.microsecond, 0);
      expect(t.isUtc, false);
    });

    test('year: set month=1, day=1 and zero time', () {
      final t = local.truncate(atDateTimeUnit: DateTimeUnit.year);
      expect(t.year, 2024);
      expect(t.month, 1);
      expect(t.day, 1);
      expect(t.hour, 0);
      expect(t.minute, 0);
      expect(t.second, 0);
      expect(t.millisecond, 0);
      expect(t.microsecond, 0);
      expect(t.isUtc, false);
    });

    // --- UTC/local preservation & constructor path ------------------------------

    test('UTC input stays UTC (second)', () {
      final t = utc.truncate(atDateTimeUnit: DateTimeUnit.second);
      expect(t.isUtc, true);
      expect(t.year, 2024);
      expect(t.month, 8);
      expect(t.day, 24);
      expect(t.hour, 15);
      expect(t.minute, 30);
      expect(t.second, 45);
      expect(t.millisecond, 0);
      expect(t.microsecond, 0);
    });

    test('UTC input stays UTC (minute)', () {
      final t = utc.truncate(atDateTimeUnit: DateTimeUnit.minute);
      expect(t.isUtc, true);
      expect(t.year, 2024);
      expect(t.month, 8);
      expect(t.day, 24);
      expect(t.hour, 15);
      expect(t.minute, 30);
      expect(t.second, 0);
      expect(t.millisecond, 0);
      expect(t.microsecond, 0);
    });

    test('DateTime.utc constructor path (day)', () {
      final d = DateTime.utc(2024, 6, 15, 12, 30, 45, 100, 200);
      final t = d.truncate(atDateTimeUnit: DateTimeUnit.day);
      expect(t.isUtc, true);
      expect(t.year, 2024);
      expect(t.month, 6);
      expect(t.day, 15);
      expect(t.hour, 0);
      expect(t.minute, 0);
      expect(t.second, 0);
      expect(t.millisecond, 0);
      expect(t.microsecond, 0);
    });

    test('DateTime.new constructor path (day)', () {
      final d = DateTime(2024, 6, 15, 12, 30, 45, 100, 200);
      final t = d.truncate(atDateTimeUnit: DateTimeUnit.day);
      expect(t.isUtc, false);
      expect(t.year, 2024);
      expect(t.month, 6);
      expect(t.day, 15);
      expect(t.hour, 0);
      expect(t.minute, 0);
      expect(t.second, 0);
      expect(t.millisecond, 0);
      expect(t.microsecond, 0);
    });

    // --- Edges / boundaries ------------------------------------------------------

    test('leap-day: month/year truncation behaves correctly', () {
      final leap = DateTime(2024, 2, 29, 12, 34, 56, 789, 123);
      final monthTrunc = leap.truncate(atDateTimeUnit: DateTimeUnit.month);
      expect(monthTrunc.year, 2024);
      expect(monthTrunc.month, 2);
      expect(monthTrunc.day, 1);
      expect(monthTrunc.hour, 0);
      expect(monthTrunc.minute, 0);
      expect(monthTrunc.second, 0);
      expect(monthTrunc.millisecond, 0);
      expect(monthTrunc.microsecond, 0);

      final yearTrunc = leap.truncate(atDateTimeUnit: DateTimeUnit.year);
      expect(yearTrunc.year, 2024);
      expect(yearTrunc.month, 1);
      expect(yearTrunc.day, 1);
      expect(yearTrunc.hour, 0);
      expect(yearTrunc.minute, 0);
      expect(yearTrunc.second, 0);
      expect(yearTrunc.millisecond, 0);
      expect(yearTrunc.microsecond, 0);
    });

    test(
      'February (non-29) truncation to month keeps month and sets day=1',
      () {
        final feb15 = DateTime(2024, 2, 15, 10, 20, 30, 400, 500);
        final t = feb15.truncate(atDateTimeUnit: DateTimeUnit.month);
        expect(t.year, 2024);
        expect(t.month, 2);
        expect(t.day, 1);
        expect(t.hour, 0);
        expect(t.minute, 0);
        expect(t.second, 0);
        expect(t.millisecond, 0);
        expect(t.microsecond, 0);
      },
    );

    test('year boundary: second truncation zeros ms/usec only', () {
      final d = DateTime(2025, 1, 1, 0, 0, 0, 1, 1);
      final t = d.truncate(atDateTimeUnit: DateTimeUnit.second);
      expect(t.year, 2025);
      expect(t.month, 1);
      expect(t.day, 1);
      expect(t.hour, 0);
      expect(t.minute, 0);
      expect(t.second, 0);
      expect(t.millisecond, 0);
      expect(t.microsecond, 0);
    });

    test('all-zero input remains sane when truncating to minute', () {
      final d = DateTime(2024, 1, 1, 0, 0, 0, 0, 0);
      final t = d.truncate(atDateTimeUnit: DateTimeUnit.minute);
      expect(t.year, 2024);
      expect(t.month, 1);
      expect(t.day, 1);
      expect(t.hour, 0);
      expect(t.minute, 0);
      expect(t.second, 0);
      expect(t.millisecond, 0);
      expect(t.microsecond, 0);
    });

    test('max-ish values: hour truncation zeros minute/second/ms/usec', () {
      final d = DateTime(2024, 12, 31, 23, 59, 59, 999, 999);
      final t = d.truncate(atDateTimeUnit: DateTimeUnit.hour);
      expect(t.year, 2024);
      expect(t.month, 12);
      expect(t.day, 31);
      expect(t.hour, 23);
      expect(t.minute, 0);
      expect(t.second, 0);
      expect(t.millisecond, 0);
      expect(t.microsecond, 0);
    });

    // --- Idempotence across all units -------------------------------------------

    test('already-aligned values remain unchanged for every unit', () {
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
        expect(alignedLocal.truncate(atDateTimeUnit: u), equals(alignedLocal));
        expect(alignedUtc.truncate(atDateTimeUnit: u), equals(alignedUtc));
      }
    });
  });
}
