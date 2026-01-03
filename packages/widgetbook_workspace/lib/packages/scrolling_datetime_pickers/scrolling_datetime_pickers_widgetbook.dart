// lib/packages/scrolling_datetime_pickers/scrolling_datetime_pickers_widgetbook.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:intl/intl.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

part 'scrolling_datetime_pickers_demo_widgets.dart';
part '_datetime_popover_demos.dart';
part '_datetime_popover_theme_showcase.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SCROLLING TIME PICKER USE CASES
// ═══════════════════════════════════════════════════════════════════════════

@widgetbook.UseCase(name: 'Default', type: ScrollingTimePicker)
Widget buildScrollingTimePickerDefaultCase(BuildContext context) {
  return Center(
    child: ScrollingTimePicker(
      initialDateTime: DateTime.now(),
      onDateTimeChanged: (dateTime) {
        debugPrint('Time changed: ${dateTime.hour}:${dateTime.minute}');
      },
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive Demo', type: ScrollingTimePicker)
Widget buildScrollingTimePickerInteractiveCase(BuildContext context) {
  return const Center(child: _InteractiveTimePickerDemo());
}

// ═══════════════════════════════════════════════════════════════════════════
// SCROLLING DATE PICKER USE CASES
// ═══════════════════════════════════════════════════════════════════════════

@widgetbook.UseCase(name: 'Default', type: ScrollingDatePicker)
Widget buildScrollingDatePickerDefaultCase(BuildContext context) {
  return Center(
    child: ScrollingDatePicker(
      initialDate: DateTime.now(),
      onDateChanged: (date) {
        debugPrint('Date changed: ${date.year}-${date.month}-${date.day}');
      },
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive Demo', type: ScrollingDatePicker)
Widget buildScrollingDatePickerInteractiveCase(BuildContext context) {
  return const Center(child: _InteractiveDatePickerDemo());
}

// ═══════════════════════════════════════════════════════════════════════════
// DATETIME PICKER POPOVER USE CASES
// ═══════════════════════════════════════════════════════════════════════════

@widgetbook.UseCase(name: 'DateTime Mode', type: DateTimePickerPopover)
Widget buildDateTimePopoverDateTimeModeCase(BuildContext context) {
  return const Center(
    child: _DateTimePopoverDemo(option: DateTimeOption.dateTime),
  );
}

@widgetbook.UseCase(name: 'Date Only Mode', type: DateTimePickerPopover)
Widget buildDateTimePopoverDateOnlyModeCase(BuildContext context) {
  return const Center(child: _DateTimePopoverDemo(option: DateTimeOption.date));
}

@widgetbook.UseCase(name: 'Time Only Mode', type: DateTimePickerPopover)
Widget buildDateTimePopoverTimeOnlyModeCase(BuildContext context) {
  return const Center(child: _DateTimePopoverDemo(option: DateTimeOption.time));
}

@widgetbook.UseCase(name: 'Light & Dark Theme', type: DateTimePickerPopover)
Widget buildDateTimePopoverThemeShowcaseCase(BuildContext context) {
  return const Center(child: _DateTimePopoverThemeShowcase());
}
