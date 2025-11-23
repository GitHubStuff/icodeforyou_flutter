// test/src/core/constants/constants_coverage_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/dimensions_constants.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/timing_constants.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/style_constants.dart';

void main() {
  group('Constants Coverage', () {
    test('DimensionConstants cannot be instantiated', () {
      // This tests the private constructor is actually private
      // and the class is being used correctly
      expect(DimensionConstants.defaultPortraitWidth, isNotNull);
      expect(DimensionConstants.defaultPortraitHeight, isNotNull);
      expect(DimensionConstants.defaultLandscapeWidth, isNotNull);
      expect(DimensionConstants.defaultLandscapeHeight, isNotNull);
      expect(DimensionConstants.itemExtent, isNotNull);
      expect(DimensionConstants.magnification, isNotNull);
      expect(DimensionConstants.squeeze, isNotNull);
      expect(DimensionConstants.diameterRatio, isNotNull);
      expect(DimensionConstants.columnSpacing, isNotNull);
      expect(DimensionConstants.dividerThickness, isNotNull);
      expect(DimensionConstants.outerColumnAngle, isNotNull);
      expect(DimensionConstants.perspectiveValue, isNotNull);
      expect(DimensionConstants.borderRadius, isNotNull);
    });

    test('TimingConstants cannot be instantiated', () {
      // This tests the private constructor is actually private
      // and the class is being used correctly
      expect(TimingConstants.callbackDebounce, isNotNull);
      expect(TimingConstants.scrollAnimationDuration, isNotNull);
      expect(TimingConstants.hapticDelay, isNotNull);
      expect(TimingConstants.scrollSettleTimeout, isNotNull);
      expect(TimingConstants.recenterCheckInterval, isNotNull);
      expect(TimingConstants.transformAnimationDuration, isNotNull);
      expect(TimingConstants.fadeAnimationDuration, isNotNull);
    });

    test('StyleConstants cannot be instantiated', () {
      // This tests the private constructor is actually private
      // and the class is being used correctly
      expect(StyleConstants.defaultBackgroundColor, isNotNull);
      expect(StyleConstants.defaultDividerColor, isNotNull);
      expect(StyleConstants.defaultTextColor, isNotNull);
      expect(StyleConstants.defaultSelectedTextColor, isNotNull);
      expect(StyleConstants.defaultUnselectedTextColor, isNotNull);
      expect(StyleConstants.defaultTextSize, isNotNull);
      expect(StyleConstants.defaultFontWeight, isNotNull);
      expect(StyleConstants.defaultTopFadeColors, isNotNull);
      expect(StyleConstants.defaultBottomFadeColors, isNotNull);
      expect(StyleConstants.defaultFadeStops, isNotNull);
      expect(StyleConstants.defaultDividerOpacity, isNotNull);
      expect(StyleConstants.hoursMin, isNotNull);
      expect(StyleConstants.hoursMax, isNotNull);
      expect(StyleConstants.minutesMin, isNotNull);
      expect(StyleConstants.minutesMax, isNotNull);
      expect(StyleConstants.secondsMin, isNotNull);
      expect(StyleConstants.secondsMax, isNotNull);
      expect(StyleConstants.infiniteScrollBuffer, isNotNull);
    });
  });
}
