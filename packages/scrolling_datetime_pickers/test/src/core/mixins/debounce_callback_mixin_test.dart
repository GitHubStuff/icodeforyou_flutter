// test/src/core/mixins/debounce_callback_mixin_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/timing_constants.dart';
import 'package:scrolling_datetime_pickers/src/core/mixins/timing_constants.dart';

// Test class to use the mixin
class TestDebounce with DebounceCallbackMixin {}

void main() {
  group('DebounceCallbackMixin', () {
    late TestDebounce testDebounce;

    setUp(() {
      testDebounce = TestDebounce();
    });

    tearDown(() {
      testDebounce.disposeDebounce();
    });

    test('should execute callback after default debounce duration', () async {
      bool callbackExecuted = false;

      testDebounce.debounceCallback(() {
        callbackExecuted = true;
      });

      expect(callbackExecuted, false);
      expect(testDebounce.isDebouncing, true);

      // Wait for default duration
      await Future.delayed(TimingConstants.callbackDebounce);
      await Future.delayed(const Duration(milliseconds: 50)); // Buffer

      expect(callbackExecuted, true);
      expect(testDebounce.isDebouncing, false);
    });

    test('should execute callback after custom duration', () async {
      bool callbackExecuted = false;
      const customDuration = Duration(milliseconds: 100);

      testDebounce.debounceCallback(
        () {
          callbackExecuted = true;
        },
        duration: customDuration,
      );

      expect(callbackExecuted, false);
      expect(testDebounce.isDebouncing, true);

      // Wait less than custom duration
      await Future.delayed(const Duration(milliseconds: 50));
      expect(callbackExecuted, false);

      // Wait for full custom duration
      await Future.delayed(const Duration(milliseconds: 60));

      expect(callbackExecuted, true);
      expect(testDebounce.isDebouncing, false);
    });

    test('should cancel previous callback when called again', () async {
      int callCount = 0;

      // First call
      testDebounce.debounceCallback(() {
        callCount++;
      });

      // Wait a bit but not full duration
      await Future.delayed(const Duration(milliseconds: 100));

      // Second call should cancel first
      testDebounce.debounceCallback(() {
        callCount += 10;
      });

      // Wait for debounce to complete
      await Future.delayed(TimingConstants.callbackDebounce);
      await Future.delayed(const Duration(milliseconds: 50));

      // Only second callback should execute
      expect(callCount, 10);
    });

    test('should cancel debounce when cancelDebounce is called', () async {
      bool callbackExecuted = false;

      testDebounce.debounceCallback(() {
        callbackExecuted = true;
      });

      expect(testDebounce.isDebouncing, true);

      // Cancel before it executes
      await Future.delayed(const Duration(milliseconds: 100));
      testDebounce.cancelDebounce();

      expect(testDebounce.isDebouncing, false);

      // Wait to ensure callback doesn't execute
      await Future.delayed(TimingConstants.callbackDebounce);

      expect(callbackExecuted, false);
    });

    test('should execute immediately when executeImmediately is called', () {
      int callCount = 0;

      // Set up a debounced callback
      testDebounce.debounceCallback(() {
        callCount++;
      });

      expect(callCount, 0);
      expect(testDebounce.isDebouncing, true);

      // Execute different callback immediately
      testDebounce.executeImmediately(() {
        callCount += 10;
      });

      expect(callCount, 10);
      expect(testDebounce.isDebouncing, false);
    });

    test('isDebouncing should return false when no timer', () {
      expect(testDebounce.isDebouncing, false);
    });

    test('isDebouncing should return true when timer is active', () {
      testDebounce.debounceCallback(() {});
      expect(testDebounce.isDebouncing, true);
    });

    test('isDebouncing should return false after timer completes', () async {
      testDebounce.debounceCallback(() {});

      await Future.delayed(TimingConstants.callbackDebounce);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(testDebounce.isDebouncing, false);
    });

    test('disposeDebounce should cancel pending callbacks', () async {
      bool callbackExecuted = false;

      testDebounce.debounceCallback(() {
        callbackExecuted = true;
      });

      expect(testDebounce.isDebouncing, true);

      // Dispose before callback executes
      await Future.delayed(const Duration(milliseconds: 100));
      testDebounce.disposeDebounce();

      expect(testDebounce.isDebouncing, false);

      // Wait to ensure callback doesn't execute
      await Future.delayed(TimingConstants.callbackDebounce);

      expect(callbackExecuted, false);
    });

    test('cancelDebounce should handle null timer', () {
      // Should not throw when timer is null
      expect(() => testDebounce.cancelDebounce(), returnsNormally);
      expect(testDebounce.isDebouncing, false);
    });

    test('multiple rapid calls should only execute last callback', () async {
      final results = <int>[];

      for (int i = 0; i < 5; i++) {
        testDebounce.debounceCallback(() {
          results.add(i);
        });
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Wait for debounce to complete
      await Future.delayed(TimingConstants.callbackDebounce);
      await Future.delayed(const Duration(milliseconds: 50));

      // Only the last callback should have executed
      expect(results, [4]);
    });
  });
}
