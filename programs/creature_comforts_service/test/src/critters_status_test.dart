// packages/creature_comforts_service/test/src/critters_status_test.dart
import '../../lib/creature_comforts_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('crittersStatusFor', () {
    final now = DateTime.utc(2026, 5, 9, 12);

    test('returns alive when lastFed is null', () {
      expect(crittersStatusFor(null, now: now), CrittersStatus.alive);
    });

    test('returns alive when lastFed equals now', () {
      expect(crittersStatusFor(now, now: now), CrittersStatus.alive);
    });

    test('returns alive when lastFed is in the future (clock skew)', () {
      final future = now.add(const Duration(hours: 1));
      expect(crittersStatusFor(future, now: now), CrittersStatus.alive);
    });

    test('returns alive when elapsed is one second under the threshold', () {
      final fed = now
          .subtract(crittersDeathThreshold)
          .add(const Duration(seconds: 1));
      expect(crittersStatusFor(fed, now: now), CrittersStatus.alive);
    });

    test('returns alive when elapsed equals the threshold exactly', () {
      // The check is `elapsed > threshold`, so the boundary itself is alive.
      final fed = now.subtract(crittersDeathThreshold);
      expect(crittersStatusFor(fed, now: now), CrittersStatus.alive);
    });

    test('returns dead when elapsed is one second over the threshold', () {
      final fed = now
          .subtract(crittersDeathThreshold)
          .subtract(const Duration(seconds: 1));
      expect(crittersStatusFor(fed, now: now), CrittersStatus.dead);
    });

    test('returns dead when elapsed greatly exceeds the threshold', () {
      final fed = now.subtract(const Duration(days: 30));
      expect(crittersStatusFor(fed, now: now), CrittersStatus.dead);
    });

    test('handles non-UTC inputs by normalizing to UTC', () {
      // Local DateTime: comparison must still work because both sides are
      // converted to UTC inside the function.
      final fed = DateTime(2026, 5, 1, 12).subtract(const Duration(days: 30));
      final reference = DateTime(2026, 5, 1, 12);
      expect(crittersStatusFor(fed, now: reference), CrittersStatus.dead);
    });

    test('falls back to DateTime.now() when now is omitted', () {
      // We can't pin wall-clock time in this branch, but a recent feeding
      // must always classify as alive — that exercises the `now ?? DateTime.now()`
      // path without making the test flaky.
      final justNow = DateTime.now().subtract(const Duration(seconds: 1));
      expect(crittersStatusFor(justNow), CrittersStatus.alive);
    });

    test(
      'crittersDeathThreshold is exposed as 7 days',
      () => expect(crittersDeathThreshold, const Duration(days: 7)),
    );
  });
}
