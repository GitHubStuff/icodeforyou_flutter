// lib/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/datetime_popover/datetime_picker_popover.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DateTimePickerPopoverShowcase)
Widget dateTimePickerPopoverUseCase(BuildContext context) {
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

  return DateTimePickerPopoverShowcase(
    option: option,
    showSeconds: showSeconds,
  );
}

/// Showcase for [DateTimePickerPopover.show], which is a static method on a
/// non-widget class. This stateful widget owns the anchor key and surfaces a
/// button that triggers `show` against itself.
class DateTimePickerPopoverShowcase extends StatefulWidget {
  const DateTimePickerPopoverShowcase({
    required this.option,
    required this.showSeconds,
    super.key,
  });

  final DateTimeOption option;
  final bool showSeconds;

  @override
  State<DateTimePickerPopoverShowcase> createState() =>
      _DateTimePickerPopoverShowcaseState();
}

class _DateTimePickerPopoverShowcaseState
    extends State<DateTimePickerPopoverShowcase> {
  final _anchorKey = GlobalKey();
  DateTime? _result;

  Future<void> _show() async {
    final result = await DateTimePickerPopover.show(
      context: context,
      anchorKey: _anchorKey,
      option: widget.option,
      showSeconds: widget.showSeconds,
    );
    if (!mounted) return;
    setState(() => _result = result);
  }

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
          FilledButton.icon(
            key: _anchorKey,
            onPressed: _show,
            icon: const Icon(Icons.event_outlined),
            label: const Text('Open popover'),
          ),
          const Gap(16),
          Text(_result == null ? '— no selection —' : 'selected: ${_format(_result!)}'),
        ],
      ),
    );
  }
}
