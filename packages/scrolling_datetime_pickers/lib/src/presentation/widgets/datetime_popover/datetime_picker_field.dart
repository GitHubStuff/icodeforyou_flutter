// lib/src/presentation/widgets/datetime_popover/datetime_picker_field.dart

import 'package:flutter/material.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/popover_constants.dart';
import 'package:scrolling_datetime_pickers/src/core/enums/datetime_option.dart';
import 'package:scrolling_datetime_pickers/src/core/models/divider_configuration.dart';
import 'package:scrolling_datetime_pickers/src/core/models/fade_configuration.dart';
import 'package:scrolling_datetime_pickers/src/presentation/widgets/datetime_popover/datetime_picker_popover.dart';

/// Convenience wrapper that shows DateTimePickerPopover when child is tapped.
class DateTimePickerField extends StatefulWidget {
  const DateTimePickerField({
    super.key,
    required this.child,
    required this.onDateTimeSelected,
    this.initialDateTime,
    this.option = DateTimeOption.dateTime,
    this.dateFormat = PopoverConstants.defaultDateFormat,
    this.timeFormat = PopoverConstants.defaultTimeFormat,
    this.showSeconds = true,
    this.popoverBackgroundColor =
        PopoverConstants.defaultPopoverBackgroundColor,
    this.dateButtonColor = PopoverConstants.defaultDateButtonColor,
    this.timeButtonColor = PopoverConstants.defaultTimeButtonColor,
    this.pickerBackgroundColor,
    this.dateButtonTextStyle,
    this.timeButtonTextStyle,
    this.headerDateTextStyle,
    this.headerTimeTextStyle,
    this.dateStyle,
    this.timeStyle,
    this.confirmWidget,
    this.confirmButtonColor = PopoverConstants.defaultConfirmButtonColor,
    this.confirmButtonText = PopoverConstants.defaultConfirmButtonText,
    this.confirmButtonTextStyle,
    this.portraitPickerSize,
    this.landscapePickerSize,
    this.dividerConfiguration,
    this.fadeConfiguration,
    this.enableHaptics = true,
    this.dayAscending = true,
    this.enabled = true,
  });

  final Widget child;
  final ValueChanged<DateTime?> onDateTimeSelected;
  final DateTime? initialDateTime;
  final DateTimeOption option;
  final String dateFormat;
  final String timeFormat;
  final bool showSeconds;
  final Color popoverBackgroundColor;
  final Color dateButtonColor;
  final Color timeButtonColor;
  final Color? pickerBackgroundColor;
  final TextStyle? dateButtonTextStyle;
  final TextStyle? timeButtonTextStyle;
  final TextStyle? headerDateTextStyle;
  final TextStyle? headerTimeTextStyle;
  final TextStyle? dateStyle;
  final TextStyle? timeStyle;
  final Widget? confirmWidget;
  final Color confirmButtonColor;
  final String confirmButtonText;
  final TextStyle? confirmButtonTextStyle;
  final Size? portraitPickerSize;
  final Size? landscapePickerSize;
  final DividerConfiguration? dividerConfiguration;
  final FadeConfiguration? fadeConfiguration;
  final bool enableHaptics;
  final bool dayAscending;
  final bool enabled;

  @override
  State<DateTimePickerField> createState() => _DateTimePickerFieldState();
}

class _DateTimePickerFieldState extends State<DateTimePickerField> {
  final GlobalKey _anchorKey = GlobalKey();

  Future<void> _showPopover() async {
    if (!widget.enabled) return;

    final result = await DateTimePickerPopover.show(
      context: context,
      anchorKey: _anchorKey,
      initialDateTime: widget.initialDateTime,
      option: widget.option,
      dateFormat: widget.dateFormat,
      timeFormat: widget.timeFormat,
      showSeconds: widget.showSeconds,
      popoverBackgroundColor: widget.popoverBackgroundColor,
      dateButtonColor: widget.dateButtonColor,
      timeButtonColor: widget.timeButtonColor,
      pickerBackgroundColor: widget.pickerBackgroundColor,
      dateButtonTextStyle: widget.dateButtonTextStyle,
      timeButtonTextStyle: widget.timeButtonTextStyle,
      headerDateTextStyle: widget.headerDateTextStyle,
      headerTimeTextStyle: widget.headerTimeTextStyle,
      dateStyle: widget.dateStyle,
      timeStyle: widget.timeStyle,
      confirmWidget: widget.confirmWidget,
      confirmButtonColor: widget.confirmButtonColor,
      confirmButtonText: widget.confirmButtonText,
      confirmButtonTextStyle: widget.confirmButtonTextStyle,
      portraitPickerSize: widget.portraitPickerSize,
      landscapePickerSize: widget.landscapePickerSize,
      dividerConfiguration: widget.dividerConfiguration,
      fadeConfiguration: widget.fadeConfiguration,
      enableHaptics: widget.enableHaptics,
      dayAscending: widget.dayAscending,
    );

    widget.onDateTimeSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _anchorKey,
      onTap: _showPopover,
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(
        absorbing: widget.enabled,
        child: widget.child,
      ),
    );
  }
}
