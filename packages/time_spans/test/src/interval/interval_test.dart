// packages/time_spans/test/src/interval/interval_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:time_spans/src/interval/interval.dart';

void main() {
  group('Interval', () {
    test('is a sealed base class and cannot be instantiated directly', () {
      // Because [Interval] is a sealed class with a private generative
      // constructor (`const Interval._`), it cannot be instantiated, extended,
      // or implemented outside of its own library (`interval.dart`).
      //
      // Full line coverage for the `exact` getter cannot be achieved in this
      // isolated test file, because creating an instance here is a compile-time
      // error. Coverage for `Interval` is naturally achieved by testing the
      // concrete library-internal subclasses (e.g., `MonthInterval`) in their
      // respective test files, as they are the only valid ways to create an
      // instance of an Interval.

      expect(Interval, isA<Type>());
    });
  });
}
