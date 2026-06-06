// lib/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/scrolling_date_picker.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ScrollingDatePicker)
Widget scrollingDatePickerUseCase(BuildContext context) {
  final dayAscending = context.knobs.boolean(
    label: 'dayAscending (DMY first)',
    initialValue: true,
  );

  final enableHaptics = context.knobs.boolean(
    label: 'enableHaptics',
    initialValue: true,
  );

  final fade = context.knobs.object.dropdown<_FadeChoice>(
    label: 'fade configuration',
    options: _FadeChoice.values,
    initialOption: _FadeChoice.defaults,
    labelBuilder: (f) => f.label,
  );

  return _DatePickerShowcase(
    dayAscending: dayAscending,
    enableHaptics: enableHaptics,
    fade: fade.toConfig(),
  );
}

enum _FadeChoice {
  defaults('Default'),
  light('Light surface'),
  dark('Dark surface'),
  none('No fade');

  const _FadeChoice(this.label);

  final String label;

  FadeConfiguration toConfig() => switch (this) {
    _FadeChoice.defaults => const FadeConfiguration(),
    _FadeChoice.light => FadeConfiguration.light(),
    _FadeChoice.dark => FadeConfiguration.dark(),
    _FadeChoice.none => FadeConfiguration.noFade(),
  };
}

class _DatePickerShowcase extends StatefulWidget {
  const _DatePickerShowcase({
    required this.dayAscending,
    required this.enableHaptics,
    required this.fade,
  });

  final bool dayAscending;
  final bool enableHaptics;
  final FadeConfiguration fade;

  @override
  State<_DatePickerShowcase> createState() => _DatePickerShowcaseState();
}

class _DatePickerShowcaseState extends State<_DatePickerShowcase> {
  DateTime _value = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScrollingDatePicker(
            // Force rebuild when knobs flip the picker layout.
            key: ValueKey('asc:${widget.dayAscending}-fade:${widget.fade}'),
            onDateChanged: (d) => setState(() => _value = d),
            dayAscending: widget.dayAscending,
            enableHaptics: widget.enableHaptics,
            fadeConfiguration: widget.fade,
          ),
          const Gap(16),
          Text(
            'selected: ${DateFormat.yMMMMd().format(_value)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
