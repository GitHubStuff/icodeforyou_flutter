// programs/widgetbook_workspace/lib/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/datetime_popover/datetime_picker_field.usecase.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart'
    show DateTimeOption, DateTimePickerDecorator, DateTimePickerField;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Interactive playground: every behavioural switch on [DateTimePickerField]
/// is exposed as a knob, and the confirmed value is echoed below the field.
@widgetbook.UseCase(name: 'Interactive', type: DateTimePickerField)
Widget dateTimePickerFieldInteractive(BuildContext context) {
  final option = context.knobs.object.dropdown<DateTimeOption>(
    label: 'Option',
    options: DateTimeOption.values,
    initialOption: DateTimeOption.dateTime,
    labelBuilder: (option) => option.name,
  );
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  final showSeconds = context.knobs.boolean(
    label: 'Show seconds',
    initialValue: true,
  );
  final dayAscending = context.knobs.boolean(
    label: 'Day ascending',
    initialValue: true,
  );
  final enableHaptics = context.knobs.boolean(
    label: 'Enable haptics',
    initialValue: true,
  );
  final confirmButtonText = context.knobs.string(
    label: 'Confirm button text',
    initialValue: 'Set',
  );
  final labelText = context.knobs.string(
    label: 'Label text',
    initialValue: 'Date & time',
  );

  return _DateTimePickerFieldDemo(
    option: option,
    enabled: enabled,
    showSeconds: showSeconds,
    dayAscending: dayAscending,
    enableHaptics: enableHaptics,
    confirmButtonText: confirmButtonText,
    labelText: labelText,
  );
}

/// Static contrast of the three [DateTimeOption] variants side by side.
@widgetbook.UseCase(name: 'Option Gallery', type: DateTimePickerField)
Widget dateTimePickerFieldOptionGallery(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DateTimePickerFieldDemo(
          option: DateTimeOption.dateTime,
          labelText: 'Date & time',
        ),
        SizedBox(height: 24),
        _DateTimePickerFieldDemo(
          option: DateTimeOption.date,
          labelText: 'Date only',
        ),
        SizedBox(height: 24),
        _DateTimePickerFieldDemo(
          option: DateTimeOption.time,
          labelText: 'Time only',
        ),
      ],
    ),
  );
}

/// Owns the selected value so the field can be exercised end to end:
/// open, confirm, clear. The clear affordance lives in the
/// [InputDecoration.suffixIcon] slot inside the field's own tap region,
/// which is exactly the arrangement the field must not swallow.
class _DateTimePickerFieldDemo extends StatefulWidget {
  const _DateTimePickerFieldDemo({
    required this.option,
    required this.labelText,
    this.enabled = true,
    this.showSeconds = true,
    this.dayAscending = true,
    this.enableHaptics = true,
    this.confirmButtonText = 'Set',
  });

  final DateTimeOption option;
  final String labelText;
  final bool enabled;
  final bool showSeconds;
  final bool dayAscending;
  final bool enableHaptics;
  final String confirmButtonText;

  @override
  State<_DateTimePickerFieldDemo> createState() =>
      _DateTimePickerFieldDemoState();
}

class _DateTimePickerFieldDemoState extends State<_DateTimePickerFieldDemo> {
  DateTime? _selected;

  void _onDateTimeSelected(DateTime? result) {
    // `null` means the popover was dismissed; keep the previous value.
    if (result == null) return;
    setState(() => _selected = result);
  }

  void _onCleared() => setState(() => _selected = null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(24),

          DateTimePickerField(
            initialDateTime: selected,
            onDateTimeSelected: _onDateTimeSelected,
            option: widget.option,
            enabled: widget.enabled,
            showSeconds: widget.showSeconds,
            dayAscending: widget.dayAscending,
            enableHaptics: widget.enableHaptics,
            confirmButtonText: widget.confirmButtonText,
            child: DateTimePickerDecorator(
              value: selected,
              option: widget.option,
              labelText: widget.labelText,
              showSeconds: widget.showSeconds,
              enabled: widget.enabled,
              onCleared: _onCleared,
            ),
          ),
          Text(
            selected == null
                ? 'No value selected'
                : 'Selected: ${selected.toIso8601String()}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
