// lib/src/core/mixins/infinite_scroll_mixin.dart

import 'package:flutter/cupertino.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/style_constants.dart';

/// Mixin for handling infinite scrolling in picker widgets
mixin InfiniteScrollMixin {
  /// Calculate the actual index from infinite scroll position
  int calculateActualIndex(int scrollIndex, int itemCount) {
    return scrollIndex % itemCount;
  }

  /// Calculate initial scroll position for infinite scroll
  int calculateInitialScrollPosition(int actualValue, int itemCount) {
    // Start in the middle of the scroll buffer
    final int middleBuffer = StyleConstants.infiniteScrollBuffer ~/ 2;
    final int basePosition = middleBuffer - (middleBuffer % itemCount);
    return basePosition + actualValue;
  }

  /// Get the item value for a given scroll index
  int getItemValue(int scrollIndex, int minValue, int maxValue) {
    final int range = maxValue - minValue + 1;
    final int actualIndex = calculateActualIndex(scrollIndex, range);
    return minValue + actualIndex;
  }

  /// Get hour value for scroll index (1-12)
  int getHourValue(int scrollIndex) {
    final int actualIndex =
        calculateActualIndex(scrollIndex, StyleConstants.hoursMax);
    return actualIndex == 0 ? StyleConstants.hoursMax : actualIndex;
  }

  /// Get minute value for scroll index (0-59)
  int getMinuteValue(int scrollIndex) {
    return getItemValue(
      scrollIndex,
      StyleConstants.minutesMin,
      StyleConstants.minutesMax,
    );
  }

  /// Get second value for scroll index (0-59)
  int getSecondValue(int scrollIndex) {
    return getItemValue(
      scrollIndex,
      StyleConstants.secondsMin,
      StyleConstants.secondsMax,
    );
  }

  /// Calculate scroll position for hour value
  int getHourScrollPosition(int hour) {
    final int hourIndex = hour == StyleConstants.hoursMax ? 0 : hour;
    return calculateInitialScrollPosition(hourIndex, StyleConstants.hoursMax);
  }

  /// Calculate scroll position for minute value
  int getMinuteScrollPosition(int minute) {
    return calculateInitialScrollPosition(
      minute,
      StyleConstants.minutesMax - StyleConstants.minutesMin + 1,
    );
  }

  /// Calculate scroll position for second value
  int getSecondScrollPosition(int second) {
    return calculateInitialScrollPosition(
      second,
      StyleConstants.secondsMax - StyleConstants.secondsMin + 1,
    );
  }

  /// Check if scroll controller needs recentering
  bool needsRecentering(FixedExtentScrollController controller) {
    if (!controller.hasClients) return false;

    final int currentIndex = controller.selectedItem;
    const int threshold = StyleConstants.infiniteScrollBuffer ~/ 4;

    return currentIndex < threshold ||
        currentIndex > (StyleConstants.infiniteScrollBuffer - threshold);
  }

  /// Recenter scroll controller to middle of buffer
  Future<void> recenterScrollController(
    FixedExtentScrollController controller,
    int itemCount,
  ) async {
    if (!controller.hasClients) return;

    final int currentValue = calculateActualIndex(
      controller.selectedItem,
      itemCount,
    );

    final int newPosition = calculateInitialScrollPosition(
      currentValue,
      itemCount,
    );

    // Jump to new position without animation
    controller.jumpToItem(newPosition);
  }

  /// Format value with leading zeros if needed
  String formatPickerValue(int value, {bool padZero = true}) {
    if (!padZero) return value.toString();
    return value.toString().padLeft(2, '0');
  }

  /// Format hour for display (no leading zero)
  String formatHour(int hour) {
    return formatPickerValue(hour, padZero: false);
  }

  /// Format minute for display (with leading zero)
  String formatMinute(int minute) {
    return formatPickerValue(minute, padZero: true);
  }

  /// Format second for display (with leading zero)
  String formatSecond(int second) {
    return formatPickerValue(second, padZero: true);
  }
}
