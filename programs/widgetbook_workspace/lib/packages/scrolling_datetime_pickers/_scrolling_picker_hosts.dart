// lib/packages/scrolling_datetime_pickers/_scrolling_picker_hosts.dart

part of 'scrolling_datetime_pickers.usecase.dart';

// ---------------------------------------------------------------------------
// _DatePickerHost
// ---------------------------------------------------------------------------

class _DatePickerHost extends StatefulWidget {
  const _DatePickerHost({
    required this.dayAscending,
    required this.borderRadius,
    required this.fadeConfig,
    required this.dividerConfig,
  });

  final bool dayAscending;
  final double borderRadius;
  final FadeConfiguration fadeConfig;
  final DividerConfiguration dividerConfig;

  @override
  State<_DatePickerHost> createState() => _DatePickerHostState();
}

class _DatePickerHostState extends State<_DatePickerHost> {
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScrollingDatePicker(
          onDateChanged: (d) => setState(() => _selected = d),
          dayAscending: widget.dayAscending,
          borderRadius: widget.borderRadius,
          fadeConfiguration: widget.fadeConfig,
          dividerConfiguration: widget.dividerConfig,
        ),
        _selectedDisplay(context, 'Selected', _selected),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _TimePickerHost
// ---------------------------------------------------------------------------

class _TimePickerHost extends StatefulWidget {
  const _TimePickerHost({
    required this.showSeconds,
    required this.borderRadius,
    required this.fadeConfig,
  });

  final bool showSeconds;
  final double borderRadius;
  final FadeConfiguration fadeConfig;

  @override
  State<_TimePickerHost> createState() => _TimePickerHostState();
}

class _TimePickerHostState extends State<_TimePickerHost> {
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScrollingTimePicker(
          onDateTimeChanged: (d) => setState(() => _selected = d),
          showSeconds: widget.showSeconds,
          borderRadius: widget.borderRadius,
          fadeConfiguration: widget.fadeConfig,
        ),
        _selectedDisplay(context, 'Selected', _selected),
      ],
    );
  }
}
