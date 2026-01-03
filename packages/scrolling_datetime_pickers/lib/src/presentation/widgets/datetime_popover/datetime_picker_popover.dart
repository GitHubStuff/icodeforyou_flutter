// lib/src/presentation/widgets/datetime_popover/datetime_picker_popover.dart

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
  DateTimePickerPopover._();

  static Future<DateTime?> show({
    required BuildContext context,
    required GlobalKey anchorKey,
    DateTime? initialDateTime,
    DateTimeOption option = DateTimeOption.dateTime,
    String dateFormat = PopoverConstants.defaultDateFormat,
    String timeFormat = PopoverConstants.defaultTimeFormat,
    bool showSeconds = true,
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

    return Navigator.of(context).push<DateTime?>(
      _DateTimePopoverRoute(
        anchorPosition: anchorPosition,
        anchorSize: anchorSize,
        initialDateTime: initialDateTime ?? DateTime.now(),
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
