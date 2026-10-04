// programs/widgetbook_workspace/lib/packages/scrolling_datetime_pickers/lib/src/presentation/widgets/datetime_popover/datetime_picker_field_decorated.usecase.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart'
    show DateTimeOption, DateTimePickerField;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Interactive playground for [DateTimePickerField.decorated]: every switch
/// the factory forwards to the field *and* the decorator is exposed as a
/// knob, so the single-source-of-truth behaviour (value, option, seconds and
/// enabled state staying in sync) can be verified by eye.
@widgetbook.UseCase(name: 'Decorated Interactive', type: DateTimePickerField)
Widget dateTimePickerFieldDecoratedInteractive(BuildContext context) {
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
  final showClear = context.knobs.boolean(
    label: 'Show clear button',
    initialValue: true,
  );
  final useCustomFormatter = context.knobs.boolean(
    label: 'Use custom formatter',
    initialValue: false,
  );
  final dayAscending = context.knobs.boolean(
    label: 'Day ascending',
    initialValue: true,
  );
  final enableHaptics = context.knobs.boolean(
    label: 'Enable haptics',
    initialValue: true,
  );
  final labelText = context.knobs.string(
    label: 'Label text',
    initialValue: 'Date & time',
  );
  final placeholder = context.knobs.string(
    label: 'Placeholder',
    initialValue: 'Tap to select',
  );
  final clearTooltip = context.knobs.string(
    label: 'Clear tooltip',
    initialValue: 'Clear',
  );
  final confirmButtonText = context.knobs.string(
    label: 'Confirm button text',
    initialValue: 'Set',
  );

  return _DecoratedFieldDemo(
    option: option,
    labelText: labelText,
    enabled: enabled,
    showSeconds: showSeconds,
    showClear: showClear,
    useCustomFormatter: useCustomFormatter,
    dayAscending: dayAscending,
    enableHaptics: enableHaptics,
    placeholder: placeholder,
    clearTooltip: clearTooltip,
    confirmButtonText: confirmButtonText,
  );
}

/// Static contrast of the three [DateTimeOption] variants built through
/// [DateTimePickerField.decorated], side by side.
@widgetbook.UseCase(name: 'Decorated Gallery', type: DateTimePickerField)
Widget dateTimePickerFieldDecoratedGallery(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DecoratedFieldDemo(
          option: DateTimeOption.dateTime,
          labelText: 'Date & time',
        ),
        SizedBox(height: 24),
        _DecoratedFieldDemo(
          option: DateTimeOption.date,
          labelText: 'Date only',
        ),
        SizedBox(height: 24),
        _DecoratedFieldDemo(
          option: DateTimeOption.time,
          labelText: 'Time only',
        ),
      ],
    ),
  );
}

/// Shows the decorator-only parameters the factory exposes that the plain
/// constructor does not: a custom [DateTimePickerField.decorated] `formatter`
/// and a field with no clear affordance at all.
@widgetbook.UseCase(name: 'Decorated Variants', type: DateTimePickerField)
Widget dateTimePickerFieldDecoratedVariants(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DecoratedFieldDemo(
          option: DateTimeOption.dateTime,
          labelText: 'Custom formatter',
          useCustomFormatter: true,
        ),
        SizedBox(height: 24),
        _DecoratedFieldDemo(
          option: DateTimeOption.date,
          labelText: 'No clear button',
          showClear: false,
        ),
        SizedBox(height: 24),
        _DecoratedFieldDemo(
          option: DateTimeOption.time,
          labelText: 'Disabled',
          enabled: false,
        ),
      ],
    ),
  );
}

/// Owns the selected value so the decorated field can be exercised end to
/// end: open, confirm, clear. Note that `initialDateTime`, `option`,
/// `showSeconds` and `enabled` are each passed exactly once — the factory
/// forwards them to both the field and the decorator.
class _DecoratedFieldDemo extends StatefulWidget {
  const _DecoratedFieldDemo({
    required this.option,
    required this.labelText,
    this.enabled = true,
    this.showSeconds = true,
    this.showClear = true,
    this.useCustomFormatter = false,
    this.dayAscending = true,
    this.enableHaptics = true,
    this.placeholder = 'Tap to select',
    this.clearTooltip = 'Clear',
    this.confirmButtonText = 'Set',
  });

  final DateTimeOption option;
  final String labelText;
  final bool enabled;
  final bool showSeconds;
  final bool showClear;
  final bool useCustomFormatter;
  final bool dayAscending;
  final bool enableHaptics;
  final String placeholder;
  final String clearTooltip;
  final String confirmButtonText;

  @override
  State<_DecoratedFieldDemo> createState() => _DecoratedFieldDemoState();
}

class _DecoratedFieldDemoState extends State<_DecoratedFieldDemo> {
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
          DateTimePickerField.decorated(
            onDateTimeSelected: _onDateTimeSelected,
            labelText: widget.labelText,
            initialDateTime: selected,
            option: widget.option,
            showSeconds: widget.showSeconds,
            enabled: widget.enabled,
            dayAscending: widget.dayAscending,
            enableHaptics: widget.enableHaptics,
            confirmButtonText: widget.confirmButtonText,
            placeholder: widget.placeholder,
            clearTooltip: widget.clearTooltip,
            onCleared: widget.showClear ? _onCleared : null,
            formatter: widget.useCustomFormatter ? _relativeFormatter : null,
          ),
          const Gap(8),
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

/// Alternative rendering used by the "custom formatter" knob/variant, chosen
/// to look nothing like the decorator's default so the override is obvious.
String _relativeFormatter(DateTime value) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final weekday = weekdays[value.weekday - 1];
  final month = months[value.month - 1];
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final meridiem = value.hour < 12 ? 'AM' : 'PM';

  return '$weekday, $month ${value.day} $hour:$minute $meridiem';
}
