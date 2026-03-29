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

/// Combines [ScrollingDatePicker] and [ScrollingTimePicker] in a popover
/// anchored to a widget in the layout tree.
///
/// Use [DateTimePickerPopover.show] to present the popover near an anchor
/// widget identified by a [GlobalKey]. The future resolves to the confirmed
/// [DateTime], or `null` when the user dismisses by tapping the barrier.
class DateTimePickerPopover {
  // coverage:ignore-start
  DateTimePickerPopover._();
  // coverage:ignore-end

  /// Returns a normalised [DateTime] appropriate for the given [option].
  ///
  /// When [initialDateTime] is provided it is adjusted to match the
  /// requirements of each [DateTimeOption]:
  /// - [DateTimeOption.date] — time components are stripped; midnight is used.
  /// - [DateTimeOption.time] — date is fixed to 1 January of the current year;
  ///   the time components from [initialDateTime] are preserved, and seconds
  ///   are included only when [useCurrentSecond] is `true`.
  /// - [DateTimeOption.dateTime] — all components are preserved; sub-second
  ///   precision is stripped, and seconds are included only when
  ///   [useCurrentSecond] is `true`.
  ///
  /// When [initialDateTime] is `null`, sensible defaults are applied:
  /// - [DateTimeOption.date] — current date at midnight.
  /// - [DateTimeOption.time] — 1 January of the current year at the current
  ///   hour and minute.
  /// - [DateTimeOption.dateTime] — current date and time without sub-second
  ///   precision.
  static DateTime _normalizeInitialDateTime(
    DateTime? initialDateTime,
    DateTimeOption option,
    bool useCurrentSecond,
  ) {
    final now = DateTime.now();

    if (initialDateTime != null) {
      switch (option) {
        case DateTimeOption.date:
          return DateTime(
            initialDateTime.year,
            initialDateTime.month,
            initialDateTime.day,
          );
        case DateTimeOption.time:
          return DateTime(
            now.year,
            1,
            1,
            initialDateTime.hour,
            initialDateTime.minute,
            useCurrentSecond
                ? initialDateTime.second
                : 0, // coverage:ignore-line
          );
        case DateTimeOption.dateTime:
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

    switch (option) {
      case DateTimeOption.date:
        return DateTime(now.year, now.month, now.day);
      case DateTimeOption.time:
        return DateTime(
          now.year,
          1,
          1,
          now.hour,
          now.minute,
          useCurrentSecond ? now.second : 0, // coverage:ignore-line
        );
      case DateTimeOption.dateTime:
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

  /// Presents the date/time popover anchored to the widget identified by
  /// [anchorKey] and returns the confirmed [DateTime], or `null` if the
  /// popover was dismissed without a selection.
  ///
  /// The popover is positioned relative to the anchor's render object. If the
  /// anchor cannot be resolved to a [RenderBox] the method returns `null`
  /// immediately without pushing a route.
  ///
  /// The [option] parameter controls which picker columns are shown:
  /// date only, time only, or both. The [initialDateTime] is normalised via
  /// [_normalizeInitialDateTime] before being passed to the route.
  ///
  /// When [showSeconds] is `true` the seconds column is visible. The
  /// [useCurrentSecond] flag further controls whether the seconds component
  /// of [initialDateTime] is preserved (`true`) or zeroed (`false`); it has
  /// no effect when [showSeconds] is `false`.
  static Future<DateTime?> show({
    required BuildContext context,
    required GlobalKey anchorKey,
    DateTime? initialDateTime,
    DateTimeOption option = DateTimeOption.dateTime,
    String dateFormat = PopoverConstants.defaultDateFormat,
    String timeFormat = PopoverConstants.defaultTimeFormat,
    bool showSeconds = true,

    // ignore: comment_references
    /// Whether to preserve the seconds component of [initialDateTime].
    ///
    // ignore: comment_references
    /// Only meaningful when [showSeconds] is `true`. When `false` seconds
    /// default to `0`.
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
