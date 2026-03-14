// lib/packages/scrolling_datetime_pickers/scrolling_datetime_pickers.usecase.dart

// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

part '_scrolling_picker_hosts.dart';
part '_field_picker_hosts.dart';

// ---------------------------------------------------------------------------
// Shared helper
// ---------------------------------------------------------------------------

Widget _selectedDisplay(BuildContext context, String label, DateTime? value) {
  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Text(
      '$label: ${value ?? '—'}',
      style: Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.center,
    ),
  );
}

// ---------------------------------------------------------------------------
// ScrollingDatePicker use cases
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Default', type: ScrollingDatePicker)
Widget scrollingDatePickerDefault(BuildContext context) {
  final dayAscending = context.knobs.boolean(
    label: 'Day Ascending',
    initialValue: true,
  );
  final borderRadius = context.knobs.double.slider(
    label: 'Border Radius',
    initialValue: 0,
    min: 0,
    max: 24,
  );
  final fadeEnabled = context.knobs.boolean(
    label: 'Fade Enabled',
    initialValue: true,
  );

  return Center(
    child: _DatePickerHost(
      dayAscending: dayAscending,
      borderRadius: borderRadius,
      fadeConfig: fadeEnabled
          ? FadeConfiguration.light()
          : FadeConfiguration.noFade(),
      dividerConfig: const DividerConfiguration(),
    ),
  );
}

@widgetbook.UseCase(name: 'Glow Dividers', type: ScrollingDatePicker)
Widget scrollingDatePickerGlowDividers(BuildContext context) {
  return Center(
    child: _DatePickerHost(
      dayAscending: true,
      borderRadius: 12,
      fadeConfig: FadeConfiguration.light(),
      dividerConfig: DividerConfiguration.withGlow(),
    ),
  );
}

// ---------------------------------------------------------------------------
// ScrollingTimePicker use cases
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Default', type: ScrollingTimePicker)
Widget scrollingTimePickerDefault(BuildContext context) {
  final showSeconds = context.knobs.boolean(
    label: 'Show Seconds',
    initialValue: false,
  );
  final borderRadius = context.knobs.double.slider(
    label: 'Border Radius',
    initialValue: 0,
    min: 0,
    max: 24,
  );
  final fadeEnabled = context.knobs.boolean(
    label: 'Fade Enabled',
    initialValue: true,
  );

  return Center(
    child: _TimePickerHost(
      showSeconds: showSeconds,
      borderRadius: borderRadius,
      fadeConfig: fadeEnabled
          ? FadeConfiguration.light()
          : FadeConfiguration.noFade(),
    ),
  );
}

// ---------------------------------------------------------------------------
// DateTimePickerField use cases
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Date & Time', type: DateTimePickerField)
Widget dateTimePickerFieldDateTime(BuildContext context) {
  final showSeconds = context.knobs.boolean(
    label: 'Show Seconds',
    initialValue: true,
  );

  return Center(
    child: _PickerFieldHost(
      option: DateTimeOption.dateTime,
      showSeconds: showSeconds,
    ),
  );
}

@widgetbook.UseCase(name: 'Date Only', type: DateTimePickerField)
Widget dateTimePickerFieldDateOnly(BuildContext context) {
  return const Center(
    child: _PickerFieldHost(option: DateTimeOption.date, showSeconds: false),
  );
}

@widgetbook.UseCase(name: 'Time Only', type: DateTimePickerField)
Widget dateTimePickerFieldTimeOnly(BuildContext context) {
  final showSeconds = context.knobs.boolean(
    label: 'Show Seconds',
    initialValue: false,
  );

  return Center(
    child: _PickerFieldHost(
      option: DateTimeOption.time,
      showSeconds: showSeconds,
    ),
  );
}
