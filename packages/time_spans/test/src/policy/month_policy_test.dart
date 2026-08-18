// packages/time_spans/test/src/policy/month_policy_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:time_spans/src/policy/month_policy.dart';

void main() {
  group('MonthPolicy', () {
    test('contains exactly 2 values in the expected order', () {
      expect(MonthPolicy.values.length, 2);

      expect(MonthPolicy.clamp.index, 0);
      expect(MonthPolicy.overflow.index, 1);
    });
  });
}
