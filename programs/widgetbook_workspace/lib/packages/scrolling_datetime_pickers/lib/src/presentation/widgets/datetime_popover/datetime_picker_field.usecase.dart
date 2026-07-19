// lib/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/datetime_popover/datetime_picker_field.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DateTimePickerField)
Widget dateTimePickerFieldUseCase(BuildContext context) {
  final option = context.knobs.object.dropdown<DateTimeOption>(
    label: 'option',
    options: DateTimeOption.values,
    initialOption: DateTimeOption.dateTime,
    labelBuilder: (o) => o.name,
  );

  final showSeconds = context.knobs.boolean(
    label: 'showSeconds',
    initialValue: true,
  );

  final dayAscending = context.knobs.boolean(
    label: 'dayAscending',
    initialValue: true,
  );

  return _FieldShowcase(
    option: option,
    showSeconds: showSeconds,
    dayAscending: dayAscending,
  );
}

class _FieldShowcase extends StatefulWidget {
  const _FieldShowcase({
    required this.option,
    required this.showSeconds,
    required this.dayAscending,
  });

  final DateTimeOption option;
  final bool showSeconds;
  final bool dayAscending;

  @override
  State<_FieldShowcase> createState() => _FieldShowcaseState();
}

class _FieldShowcaseState extends State<_FieldShowcase> {
  DateTime? _value;

  String _format(DateTime d) {
    switch (widget.option) {
      case DateTimeOption.date:
        return DateFormat.yMMMMd().format(d);
      case DateTimeOption.time:
        return DateFormat.jm().format(d);
      case DateTimeOption.dateTime:
        return DateFormat.yMMMMd().add_jm().format(d);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DateTimePickerField(
            option: widget.option,
            showSeconds: widget.showSeconds,
            dayAscending: widget.dayAscending,
            onDateTimeSelected: (d) => setState(() => _value = d),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event, color: Colors.white),
                  const Gap(8),
                  Text(
                    _value == null ? 'Pick date / time' : _format(_value!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(16),
          Text(_value == null ? '— no selection —' : 'selected: ${_format(_value!)}'),
        ],
      ),
    );
  }
}
