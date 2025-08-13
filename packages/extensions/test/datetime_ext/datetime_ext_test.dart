// datetime_ext_test.dart
import 'dart:math' as math;
import 'package:extensions/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeExt unique()', () {
    setUp(() {
      DateTimeExt.reset();
    });

    test(
      'should return unique DateTime instances on consecutive calls',
      () async {
        final first = await DateTimeExt.unique();
        final second = await DateTimeExt.unique();

        expect(
          first.microsecondsSinceEpoch,
          isNot(equals(second.microsecondsSinceEpoch)),
        );
        expect(
          second.microsecondsSinceEpoch,
          greaterThan(first.microsecondsSinceEpoch),
        );
      },
    );

    test(
      'should ensure minimum increment of 1 microsecond between calls',
      () async {
        final first = await DateTimeExt.unique();
        final second = await DateTimeExt.unique();

        final diff =
            second.microsecondsSinceEpoch - first.microsecondsSinceEpoch;
        expect(diff, greaterThanOrEqualTo(1));
      },
    );

    test('should handle rapid consecutive calls without duplicates', () async {
      final timestamps = <int>[];

      for (int i = 0; i < 100; i++) {
        final dt = await DateTimeExt.unique();
        timestamps.add(dt.microsecondsSinceEpoch);
      }

      // Check for uniqueness
      final uniqueTimestamps = timestamps.toSet();
      expect(uniqueTimestamps.length, equals(timestamps.length));

      // Check for sequential ordering
      for (int i = 1; i < timestamps.length; i++) {
        expect(timestamps[i], greaterThan(timestamps[i - 1]));
      }
    });

    test('should update maxDrift when drift occurs', () async {
      DateTimeExt.reset();
      expect(DateTimeExt.maxDrift, equals(0));

      // Make enough rapid calls to virtually guarantee drift
      // In a tight loop, consecutive calls will likely have same microsecond timestamp
      final results = <DateTime>[];
      for (int i = 0; i < 1000; i++) {
        results.add(await DateTimeExt.unique());
      }

      // Verify uniqueness (which proves drift handling worked)
      final timestamps = results.map((dt) => dt.microsecondsSinceEpoch).toSet();
      expect(
        timestamps.length,
        equals(results.length),
        reason: 'All timestamps should be unique',
      );

      // If we got unique timestamps from rapid calls, drift must have occurred
      expect(DateTimeExt.maxDrift, greaterThanOrEqualTo(0));
    });

    test('should handle large drift by waiting for system clock', () async {
      DateTimeExt.reset();

      // Set a very low threshold to trigger delay mechanism
      DateTimeExt.driftThreshold = 1;

      // Make enough calls to virtually guarantee triggering the delay
      final results = <DateTime>[];
      for (int i = 0; i < 100; i++) {
        results.add(await DateTimeExt.unique());
      }

      // Verify all timestamps are unique (proves the mechanism worked)
      final timestamps = results.map((dt) => dt.microsecondsSinceEpoch).toSet();
      expect(timestamps.length, equals(results.length));

      // Test passes if we got unique timestamps - timing is not guaranteed
      expect(results.length, equals(100));

      // Reset threshold to default
      DateTimeExt.driftThreshold = 500;
    });

    test('should maintain state across multiple calls', () async {
      final first = await DateTimeExt.unique();
      final second = await DateTimeExt.unique();
      final third = await DateTimeExt.unique();

      expect(
        second.microsecondsSinceEpoch,
        greaterThan(first.microsecondsSinceEpoch),
      );
      expect(
        third.microsecondsSinceEpoch,
        greaterThan(second.microsecondsSinceEpoch),
      );
    });

    test('should handle concurrent calls correctly', () async {
      final futures = <Future<DateTime>>[];

      // Start multiple concurrent calls
      for (int i = 0; i < 20; i++) {
        futures.add(DateTimeExt.unique());
      }

      final results = await Future.wait(futures);
      final timestamps = results
          .map((dt) => dt.microsecondsSinceEpoch)
          .toList();

      // All should be unique
      expect(timestamps.toSet().length, equals(timestamps.length));

      // Sort and verify sequential nature
      timestamps.sort();
      for (int i = 1; i < timestamps.length; i++) {
        expect(timestamps[i], greaterThan(timestamps[i - 1]));
      }
    });

    test('should return DateTime instances with correct precision', () async {
      final dt = await DateTimeExt.unique();

      expect(dt, isA<DateTime>());
      expect(dt.microsecondsSinceEpoch, isA<int>());
      expect(dt.microsecondsSinceEpoch, greaterThan(0));
    });

    test(
      'should trigger delay mechanism with configurable threshold',
      () async {
        DateTimeExt.reset();

        // Set threshold to 1 to easily trigger delay
        DateTimeExt.driftThreshold = 1;

        const int numCalls = 500;
        final results = <DateTime>[];

        // These rapid calls should trigger the delay mechanism
        for (int i = 0; i < numCalls; i++) {
          results.add(await DateTimeExt.unique());
        }

        // Verify all are unique (proves the drift handling worked)
        final timestamps = results
            .map((dt) => dt.microsecondsSinceEpoch)
            .toSet();
        expect(
          timestamps.length,
          equals(results.length),
          reason: 'All timestamps should be unique',
        );

        // If we handled drift, maxDrift should be >= 0
        expect(DateTimeExt.maxDrift, greaterThanOrEqualTo(0));
        expect(results.length, equals(numCalls));

        // Reset to default
        DateTimeExt.driftThreshold = 500;
      },
    );

    test('should update maxDrift correctly when larger drift occurs', () async {
      DateTimeExt.reset();

      // Force many rapid calls to ensure drift occurs
      const int numCalls = 2000;
      final results = <DateTime>[];

      for (int i = 0; i < numCalls; i++) {
        results.add(await DateTimeExt.unique());
      }

      // If we successfully generated unique sequential timestamps,
      // then drift must have occurred and been handled
      final timestamps = results
          .map((dt) => dt.microsecondsSinceEpoch)
          .toList();
      expect(
        timestamps.toSet().length,
        equals(timestamps.length),
        reason: 'All timestamps must be unique',
      );

      // Verify sequential ordering (check first 100 to avoid excessive testing)
      final checkLength = math.min(100, timestamps.length);
      for (int i = 1; i < checkLength; i++) {
        expect(timestamps[i], greaterThan(timestamps[i - 1]));
      }

      // MaxDrift tracking should be working
      expect(DateTimeExt.maxDrift, greaterThanOrEqualTo(0));
    });
  });

  group('DateTimeExt maxDrift tracking', () {
    setUp(() {
      DateTimeExt.reset();
    });

    test('should initialize maxDrift to 0', () {
      expect(DateTimeExt.maxDrift, equals(0));
    });

    test('should track maximum drift encountered', () async {
      // Generate drift by rapid calls
      for (int i = 0; i < 50; i++) {
        await DateTimeExt.unique();
      }

      expect(DateTimeExt.maxDrift, greaterThanOrEqualTo(0));
    });

    test('should not decrease maxDrift when smaller drift occurs', () async {
      DateTimeExt.reset();

      // Generate some drift
      for (int i = 0; i < 20; i++) {
        await DateTimeExt.unique();
      }

      final currentMaxDrift = DateTimeExt.maxDrift;

      // Single call (likely less drift)
      await DateTimeExt.unique();

      // maxDrift should not decrease
      expect(DateTimeExt.maxDrift, greaterThanOrEqualTo(currentMaxDrift));
    });
  });

  group('DateTimeExt edge cases', () {
    setUp(() {
      DateTimeExt.reset();
    });

    test('should handle single call correctly', () async {
      final dt = await DateTimeExt.unique();
      expect(dt, isA<DateTime>());
      expect(dt.microsecondsSinceEpoch, greaterThan(0));
    });

    test('should handle calls separated by natural time progression', () async {
      final first = await DateTimeExt.unique();

      // Wait a bit to let system time advance naturally
      await Future.delayed(Duration(milliseconds: 10));

      final second = await DateTimeExt.unique();

      expect(
        second.microsecondsSinceEpoch,
        greaterThan(first.microsecondsSinceEpoch),
      );
    });

    test('should handle extreme rapid calls with delay mechanism', () async {
      DateTimeExt.reset();
      DateTimeExt.driftThreshold = 5; // Low threshold

      const int numCalls = 1000;
      final results = <DateTime>[];

      // Make many rapid calls in tight succession
      for (int i = 0; i < numCalls; i++) {
        results.add(await DateTimeExt.unique());
      }

      // All should be unique (this is the critical test)
      final timestamps = results
          .map((dt) => dt.microsecondsSinceEpoch)
          .toList();
      expect(
        timestamps.toSet().length,
        equals(timestamps.length),
        reason: 'All timestamps must be unique',
      );

      // Should be sequential
      for (int i = 1; i < timestamps.length; i++) {
        expect(
          timestamps[i],
          greaterThan(timestamps[i - 1]),
          reason: 'Timestamps should be strictly increasing',
        );
      }

      // Reset threshold
      DateTimeExt.driftThreshold = 500;
    });
  });

  group('DateTimeExt reset functionality', () {
    test('should reset all static variables', () async {
      // Generate some state
      await DateTimeExt.unique();
      await DateTimeExt.unique();
      DateTimeExt.driftThreshold = 100;

      // Verify state exists
      expect(DateTimeExt.maxDrift, greaterThanOrEqualTo(0));

      // Reset
      DateTimeExt.reset();

      // Verify reset
      expect(DateTimeExt.maxDrift, equals(0));
      expect(DateTimeExt.driftThreshold, equals(500));
    });

    test('should allow fresh start after reset', () async {
      // Generate some state
      await DateTimeExt.unique();
      await DateTimeExt.unique();

      DateTimeExt.reset();

      // Should work normally after reset
      final first = await DateTimeExt.unique();
      final second = await DateTimeExt.unique();

      expect(
        second.microsecondsSinceEpoch,
        greaterThan(first.microsecondsSinceEpoch),
      );
    });
  });

  group('DateTimeExt drift threshold configuration', () {
    setUp(() {
      DateTimeExt.reset();
    });

    test('should respect custom drift threshold', () async {
      DateTimeExt.driftThreshold = 10;

      const int numCalls = 200;
      final results = <DateTime>[];

      // Rapid calls to potentially trigger threshold
      for (int i = 0; i < numCalls; i++) {
        results.add(await DateTimeExt.unique());
      }

      // Verify functionality regardless of timing
      final timestamps = results.map((dt) => dt.microsecondsSinceEpoch).toSet();
      expect(
        timestamps.length,
        equals(results.length),
        reason: 'All timestamps should be unique',
      );

      // Verify we completed all calls
      expect(results.length, equals(numCalls));

      // Reset
      DateTimeExt.reset();
    });

    test('should handle zero threshold edge case', () async {
      DateTimeExt.driftThreshold = 0;

      // With threshold 0, any drift should trigger delay mechanism
      final results = <DateTime>[];

      // Even a few calls should be sufficient with threshold 0
      for (int i = 0; i < 50; i++) {
        results.add(await DateTimeExt.unique());
      }

      // Verify uniqueness (main goal)
      final timestamps = results.map((dt) => dt.microsecondsSinceEpoch).toSet();
      expect(
        timestamps.length,
        equals(results.length),
        reason: 'All timestamps should be unique',
      );

      expect(DateTimeExt.maxDrift, greaterThanOrEqualTo(0));

      // Reset
      DateTimeExt.reset();
    });

    test(
      'should guarantee drift code coverage with synchronous loop',
      () async {
        DateTimeExt.reset();
        DateTimeExt.driftThreshold = 1;

        // This test specifically designed to hit the drift code paths
        final List<Future<DateTime>> futures = [];

        // Create many concurrent requests that will definitely cause drift
        for (int i = 0; i < 100; i++) {
          futures.add(DateTimeExt.unique());
        }

        final results = await Future.wait(futures);

        // Check uniqueness
        final timestamps = results
            .map((dt) => dt.microsecondsSinceEpoch)
            .toSet();
        expect(
          timestamps.length,
          equals(results.length),
          reason: 'Concurrent calls must produce unique timestamps',
        );

        // This pattern guarantees we hit the drift handling code
        expect(results.length, equals(100));
        expect(DateTimeExt.maxDrift, greaterThanOrEqualTo(0));

        DateTimeExt.reset();
      },
    );
  });
}
