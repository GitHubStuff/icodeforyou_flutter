// packages/extensions/test/datetime/src/datetime_unit_test.dart
import 'package:ext_datetime/src/datetime_unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeUnit', () {
    test('is declared coarsest to finest', () {
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
  });

  group('DateTimeUnit.sublist', () {
    test('from year returns every unit', () {
      expect(
        DateTimeUnit.year.sublist(),
        DateTimeUnit.values.toSet(),
      );
    });

    test('from second returns second, msec and usec', () {
      expect(DateTimeUnit.second.sublist(), const {
        DateTimeUnit.second,
        DateTimeUnit.msec,
        DateTimeUnit.usec,
      });
    });

    test('from usec returns only usec', () {
      expect(DateTimeUnit.usec.sublist(), const {DateTimeUnit.usec});
    });

    test('is inclusive of the receiver for every unit', () {
      for (final unit in DateTimeUnit.values) {
        expect(unit.sublist(), contains(unit), reason: unit.name);
      }
    });

    test('contains exactly the units at or after the receiver', () {
      for (final unit in DateTimeUnit.values) {
        final expected = DateTimeUnit.values
            .where((other) => other.index >= unit.index)
            .toSet();

        expect(unit.sublist(), expected, reason: unit.name);
      }
    });

    test('never contains a coarser unit', () {
      for (final unit in DateTimeUnit.values.skip(1)) {
        final coarser = DateTimeUnit.values[unit.index - 1];

        expect(
          unit.sublist(),
          isNot(contains(coarser)),
          reason: '${unit.name} must not contain ${coarser.name}',
        );
      }
    });
  });
}
