// packages/scrolling_datetime_pickers/lib/src/presentation/widgets/datetime_popover/datetime_picker_decorator.dart

import 'package:flutter/material.dart';
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart'
    show DateTimeOption, DateTimePickerField;

/// Renders a [DateTime] value inside a labelled [InputDecorator] shell,
/// sized and styled to sit in the `child` slot of a [DateTimePickerField].
///
/// This widget is presentation only: it holds no state and never opens the
/// picker. The owner supplies [value], reacts to the field's
/// `onDateTimeSelected`, and (optionally) handles [onCleared]. The clear
/// button lives in [InputDecoration.suffixIcon], inside the field's tap
/// region, which is the arrangement [DateTimePickerField] is required not to
/// swallow.
///
/// Text is limited to the columns [option] exposes, so the field never shows
/// a component the user could not have picked. Supply [formatter] to override
/// that rendering entirely.
class DateTimePickerDecorator extends StatelessWidget {
  /// Creates a decorator for a [DateTimePickerField].
  const DateTimePickerDecorator({
    required this.value,
    required this.option,
    required this.labelText,
    this.showSeconds = true,
    this.enabled = true,
    this.placeholder = 'Tap to select',
    this.clearTooltip = 'Clear',
    this.onCleared,
    this.formatter,
    super.key,
  });

  /// The currently selected value, or `null` when nothing is selected.
  final DateTime? value;

  /// Which columns the owning field exposes; drives the default rendering.
  final DateTimeOption option;

  /// Floating label shown above the value.
  final String labelText;

  /// Whether seconds are included in the default time rendering.
  final bool showSeconds;

  /// Mirrors the owning field's `enabled`; greys the border and disables
  /// the clear button.
  final bool enabled;

  /// Text shown when [value] is `null`.
  final String placeholder;

  /// Tooltip on the clear button.
  final String clearTooltip;

  /// Invoked when the clear button is pressed. When `null`, no clear button
  /// is rendered.
  final VoidCallback? onCleared;

  /// Optional override for turning [value] into display text. Defaults to a
  /// rendering limited to the columns [option] exposes.
  final String Function(DateTime value)? formatter;

  bool get _isEmpty => value == null;

  bool get _showClear => !_isEmpty && onCleared != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final outline = colorScheme.outline;
    final current = value;

    return InputDecorator(
      isEmpty: _isEmpty,
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: colorScheme.surface,
        enabled: enabled,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: outline),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: outline.withValues(alpha: 0.38)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: outline, width: 2),
        ),
        suffixIcon: _showClear
            ? IconButton(
                icon: const Icon(Icons.clear),
                tooltip: clearTooltip,
                onPressed: enabled ? onCleared : null,
              )
            : null,
      ),
      child: Text(
        current == null ? placeholder : _display(current),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: current == null ? colorScheme.onSurfaceVariant : null,
          fontStyle: current == null ? FontStyle.italic : null,
        ),
      ),
    );
  }

  String _display(DateTime current) =>
      formatter?.call(current) ?? _formatForOption(current);

  String _formatForOption(DateTime current) {
    final date = '${current.year}-${_two(current.month)}-${_two(current.day)}';
    final time = showSeconds
        ? '${_two(current.hour)}:${_two(current.minute)}:'
              '${_two(current.second)}'
        : '${_two(current.hour)}:${_two(current.minute)}';

    return switch (option) {
      DateTimeOption.date => date,
      DateTimeOption.time => time,
      DateTimeOption.dateTime => '$date $time',
    };
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
