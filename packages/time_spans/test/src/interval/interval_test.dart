// packages/time_spans/test/src/interval/interval_test.dart

import 'package:test/test.dart';
import 'package:time_spans/src/interval/interval.dart';

/// Minimal concrete subtype: `base` requires `extends`, and giving the
/// abstract class an inhabitant here is exactly how its members are
/// exercised until the real interval types adopt it.
final class _TestInterval extends Interval {
  const _TestInterval(super.start, super.end);
}

void main() {
  group(Interval, () {
    // Runtime-derived endpoints keep the construction from being
    // const-canonicalized, so the base constructor line records hits.
    final start = DateTime.utc(2026, 1, 1);
    final end = DateTime.utc(2026, 1, 2, 6);

    test('stores the inclusive start and exclusive end', () {
      final interval = _TestInterval(start, end);

      expect(interval.start, start);
      expect(interval.end, end);
    });

    group('exact', () {
      test('is the anchored length between start and end', () {
        final interval = _TestInterval(start, end);

        expect(interval.exact, const Duration(days: 1, hours: 6));
      });

      test('is zero for an empty span', () {
        final interval = _TestInterval(start, start);

        expect(interval.exact, Duration.zero);
      });

      test('is negative when end precedes start', () {
        // Pins current behavior: the base does not validate ordering, so
        // an inverted span yields a negative duration. If ordering ever
        // becomes a constructor invariant, this test is the one to flip.
        final interval = _TestInterval(end, start);

        expect(interval.exact, -const Duration(days: 1, hours: 6));
      });
    });
  });
}
