// packages/time_spans/test/src/comparison/datetime_order_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:time_spans/src/comparison/datetime_order.dart';

void main() {
  group('DateTimeOrder', () {
    test('contains exactly 3 values in the expected order', () {
      expect(DateTimeOrder.values.length, 3);
      expect(DateTimeOrder.before.index, 0);
      expect(DateTimeOrder.now.index, 1);
      expect(DateTimeOrder.after.index, 2);
    });

    group('direction', () {
      test(
        'returns DateTimeOrder.before when startEvent is before endEvent',
        () {
          final startEvent = DateTime(2026, 8, 17, 10, 0, 0);
          final endEvent = DateTime(2026, 8, 18, 10, 0, 0);

          final result = DateTimeOrder.direction(startEvent, endEvent);

          expect(result, DateTimeOrder.before);
        },
      );

      test('returns DateTimeOrder.after when startEvent is after endEvent', () {
        final startEvent = DateTime(2026, 8, 19, 10, 0, 0);
        final endEvent = DateTime(2026, 8, 18, 10, 0, 0);

        final result = DateTimeOrder.direction(startEvent, endEvent);

        expect(result, DateTimeOrder.after);
      });

      test(
        'returns DateTimeOrder.now when startEvent is at the exact same time as endEvent',
        () {
          final startEvent = DateTime(2026, 8, 18, 1, 31, 9);
          final endEvent = DateTime(2026, 8, 18, 1, 31, 9);

          final result = DateTimeOrder.direction(startEvent, endEvent);

          expect(result, DateTimeOrder.now);
        },
      );

      test('returns DateTimeOrder.now for identical instances', () {
        final time = DateTime(2026, 8, 18, 1, 31, 9);

        // Ensure identity equality also routes to 'now'
        final result = DateTimeOrder.direction(time, time);

        expect(result, DateTimeOrder.now);
      });
    });
  });
}
