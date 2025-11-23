// test/src/core/mixins/infinite_scroll_mixin_test.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/core/mixins/infinite_scroll_mixin.dart';

// Test class to use the mixin
class _TestInfiniteScroll with InfiniteScrollMixin {}

void main() {
  group('InfiniteScrollMixin', () {
    late _TestInfiniteScroll testScroll;

    setUp(() {
      testScroll = _TestInfiniteScroll();
    });

    group('calculateActualIndex', () {
      test('should calculate correct actual index', () {
        expect(testScroll.calculateActualIndex(0, 12), 0);
        expect(testScroll.calculateActualIndex(5, 12), 5);
        expect(testScroll.calculateActualIndex(12, 12), 0);
        expect(testScroll.calculateActualIndex(13, 12), 1);
        expect(testScroll.calculateActualIndex(24, 12), 0);
        expect(testScroll.calculateActualIndex(25, 12), 1);
      });

      test('should handle large scroll positions', () {
        expect(testScroll.calculateActualIndex(10000, 60), 40);
        expect(testScroll.calculateActualIndex(10001, 60), 41);
      });
    });

    group('calculateInitialScrollPosition', () {
      test('should calculate middle buffer position', () {
        final position = testScroll.calculateInitialScrollPosition(5, 12);
        final actualIndex = testScroll.calculateActualIndex(position, 12);

        expect(actualIndex, 5);
        expect(position, greaterThan(1000)); // Should be in middle of buffer
        expect(position, lessThan(9000));
      });

      test('should handle different item counts', () {
        final position60 = testScroll.calculateInitialScrollPosition(30, 60);
        final position12 = testScroll.calculateInitialScrollPosition(6, 12);

        expect(testScroll.calculateActualIndex(position60, 60), 30);
        expect(testScroll.calculateActualIndex(position12, 12), 6);
      });
    });

    group('getItemValue', () {
      test('should get correct item value for range', () {
        expect(testScroll.getItemValue(0, 0, 59), 0);
        expect(testScroll.getItemValue(30, 0, 59), 30);
        expect(testScroll.getItemValue(59, 0, 59), 59);
        expect(testScroll.getItemValue(60, 0, 59), 0);
        expect(testScroll.getItemValue(120, 0, 59), 0);
      });
    });

    group('getHourValue', () {
      test('should return 12 for index 0', () {
        expect(testScroll.getHourValue(0), 12);
        expect(testScroll.getHourValue(12), 12);
        expect(testScroll.getHourValue(24), 12);
      });

      test('should return 1-11 for other indices', () {
        for (int i = 1; i <= 11; i++) {
          expect(testScroll.getHourValue(i), i);
          expect(testScroll.getHourValue(i + 12), i);
          expect(testScroll.getHourValue(i + 24), i);
        }
      });
    });

    group('getMinuteValue', () {
      test('should return 0-59 for minutes', () {
        expect(testScroll.getMinuteValue(0), 0);
        expect(testScroll.getMinuteValue(30), 30);
        expect(testScroll.getMinuteValue(59), 59);
        expect(testScroll.getMinuteValue(60), 0);
        expect(testScroll.getMinuteValue(119), 59);
        expect(testScroll.getMinuteValue(120), 0);
      });
    });

    group('getSecondValue', () {
      test('should return 0-59 for seconds', () {
        expect(testScroll.getSecondValue(0), 0);
        expect(testScroll.getSecondValue(30), 30);
        expect(testScroll.getSecondValue(59), 59);
        expect(testScroll.getSecondValue(60), 0);
        expect(testScroll.getSecondValue(119), 59);
        expect(testScroll.getSecondValue(120), 0);
      });
    });

    group('scroll position calculations', () {
      test('getHourScrollPosition should calculate correct position', () {
        final pos12 = testScroll.getHourScrollPosition(12);
        final pos1 = testScroll.getHourScrollPosition(1);
        final pos6 = testScroll.getHourScrollPosition(6);

        expect(testScroll.getHourValue(pos12), 12);
        expect(testScroll.getHourValue(pos1), 1);
        expect(testScroll.getHourValue(pos6), 6);
      });

      test('getMinuteScrollPosition should calculate correct position', () {
        final pos0 = testScroll.getMinuteScrollPosition(0);
        final pos30 = testScroll.getMinuteScrollPosition(30);
        final pos59 = testScroll.getMinuteScrollPosition(59);

        expect(testScroll.getMinuteValue(pos0), 0);
        expect(testScroll.getMinuteValue(pos30), 30);
        expect(testScroll.getMinuteValue(pos59), 59);
      });

      test('getSecondScrollPosition should calculate correct position', () {
        final pos0 = testScroll.getSecondScrollPosition(0);
        final pos30 = testScroll.getSecondScrollPosition(30);
        final pos59 = testScroll.getSecondScrollPosition(59);

        expect(testScroll.getSecondValue(pos0), 0);
        expect(testScroll.getSecondValue(pos30), 30);
        expect(testScroll.getSecondValue(pos59), 59);
      });
    });

    group('needsRecentering', () {
      test('should return false when controller has no clients', () {
        final controller = FixedExtentScrollController();
        expect(testScroll.needsRecentering(controller), false);
        controller.dispose();
      });

      // Note: needsRecentering requires controller.hasClients to be true,
      // which needs the controller to be attached to an actual scroll view.
      // This would require a widget test with a CupertinoPicker.
    });

    group('formatting', () {
      test('formatPickerValue should pad zeros when requested', () {
        expect(testScroll.formatPickerValue(5, padZero: true), '05');
        expect(testScroll.formatPickerValue(10, padZero: true), '10');
        expect(testScroll.formatPickerValue(5, padZero: false), '5');
        expect(testScroll.formatPickerValue(10, padZero: false), '10');
      });

      test('formatHour should not pad zeros', () {
        expect(testScroll.formatHour(1), '1');
        expect(testScroll.formatHour(9), '9');
        expect(testScroll.formatHour(10), '10');
        expect(testScroll.formatHour(12), '12');
      });

      test('formatMinute should pad zeros', () {
        expect(testScroll.formatMinute(0), '00');
        expect(testScroll.formatMinute(5), '05');
        expect(testScroll.formatMinute(10), '10');
        expect(testScroll.formatMinute(59), '59');
      });

      test('formatSecond should pad zeros', () {
        expect(testScroll.formatSecond(0), '00');
        expect(testScroll.formatSecond(5), '05');
        expect(testScroll.formatSecond(10), '10');
        expect(testScroll.formatSecond(59), '59');
      });
    });
  });
}
