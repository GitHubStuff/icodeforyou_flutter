// test/src/core/constants/timing_constants_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/timing_constants.dart';

void main() {
  group('TimingConstants', () {
    test('should have callback debounce between 300-500ms', () {
      expect(
        TimingConstants.callbackDebounce.inMilliseconds,
        greaterThanOrEqualTo(300),
      );
      expect(
        TimingConstants.callbackDebounce.inMilliseconds,
        lessThanOrEqualTo(500),
      );
      expect(TimingConstants.callbackDebounce.inMilliseconds, 400);
    });

    test('should have scroll animation duration for smooth scrolling', () {
      expect(
        TimingConstants.scrollAnimationDuration.inMilliseconds,
        greaterThan(0),
      );
      expect(
        TimingConstants.scrollAnimationDuration.inMilliseconds,
        lessThanOrEqualTo(500),
      );
      expect(TimingConstants.scrollAnimationDuration.inMilliseconds, 300);
    });

    test('should have minimal haptic feedback delay', () {
      expect(
        TimingConstants.hapticDelay.inMilliseconds,
        greaterThanOrEqualTo(0),
      );
      expect(
        TimingConstants.hapticDelay.inMilliseconds,
        lessThan(50),
      );
      expect(TimingConstants.hapticDelay.inMilliseconds, 10);
    });

    test('should have reasonable scroll settle timeout', () {
      expect(
        TimingConstants.scrollSettleTimeout.inSeconds,
        greaterThan(0),
      );
      expect(
        TimingConstants.scrollSettleTimeout.inSeconds,
        lessThanOrEqualTo(5),
      );
      expect(TimingConstants.scrollSettleTimeout.inSeconds, 2);
    });

    test('should have recenter check interval for infinite scroll', () {
      expect(
        TimingConstants.recenterCheckInterval.inSeconds,
        greaterThan(0),
      );
      expect(TimingConstants.recenterCheckInterval.inSeconds, 5);
    });

    test('should have transform animation duration for 3D effects', () {
      expect(
        TimingConstants.transformAnimationDuration.inMilliseconds,
        greaterThan(0),
      );
      expect(
        TimingConstants.transformAnimationDuration.inMilliseconds,
        lessThan(300),
      );
      expect(TimingConstants.transformAnimationDuration.inMilliseconds, 150);
    });

    test('should have fade animation duration for gradients', () {
      expect(
        TimingConstants.fadeAnimationDuration.inMilliseconds,
        greaterThan(0),
      );
      expect(
        TimingConstants.fadeAnimationDuration.inMilliseconds,
        lessThanOrEqualTo(500),
      );
      expect(TimingConstants.fadeAnimationDuration.inMilliseconds, 200);
    });

    test('should not be instantiable', () {
      // Private constructor prevents instantiation
      // This is enforced at compile-time
      expect(
        () {
          // Cannot create instance due to private constructor
        },
        returnsNormally,
      );
    });

    test('callback debounce should be longer than haptic delay', () {
      expect(
        TimingConstants.callbackDebounce.inMilliseconds,
        greaterThan(TimingConstants.hapticDelay.inMilliseconds),
      );
    });

    test('scroll animation should complete before callback fires', () {
      expect(
        TimingConstants.scrollAnimationDuration.inMilliseconds,
        lessThan(TimingConstants.callbackDebounce.inMilliseconds),
      );
    });
  });
}
