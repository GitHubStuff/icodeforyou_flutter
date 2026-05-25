// lib/src/presentation/widgets/datetime_popover/datetime_picker_field.dart

import 'package:flutter/material.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/popover_constants.dart';
import 'package:scrolling_datetime_pickers/src/core/enums/datetime_option.dart';
import 'package:scrolling_datetime_pickers/src/core/models/divider_configuration.dart';
import 'package:scrolling_datetime_pickers/src/core/models/fade_configuration.dart';
import 'package:scrolling_datetime_pickers/src/presentation/widgets/datetime_popover/datetime_picker_popover.dart';

/// A convenience wrapper that presents a [DateTimePickerPopover] anchored to
/// itself when tapped.
///
/// Wrap any widget with [DateTimePickerField] to turn it into a tappable
/// date/time input. The popover is anchored to the wrapped widget via a
/// [GlobalKey] so it appears in the correct position regardless of layout.
class DateTimePickerField extends StatefulWidget {
  /// Creates a [DateTimePickerField].
  ///
  /// [child] is the widget that the user taps to open the popover.
  /// [onDateTimeSelected] is called with the confirmed [DateTime] when the
  /// user dismisses the popover, or `null` if the popover was cancelled.
  /// When [enabled] is `false` taps are ignored and the popover will not open.
  const DateTimePickerField({
    required this.child,
    required this.onDateTimeSelected,
    super.key,
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

  /// The widget that the user taps to open the date/time popover.
  final Widget child;

  /// Called with the selected [DateTime] when the popover is confirmed, or
  /// `null` when it is dismissed without a selection.
  final ValueChanged<DateTime?> onDateTimeSelected;

  /// The date and time pre-selected when the popover opens.
  ///
  /// When `null` the popover uses its own internal default.
  final DateTime? initialDateTime;

  /// Controls which picker columns are shown — date only, time only, or both.
  ///
  /// Defaults to [DateTimeOption.dateTime].
  final DateTimeOption option;

  /// Format string used to display the date in the popover header button.
  ///
  /// Defaults to [PopoverConstants.defaultDateFormat].
  final String dateFormat;

  /// Format string used to display the time in the popover header button.
  ///
  /// Defaults to [PopoverConstants.defaultTimeFormat].
  final String timeFormat;

  /// Whether the seconds scroll column is visible in the time picker.
  ///
  /// Defaults to `true`.
  final bool showSeconds;

  /// Background color of the popover container.
  ///
  /// Defaults to [PopoverConstants.defaultPopoverBackgroundColor].
  final Color popoverBackgroundColor;

  /// Background color of the date toggle button in the popover header.
  ///
  /// Defaults to [PopoverConstants.defaultDateButtonColor].
  final Color dateButtonColor;

  /// Background color of the time toggle button in the popover header.
  ///
  /// Defaults to [PopoverConstants.defaultTimeButtonColor].
  final Color timeButtonColor;

  /// Background color of the picker drum itself.
  ///
  /// When `null` the picker uses its default background.
  final Color? pickerBackgroundColor;

  /// Text style applied to the date toggle button label.
  ///
  /// When `null` the popover's default style is used.
  final TextStyle? dateButtonTextStyle;

  /// Text style applied to the time toggle button label.
  ///
  /// When `null` the popover's default style is used.
  final TextStyle? timeButtonTextStyle;

  /// Text style applied to the date value displayed in the popover header.
  ///
  /// When `null` the popover's default style is used.
  final TextStyle? headerDateTextStyle;

  /// Text style applied to the time value displayed in the popover header.
  ///
  /// When `null` the popover's default style is used.
  final TextStyle? headerTimeTextStyle;

  /// Text style applied to the date items in the picker drum.
  ///
  /// When `null` the picker's default style is used.
  final TextStyle? dateStyle;

  /// Text style applied to the time items in the picker drum.
  ///
  /// When `null` the picker's default style is used.
  final TextStyle? timeStyle;

  /// Custom widget to replace the default confirm button.
  ///
  /// When `null` the popover renders a default button using
  /// [confirmButtonColor], [confirmButtonText], and [confirmButtonTextStyle].
  final Widget? confirmWidget;

  /// Background color of the default confirm button.
  ///
  /// Ignored when [confirmWidget] is provided.
  /// Defaults to [PopoverConstants.defaultConfirmButtonColor].
  final Color confirmButtonColor;

  /// Label text of the default confirm button.
  ///
  /// Ignored when [confirmWidget] is provided.
  /// Defaults to [PopoverConstants.defaultConfirmButtonText].
  final String confirmButtonText;

  /// Text style applied to the default confirm button label.
  ///
  /// Ignored when [confirmWidget] is provided. When `null` the popover's
  /// default style is used.
  final TextStyle? confirmButtonTextStyle;

  /// Preferred size of the popover in portrait orientation.
  ///
  /// When `null` the popover uses its intrinsic size.
  final Size? portraitPickerSize;

  /// Preferred size of the popover in landscape orientation.
  ///
  /// When `null` the popover uses its intrinsic size.
  final Size? landscapePickerSize;

  /// Visual configuration for the selection divider lines.
  ///
  /// When `null` the picker uses its default divider styling.
  final DividerConfiguration? dividerConfiguration;

  /// Visual configuration for the top and bottom fade overlays.
  ///
  /// When `null` the picker uses its default fade styling.
  final FadeConfiguration? fadeConfiguration;

  /// Whether haptic feedback is triggered on scroll and selection events.
  ///
  /// Defaults to `true`.
  final bool enableHaptics;

  /// Whether day values in the date picker are listed in ascending order.
  ///
  /// Defaults to `true`.
  final bool dayAscending;

  /// Whether tapping [child] opens the popover.
  ///
  /// When `false` taps are ignored and the popover will not be shown.
  /// Defaults to `true`.
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
