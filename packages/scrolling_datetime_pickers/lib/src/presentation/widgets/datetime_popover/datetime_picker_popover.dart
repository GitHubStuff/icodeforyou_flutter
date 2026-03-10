// lib/src/presentation/widgets/datetime_popover/datetime_picker_popover.dart

// ignore_for_file: document_ignores

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/popover_constants.dart';
import 'package:scrolling_datetime_pickers/src/core/enums/datetime_option.dart';
import 'package:scrolling_datetime_pickers/src/core/models/divider_configuration.dart';
import 'package:scrolling_datetime_pickers/src/core/models/fade_configuration.dart';
import 'package:scrolling_datetime_pickers/src/presentation/widgets/scrolling_date_picker.dart';
import 'package:scrolling_datetime_pickers/src/presentation/widgets/scrolling_time_picker.dart';

part '_datetime_popover_route.dart';
part '_datetime_popover_content.dart';
part '_datetime_popover_header.dart';
part '_datetime_popover_tab_bar.dart';
part '_datetime_popover_body.dart';

enum _DateTimeTab { date, time }

/// Combines ScrollingDatePicker and ScrollingTimePicker in a popover.
/// Use [DateTimePickerPopover.show] to display near an anchor widget.
/// Returns selected DateTime on confirm, null on barrier tap.
class DateTimePickerPopover {
  // coverage:ignore-start
  DateTimePickerPopover._();
  // coverage:ignore-end

  /// Normalize initial datetime based on the picker option:
  /// - DateOnly: current date at midnight (00:00:00.000)
  /// - TimeOnly: Jan 1st of current year with current time (seconds based on
  /// flag)
  /// - DateTime: current date/time with seconds based on flag, no milliseconds
  static DateTime _normalizeInitialDateTime(
    DateTime? initialDateTime,
    DateTimeOption option,
    bool useCurrentSecond,
  ) {
    final now = DateTime.now();

    // If user provided a specific datetime, normalize it
    if (initialDateTime != null) {
      switch (option) {
        case DateTimeOption.date:
          // Date only: strip time, use midnight
          return DateTime(
            initialDateTime.year,
            initialDateTime.month,
            initialDateTime.day,
          );
        case DateTimeOption.time:
          // Time only: use Jan 1st of current year with provided time
          return DateTime(
            now.year,
            1,
            1,
            initialDateTime.hour,
            initialDateTime.minute,
            // ignore: lines_longer_than_80_chars
            useCurrentSecond ? initialDateTime.second : 0, // coverage:ignore-line
          );
        case DateTimeOption.dateTime:
          // Combined: use all components, strip sub-second precision
          return DateTime(
            initialDateTime.year,
            initialDateTime.month,
            initialDateTime.day,
            initialDateTime.hour,
            initialDateTime.minute,
            useCurrentSecond ? initialDateTime.second : 0,
          );
      }
    }

    // No initial datetime provided - use defaults
    switch (option) {
      case DateTimeOption.date:
        // Date only: current date at midnight
        return DateTime(now.year, now.month, now.day);
      case DateTimeOption.time:
        // Time only: Jan 1st of current year with current time
        return DateTime(
          now.year,
          1,
          1,
          now.hour,
          now.minute,
          useCurrentSecond ? now.second : 0, // coverage:ignore-line
        );
      case DateTimeOption.dateTime:
        // Combined: current date/time, strip sub-second precision
        return DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          now.minute,
          useCurrentSecond ? now.second : 0, // coverage:ignore-line
        );
    }
  }

  static Future<DateTime?> show({
    required BuildContext context,
    required GlobalKey anchorKey,
    DateTime? initialDateTime,
    DateTimeOption option = DateTimeOption.dateTime,
    String dateFormat = PopoverConstants.defaultDateFormat,
    String timeFormat = PopoverConstants.defaultTimeFormat,
    bool showSeconds = true,

    /// Whether to use current second value or default to 0
    /// Only applies when showSeconds is true
    bool useCurrentSecond = false,
    Color popoverBackgroundColor =
        PopoverConstants.defaultPopoverBackgroundColor,
    Color dateButtonColor = PopoverConstants.defaultDateButtonColor,
    Color timeButtonColor = PopoverConstants.defaultTimeButtonColor,
    Color? pickerBackgroundColor,
    TextStyle? dateButtonTextStyle,
    TextStyle? timeButtonTextStyle,
    TextStyle? headerDateTextStyle,
    TextStyle? headerTimeTextStyle,
    TextStyle? dateStyle,
    TextStyle? timeStyle,
    Widget? confirmWidget,
    Color confirmButtonColor = PopoverConstants.defaultConfirmButtonColor,
    String confirmButtonText = PopoverConstants.defaultConfirmButtonText,
    TextStyle? confirmButtonTextStyle,
    Size? portraitPickerSize,
    Size? landscapePickerSize,
    DividerConfiguration? dividerConfiguration,
    FadeConfiguration? fadeConfiguration,
    bool enableHaptics = true,
    bool dayAscending = true,
  }) async {
    final renderBox =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return null;

    final anchorPosition = renderBox.localToGlobal(Offset.zero);
    final anchorSize = renderBox.size;

    // Normalize initial datetime based on option type
    final normalizedDateTime = _normalizeInitialDateTime(
      initialDateTime,
      option,
      useCurrentSecond && showSeconds,
    );

    return Navigator.of(context).push<DateTime?>(
      _DateTimePopoverRoute(
        anchorPosition: anchorPosition,
        anchorSize: anchorSize,
        initialDateTime: normalizedDateTime,
        option: option,
        dateFormat: dateFormat,
        timeFormat: timeFormat,
        showSeconds: showSeconds,
        popoverBackgroundColor: popoverBackgroundColor,
        dateButtonColor: dateButtonColor,
        timeButtonColor: timeButtonColor,
        pickerBackgroundColor: pickerBackgroundColor,
        dateButtonTextStyle: dateButtonTextStyle,
        timeButtonTextStyle: timeButtonTextStyle,
        headerDateTextStyle: headerDateTextStyle,
        headerTimeTextStyle: headerTimeTextStyle,
        dateStyle: dateStyle,
        timeStyle: timeStyle,
        confirmWidget: confirmWidget,
        confirmButtonColor: confirmButtonColor,
        confirmButtonText: confirmButtonText,
        confirmButtonTextStyle: confirmButtonTextStyle,
        portraitPickerSize: portraitPickerSize,
        landscapePickerSize: landscapePickerSize,
        dividerConfiguration: dividerConfiguration,
        fadeConfiguration: fadeConfiguration,
        enableHaptics: enableHaptics,
        dayAscending: dayAscending,
      ),
    );
  }
}
