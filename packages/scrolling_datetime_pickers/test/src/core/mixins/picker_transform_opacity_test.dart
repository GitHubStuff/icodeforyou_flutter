// test/src/core/mixins/picker_transform_opacity_test.dart

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/mixins/picker_transform_mixin.dart';

// Test class to use the mixin
class _TestTransform with PickerTransformMixin {}

void main() {
  group('PickerTransformMixin Opacity and Conversions', () {
    late _TestTransform testTransform;

    setUp(() {
      testTransform = _TestTransform();
    });

    group('calculateItemOpacity', () {
      test('should return 1.0 when fade is disabled', () {
        final opacity = testTransform.calculateItemOpacity(
          50.0,
          200.0,
          false, // Fade disabled
          40.0,
        );

        expect(opacity, 1.0);
      });

      test('should return 1.0 for items within fade distance', () {
        final opacity = testTransform.calculateItemOpacity(
          100.0, // At center
          200.0, // Viewport height
          true,
          40.0,
        );

        expect(opacity, 1.0);
      });

      test('should return 1.0 for items close to center', () {
        // Item at center + 30 (within 40 fade distance)
        final opacity1 = testTransform.calculateItemOpacity(
          130.0,
          200.0,
          true,
          40.0,
        );
        expect(opacity1, 1.0);

        // Item at center - 30 (within 40 fade distance)
        final opacity2 = testTransform.calculateItemOpacity(
          70.0,
          200.0,
          true,
          40.0,
        );
        expect(opacity2, 1.0);
      });

      test('should calculate fade for items outside fade distance', () {
        final opacity = testTransform.calculateItemOpacity(
          0.0, // At top
          200.0, // Viewport height (center at 100)
          true,
          40.0, // Fade distance
        );

        // Distance from center is 100, fade starts at 40
        expect(opacity, lessThan(1.0));
        expect(opacity, greaterThanOrEqualTo(0.0));
      });

      test('should calculate correct opacity values', () {
        // Center at 100, fade distance 40
        // Items at 140+ should start fading
        final opacity1 = testTransform.calculateItemOpacity(
          150.0, // 50 from center, 10 beyond fade distance
          200.0,
          true,
          40.0,
        );

        // Fade range is 60 (100 - 40), distance beyond fade is 10
        // Expected: 1.0 - (10/60) = 0.833...
        expect(opacity1, closeTo(0.833, 0.01));

        final opacity2 = testTransform.calculateItemOpacity(
          200.0, // At edge, 100 from center
          200.0,
          true,
          40.0,
        );

        // Distance beyond fade is 60, fade range is 60
        // Expected: 1.0 - (60/60) = 0.0
        expect(opacity2, 0.0);
      });

      test('should clamp opacity between 0 and 1', () {
        final opacity = testTransform.calculateItemOpacity(
          -100.0, // Far outside viewport
          200.0,
          true,
          40.0,
        );

        expect(opacity, greaterThanOrEqualTo(0.0));
        expect(opacity, lessThanOrEqualTo(1.0));
      });

      test('should handle edge case when fade distance equals center', () {
        final opacity = testTransform.calculateItemOpacity(
          50.0,
          100.0,
          true,
          50.0, // Fade distance equals center
        );

        expect(opacity, 1.0);
      });

      test('should handle edge case when fade range is negative', () {
        final opacity = testTransform.calculateItemOpacity(
          0.0,
          100.0,
          true,
          60.0, // Fade distance > center
        );

        expect(opacity, 1.0);
      });
    });

    group('degreesToRadians', () {
      test('should convert common angles correctly', () {
        expect(testTransform.degreesToRadians(0), 0.0);
        expect(testTransform.degreesToRadians(90), math.pi / 2);
        expect(testTransform.degreesToRadians(180), math.pi);
        expect(testTransform.degreesToRadians(270), 3 * math.pi / 2);
        expect(testTransform.degreesToRadians(360), 2 * math.pi);
      });

      test('should convert arbitrary angles', () {
        expect(
          testTransform.degreesToRadians(45),
          closeTo(math.pi / 4, 0.0001),
        );
        expect(
          testTransform.degreesToRadians(30),
          closeTo(math.pi / 6, 0.0001),
        );
        expect(
          testTransform.degreesToRadians(60),
          closeTo(math.pi / 3, 0.0001),
        );
      });

      test('should handle negative angles', () {
        expect(testTransform.degreesToRadians(-90), -math.pi / 2);
        expect(testTransform.degreesToRadians(-180), -math.pi);
        expect(testTransform.degreesToRadians(-360), -2 * math.pi);
      });
    });

    group('radiansToDegrees', () {
      test('should convert common radians correctly', () {
        expect(testTransform.radiansToDegrees(0), 0.0);
        expect(testTransform.radiansToDegrees(math.pi / 2), 90.0);
        expect(testTransform.radiansToDegrees(math.pi), 180.0);
        expect(testTransform.radiansToDegrees(3 * math.pi / 2), 270.0);
        expect(testTransform.radiansToDegrees(2 * math.pi), 360.0);
      });

      test('should convert arbitrary radians', () {
        expect(
          testTransform.radiansToDegrees(math.pi / 4),
          closeTo(45.0, 0.0001),
        );
        expect(
          testTransform.radiansToDegrees(math.pi / 6),
          closeTo(30.0, 0.0001),
        );
        expect(
          testTransform.radiansToDegrees(math.pi / 3),
          closeTo(60.0, 0.0001),
        );
      });

      test('should handle negative radians', () {
        expect(testTransform.radiansToDegrees(-math.pi / 2), -90.0);
        expect(testTransform.radiansToDegrees(-math.pi), -180.0);
        expect(testTransform.radiansToDegrees(-2 * math.pi), -360.0);
      });
    });

    group('conversion symmetry', () {
      test('degrees to radians and back should preserve value', () {
        const testDegrees = [
          0.0,
          45.0,
          90.0,
          135.0,
          180.0,
          225.0,
          270.0,
          315.0,
          360.0,
          -45.0,
          -90.0,
          -180.0,
          123.456,
          789.012,
        ];

        for (final degrees in testDegrees) {
          final radians = testTransform.degreesToRadians(degrees);
          final backToDegrees = testTransform.radiansToDegrees(radians);

          expect(
            backToDegrees,
            closeTo(degrees, 0.0001),
            reason: 'Failed for $degrees degrees',
          );
        }
      });

      test('radians to degrees and back should preserve value', () {
        final testRadians = [
          0.0,
          math.pi / 6,
          math.pi / 4,
          math.pi / 3,
          math.pi / 2,
          math.pi,
          3 * math.pi / 2,
          2 * math.pi,
          -math.pi / 2,
          -math.pi,
          1.234,
          5.678,
        ];

        for (final radians in testRadians) {
          final degrees = testTransform.radiansToDegrees(radians);
          final backToRadians = testTransform.degreesToRadians(degrees);

          expect(
            backToRadians,
            closeTo(radians, 0.0001),
            reason: 'Failed for $radians radians',
          );
        }
      });
    });
  });
}
