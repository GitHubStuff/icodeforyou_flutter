// packages/time_spans/test/src/extended_duration_unit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:time_spans/src/extended_duration_unit.dart';

void main() {
  group('ExtendedDurationUnit', () {
    test('contains exactly 9 values in descending order of magnitude', () {
      expect(ExtendedDurationUnit.values.length, 9);

      expect(ExtendedDurationUnit.year.index, 0);
      expect(ExtendedDurationUnit.month.index, 1);
      expect(ExtendedDurationUnit.week.index, 2);
      expect(ExtendedDurationUnit.day.index, 3);
      expect(ExtendedDurationUnit.hour.index, 4);
      expect(ExtendedDurationUnit.minute.index, 5);
      expect(ExtendedDurationUnit.second.index, 6);
      expect(ExtendedDurationUnit.millisecond.index, 7);
      expect(ExtendedDurationUnit.microsecond.index, 8);
    });
  });
}
