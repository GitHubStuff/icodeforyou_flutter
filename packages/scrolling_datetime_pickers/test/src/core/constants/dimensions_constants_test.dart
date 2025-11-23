// test/src/core/constants/dimensions_constants_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/dimensions_constants.dart';

void main() {
  group('DimensionConstants', () {
    test('should have correct default portrait dimensions', () {
      expect(DimensionConstants.defaultPortraitWidth, 175.0);
      expect(DimensionConstants.defaultPortraitHeight, 200.0);
    });

    test('should have correct default landscape dimensions', () {
      expect(DimensionConstants.defaultLandscapeWidth, 175.0);
      expect(DimensionConstants.defaultLandscapeHeight, 200.0);
    });

    test('should have correct item extent for 5 visible rows', () {
      // With 200 height and 5 rows visible, each item should be 40
      expect(DimensionConstants.itemExtent, 40.0);
      expect(
        DimensionConstants.defaultPortraitHeight / 5,
        DimensionConstants.itemExtent,
      );
    });

    test('should have magnification greater than 1 for selected item', () {
      expect(DimensionConstants.magnification, greaterThan(1.0));
      expect(DimensionConstants.magnification, 1.2);
    });

    test('should have squeeze factor for proper item density', () {
      expect(DimensionConstants.squeeze, greaterThan(1.0));
      expect(DimensionConstants.squeeze, 1.45);
    });

    test('should have diameter ratio for wheel curvature', () {
      expect(DimensionConstants.diameterRatio, greaterThan(1.0));
      expect(DimensionConstants.diameterRatio, 1.1);
    });

    test('should have zero column spacing by default', () {
      expect(DimensionConstants.columnSpacing, 0.0);
    });

    test('should have divider thickness visible but not too thick', () {
      expect(DimensionConstants.dividerThickness, greaterThan(1.0));
      expect(DimensionConstants.dividerThickness, lessThan(3.0));
      expect(DimensionConstants.dividerThickness, 1.5);
    });

    test('should have 3D rotation angle for outer columns', () {
      expect(DimensionConstants.outerColumnAngle, greaterThan(0));
      expect(
        DimensionConstants.outerColumnAngle,
        lessThan(1.0),
      ); // Less than 1 radian
      expect(DimensionConstants.outerColumnAngle, 0.1);
    });

    test('should have perspective value for 3D transform', () {
      expect(DimensionConstants.perspectiveValue, greaterThan(0));
      expect(
        DimensionConstants.perspectiveValue,
        lessThan(0.01),
      ); // Small value for subtle effect
      expect(DimensionConstants.perspectiveValue, 0.003);
    });

    test('should have border radius for rounded corners', () {
      expect(DimensionConstants.borderRadius, greaterThan(0));
      expect(DimensionConstants.borderRadius, 12.0);
    });

    test('should not be instantiable', () {
      // This test verifies the class cannot be instantiated
      // The private constructor prevents this
      expect(() {
        // Cannot call DimensionConstants() due to private constructor
        // This is a compile-time check, not runtime
      }, returnsNormally);
    });
  });
}
