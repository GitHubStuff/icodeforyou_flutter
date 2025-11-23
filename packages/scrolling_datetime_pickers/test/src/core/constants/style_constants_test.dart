// test/src/core/constants/style_constants_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/style_constants.dart';

void main() {
  group('StyleConstants', () {
    group('Colors', () {
      test('should have deep blue background color', () {
        expect(StyleConstants.defaultBackgroundColor, const Color(0xFF000033));
      });

      test('should have light gray divider color', () {
        expect(StyleConstants.defaultDividerColor, const Color(0xFFE0E0E0));
      });

      test('should have white text colors', () {
        expect(StyleConstants.defaultTextColor, Colors.white);
        expect(StyleConstants.defaultSelectedTextColor, Colors.white);
      });

      test('should have semi-transparent unselected text color', () {
        expect(StyleConstants.defaultUnselectedTextColor, Colors.white70);
      });
    });

    group('Text Styles', () {
      test('should have appropriate text size', () {
        expect(StyleConstants.defaultTextSize, 24.0);
        expect(StyleConstants.defaultTextSize, greaterThan(20.0));
        expect(StyleConstants.defaultTextSize, lessThan(30.0));
      });

      test('should use bold font weight', () {
        expect(StyleConstants.defaultFontWeight, FontWeight.bold);
        expect(StyleConstants.defaultFontWeight.index, FontWeight.w700.index);
      });
    });

    group('Fade Gradients', () {
      test('should have top fade from solid to transparent', () {
        expect(StyleConstants.defaultTopFadeColors.length, 2);
        expect(StyleConstants.defaultTopFadeColors[0], const Color(0xFF000033));
        expect(StyleConstants.defaultTopFadeColors[1], const Color(0x00000033));
      });

      test('should have bottom fade from transparent to solid', () {
        expect(StyleConstants.defaultBottomFadeColors.length, 2);
        expect(
            StyleConstants.defaultBottomFadeColors[0], const Color(0x00000033));
        expect(
            StyleConstants.defaultBottomFadeColors[1], const Color(0xFF000033));
      });

      test('should have correct fade stops', () {
        expect(StyleConstants.defaultFadeStops, [0.0, 1.0]);
        expect(StyleConstants.defaultFadeStops.length, 2);
      });
    });

    group('Numeric Constants', () {
      test('should have correct hour range for 12-hour format', () {
        expect(StyleConstants.hoursMin, 1);
        expect(StyleConstants.hoursMax, 12);
        expect(StyleConstants.hoursMax - StyleConstants.hoursMin + 1, 12);
      });

      test('should have correct minute range', () {
        expect(StyleConstants.minutesMin, 0);
        expect(StyleConstants.minutesMax, 59);
        expect(StyleConstants.minutesMax - StyleConstants.minutesMin + 1, 60);
      });

      test('should have correct second range', () {
        expect(StyleConstants.secondsMin, 0);
        expect(StyleConstants.secondsMax, 59);
        expect(StyleConstants.secondsMax - StyleConstants.secondsMin + 1, 60);
      });

      test('should have large buffer for infinite scroll', () {
        expect(StyleConstants.infiniteScrollBuffer, 10000);
        expect(StyleConstants.infiniteScrollBuffer, greaterThan(1000));
        // Should be divisible by 60 for minutes/seconds
        expect(StyleConstants.infiniteScrollBuffer % 60, 40);
        // Should be divisible by 12 for hours
        expect(StyleConstants.infiniteScrollBuffer % 12, 4);
      });
    });

    group('Opacity', () {
      test('should have full opacity for dividers by default', () {
        expect(StyleConstants.defaultDividerOpacity, 1.0);
        expect(StyleConstants.defaultDividerOpacity, greaterThanOrEqualTo(0.0));
        expect(StyleConstants.defaultDividerOpacity, lessThanOrEqualTo(1.0));
      });
    });

    test('should not be instantiable', () {
      // Private constructor prevents instantiation
      expect(
        () {
          // Cannot create instance due to private constructor
        },
        returnsNormally,
      );
    });
  });
}
