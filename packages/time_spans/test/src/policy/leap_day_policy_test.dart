// packages/time_spans/test/src/policy/leap_day_policy_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:time_spans/src/policy/leap_day_policy.dart';

void main() {
  group('LeapDayPolicy', () {
    test('contains exactly 2 values in the expected order', () {
      expect(LeapDayPolicy.values.length, 2);

      expect(LeapDayPolicy.feb28.index, 0);
      expect(LeapDayPolicy.mar1.index, 1);
    });
  });
}
