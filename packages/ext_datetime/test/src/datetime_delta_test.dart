// packages/ext_datetime/test/src/datetime_delta_test.dart

import 'package:ext_datetime/ext_datetime.dart';
import 'package:ext_datetime/src/helpers/datetime_difference.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeDelta', () {
    group('constructor', () {
      test('stores every component', () {
        const delta = DateTimeDelta(
          isFuture: true,
          years: 1,
          months: 2,
          days: 3,
          hours: 4,
          minutes: 5,
          seconds: 6,
          milliseconds: 7,
          microseconds: 8,
        );
        expect(delta.isFuture, isTrue);
        expect(delta.years, 1);
        expect(delta.months, 2);
        expect(delta.days, 3);
        expect(delta.hours, 4);
        expect(delta.minutes, 5);
        expect(delta.seconds, 6);
        expect(delta.milliseconds, 7);
        expect(delta.microseconds, 8);
      });

      test('components default to null', () {
        const delta = DateTimeDelta(isFuture: false);
        expect(delta.isFuture, isFalse);
        expect(delta.years, isNull);
        expect(delta.months, isNull);
        expect(delta.days, isNull);
        expect(delta.hours, isNull);
        expect(delta.minutes, isNull);
        expect(delta.seconds, isNull);
        expect(delta.milliseconds, isNull);
        expect(delta.microseconds, isNull);
      });

      test('is const-constructible and canonicalised', () {
        const a = DateTimeDelta(isFuture: true, days: 1);
        const b = DateTimeDelta(isFuture: true, days: 1);
        expect(identical(a, b), isTrue);
      });
    });

    group('delta', () {
      test('delegates to DateTimeDifference.delta with defaults', () {
        final start = DateTime.utc(2024, 1, 15, 10, 30);
        final end = DateTime.utc(2026, 3, 20, 8, 15, 42, 500, 250);

        final viaFacade = DateTimeDelta.delta(startTime: start, endTime: end);
        final direct = DateTimeDifference.delta(startTime: start, endTime: end);

        expect(viaFacade, direct);
        expect(
          viaFacade,
          const DateTimeDelta(
            isFuture: true,
            years: 2,
            months: 2,
            days: 4,
            hours: 21,
            minutes: 45,
            seconds: 42,
            milliseconds: 0,
            microseconds: 0,
          ),
        );
      });

      test('forwards firstDateTimeUnit', () {
        final start = DateTime.utc(2024, 1, 15, 10, 30);
        final end = DateTime.utc(2026, 3, 20, 8, 15);

        final result = DateTimeDelta.delta(
          startTime: start,
          endTime: end,
          firstDateTimeUnit: DateTimeUnit.day,
        );

        expect(result.years, isNull);
        expect(result.months, isNull);
        expect(result.days, 4);
        expect(result.hours, 21);
        expect(result.minutes, 45);
        expect(result.seconds, 0);
      });

      test('forwards precision', () {
        final start = DateTime.utc(2024, 1, 15, 10, 30);
        final end = DateTime.utc(2026, 3, 20, 8, 15, 42);

        final result = DateTimeDelta.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.minute,
        );

        expect(result.minutes, 45);
        expect(result.seconds, 0);
        expect(result.milliseconds, 0);
        expect(result.microseconds, 0);
      });

      test('forwards truncate', () {
        final start = DateTime.utc(2024, 1, 15, 10, 30);
        final end = DateTime.utc(2026, 3, 20, 8, 15, 42);

        final result = DateTimeDelta.delta(
          startTime: start,
          endTime: end,
          precision: DateTimeUnit.minute,
          truncate: false,
        );

        expect(result.minutes, 45);
        expect(result.seconds, isNull);
        expect(result.milliseconds, isNull);
        expect(result.microseconds, isNull);
      });

      test('forwards a null endTime (defaults to now)', () {
        final result = DateTimeDelta.delta(startTime: DateTime.utc(2000));
        expect(result.isFuture, isTrue);
        expect(result.years, greaterThanOrEqualTo(26));
      });

      test('reports isFuture false when start is after end', () {
        final result = DateTimeDelta.delta(
          startTime: DateTime.utc(2026, 1, 2),
          endTime: DateTime.utc(2026),
        );
        expect(result.isFuture, isFalse);
        expect(result.days, 1);
      });

      test('propagates the UTC ArgumentError', () {
        expect(
          () => DateTimeDelta.delta(startTime: DateTime(2026)),
          throwsArgumentError,
        );
      });

      test('propagates the unit-ordering ArgumentError', () {
        expect(
          () => DateTimeDelta.delta(
            startTime: DateTime.utc(2026),
            endTime: DateTime.utc(2026, 1, 2),
            firstDateTimeUnit: DateTimeUnit.minute,
            precision: DateTimeUnit.hour,
          ),
          throwsArgumentError,
        );
      });
    });

    group('toString', () {
      test('renders every component when all are positive', () {
        const delta = DateTimeDelta(
          isFuture: true,
          years: 1,
          months: 2,
          days: 3,
          hours: 4,
          minutes: 5,
          seconds: 6,
          milliseconds: 7,
          microseconds: 8,
        );
        expect(delta.toString(), '1y 2mo 3d 4h 5m 6s 7ms 8μs');
      });

      test('years only', () {
        expect(const DateTimeDelta(isFuture: true, years: 3).toString(), '3y');
      });

      test('months only', () {
        expect(const DateTimeDelta(isFuture: true, months: 11).toString(), '11mo');
      });

      test('days only', () {
        expect(const DateTimeDelta(isFuture: true, days: 28).toString(), '28d');
      });

      test('hours only', () {
        expect(const DateTimeDelta(isFuture: true, hours: 23).toString(), '23h');
      });

      test('minutes only', () {
        expect(const DateTimeDelta(isFuture: true, minutes: 59).toString(), '59m');
      });

      test('seconds only', () {
        expect(const DateTimeDelta(isFuture: true, seconds: 1).toString(), '1s');
      });

      test('milliseconds only', () {
        expect(
          const DateTimeDelta(isFuture: true, milliseconds: 999).toString(),
          '999ms',
        );
      });

      test('microseconds only uses the Greek mu', () {
        expect(
          const DateTimeDelta(isFuture: true, microseconds: 1).toString(),
          '1\u03bcs',
        );
      });

      test('omits zero components', () {
        const delta = DateTimeDelta(
          isFuture: true,
          years: 0,
          months: 0,
          days: 5,
          hours: 0,
          minutes: 30,
          seconds: 0,
          milliseconds: 0,
          microseconds: 0,
        );
        expect(delta.toString(), '5d 30m');
      });

      test('omits null components', () {
        const delta = DateTimeDelta(isFuture: true, hours: 2, seconds: 9);
        expect(delta.toString(), '2h 9s');
      });

      test('all null renders 0', () {
        expect(const DateTimeDelta(isFuture: true).toString(), '0');
      });

      test('all zero renders 0', () {
        const delta = DateTimeDelta(
          isFuture: true,
          years: 0,
          months: 0,
          days: 0,
          hours: 0,
          minutes: 0,
          seconds: 0,
          milliseconds: 0,
          microseconds: 0,
        );
        expect(delta.toString(), '0');
      });

      test('negative direction prefixes a minus', () {
        const delta = DateTimeDelta(isFuture: false, hours: 1, minutes: 20);
        expect(delta.toString(), '-1h 20m');
      });

      test('negative direction with nothing to show renders 0 without minus', () {
        expect(const DateTimeDelta(isFuture: false).toString(), '0');
        const zeros = DateTimeDelta(isFuture: false, days: 0, hours: 0);
        expect(zeros.toString(), '0');
      });

      test('negative direction renders every component', () {
        const delta = DateTimeDelta(
          isFuture: false,
          years: 1,
          months: 2,
          days: 3,
          hours: 4,
          minutes: 5,
          seconds: 6,
          milliseconds: 7,
          microseconds: 8,
        );
        expect(delta.toString(), '-1y 2mo 3d 4h 5m 6s 7ms 8μs');
      });

      test('a computed delta renders as expected', () {
        final delta = DateTimeDelta.delta(
          startTime: DateTime.utc(2024, 1, 15, 10, 30),
          endTime: DateTime.utc(2026, 3, 20, 8, 15),
        );
        expect(delta.toString(), '2y 2mo 4d 21h 45m');
      });

      test('a computed reverse delta renders with a minus', () {
        final delta = DateTimeDelta.delta(
          startTime: DateTime.utc(2026, 3, 20, 8, 15),
          endTime: DateTime.utc(2024, 1, 15, 10, 30),
        );
        expect(delta.toString(), '-2y 2mo 4d 21h 45m');
      });
    });

    group('equality', () {
      const reference = DateTimeDelta(
        isFuture: true,
        years: 1,
        months: 2,
        days: 3,
        hours: 4,
        minutes: 5,
        seconds: 6,
        milliseconds: 7,
        microseconds: 8,
      );

      test('is reflexive', () {
        expect(reference, equals(reference));
        expect(reference == reference, isTrue);
      });

      test('two non-identical instances with equal fields are equal', () {
        final a = DateTimeDelta.delta(
          startTime: DateTime.utc(2026),
          endTime: DateTime.utc(2026, 2, 3, 4, 5, 6, 7, 8),
        );
        final b = DateTimeDelta.delta(
          startTime: DateTime.utc(2026),
          endTime: DateTime.utc(2026, 2, 3, 4, 5, 6, 7, 8),
        );
        expect(identical(a, b), isFalse);
        expect(a, equals(b));
        expect(b, equals(a));
      });

      test('is not equal to an unrelated object', () {
        expect(reference, isNot(equals(Object())));
        expect(reference, isNot(equals('1y 2mo 3d 4h 5m 6s 7ms 8μs')));
      });

      test('differs on years', () {
        const other = DateTimeDelta(
          isFuture: true,
          years: 9,
          months: 2,
          days: 3,
          hours: 4,
          minutes: 5,
          seconds: 6,
          milliseconds: 7,
          microseconds: 8,
        );
        expect(reference, isNot(equals(other)));
      });

      test('differs on months', () {
        const other = DateTimeDelta(
          isFuture: true,
          years: 1,
          months: 9,
          days: 3,
          hours: 4,
          minutes: 5,
          seconds: 6,
          milliseconds: 7,
          microseconds: 8,
        );
        expect(reference, isNot(equals(other)));
      });

      test('differs on days', () {
        const other = DateTimeDelta(
          isFuture: true,
          years: 1,
          months: 2,
          days: 9,
          hours: 4,
          minutes: 5,
          seconds: 6,
          milliseconds: 7,
          microseconds: 8,
        );
        expect(reference, isNot(equals(other)));
      });

      test('differs on hours', () {
        const other = DateTimeDelta(
          isFuture: true,
          years: 1,
          months: 2,
          days: 3,
          hours: 9,
          minutes: 5,
          seconds: 6,
          milliseconds: 7,
          microseconds: 8,
        );
        expect(reference, isNot(equals(other)));
      });

      test('differs on minutes', () {
        const other = DateTimeDelta(
          isFuture: true,
          years: 1,
          months: 2,
          days: 3,
          hours: 4,
          minutes: 9,
          seconds: 6,
          milliseconds: 7,
          microseconds: 8,
        );
        expect(reference, isNot(equals(other)));
      });

      test('differs on seconds', () {
        const other = DateTimeDelta(
          isFuture: true,
          years: 1,
          months: 2,
          days: 3,
          hours: 4,
          minutes: 5,
          seconds: 9,
          milliseconds: 7,
          microseconds: 8,
        );
        expect(reference, isNot(equals(other)));
      });

      test('differs on milliseconds', () {
        const other = DateTimeDelta(
          isFuture: true,
          years: 1,
          months: 2,
          days: 3,
          hours: 4,
          minutes: 5,
          seconds: 6,
          milliseconds: 9,
          microseconds: 8,
        );
        expect(reference, isNot(equals(other)));
      });

      test('differs on microseconds', () {
        const other = DateTimeDelta(
          isFuture: true,
          years: 1,
          months: 2,
          days: 3,
          hours: 4,
          minutes: 5,
          seconds: 6,
          milliseconds: 7,
          microseconds: 9,
        );
        expect(reference, isNot(equals(other)));
      });

      test('differs on isFuture', () {
        const other = DateTimeDelta(
          isFuture: false,
          years: 1,
          months: 2,
          days: 3,
          hours: 4,
          minutes: 5,
          seconds: 6,
          milliseconds: 7,
          microseconds: 8,
        );
        expect(reference, isNot(equals(other)));
      });

      test('null and zero are distinct', () {
        const withNull = DateTimeDelta(isFuture: true);
        const withZero = DateTimeDelta(isFuture: true, years: 0);
        expect(withNull, isNot(equals(withZero)));
      });
    });

    group('hashCode', () {
      test('equal instances share a hash', () {
        final a = DateTimeDelta.delta(
          startTime: DateTime.utc(2026),
          endTime: DateTime.utc(2026, 2, 3, 4, 5, 6, 7, 8),
        );
        final b = DateTimeDelta.delta(
          startTime: DateTime.utc(2026),
          endTime: DateTime.utc(2026, 2, 3, 4, 5, 6, 7, 8),
        );
        expect(a.hashCode, b.hashCode);
      });

      test('is stable across calls', () {
        const delta = DateTimeDelta(isFuture: true, days: 3, hours: 4);
        expect(delta.hashCode, delta.hashCode);
      });

      test('direction participates in the hash', () {
        const future = DateTimeDelta(isFuture: true, days: 3);
        const past = DateTimeDelta(isFuture: false, days: 3);
        expect(future.hashCode, isNot(past.hashCode));
      });

      test('works as a set member and map key', () {
        const a = DateTimeDelta(isFuture: true, days: 3);
        final b = DateTimeDelta.delta(
          startTime: DateTime.utc(2026),
          endTime: DateTime.utc(2026, 1, 4),
          firstDateTimeUnit: DateTimeUnit.day,
          precision: DateTimeUnit.day,
          truncate: false,
        );
        expect(a, equals(b));
        expect({a}.contains(b), isTrue);
        expect({a: 'x'}[b], 'x');
      });
    });
  });
}
