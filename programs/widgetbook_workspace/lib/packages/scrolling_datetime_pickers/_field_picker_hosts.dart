// lib/packages/scrolling_datetime_pickers/_field_picker_hosts.dart

part of 'scrolling_datetime_pickers.usecase.dart';

// ---------------------------------------------------------------------------
// _PickerFieldHost
// ---------------------------------------------------------------------------

class _PickerFieldHost extends StatefulWidget {
  const _PickerFieldHost({
    required this.option,
    required this.showSeconds,
  });

  final DateTimeOption option;
  final bool showSeconds;

  @override
  State<_PickerFieldHost> createState() => _PickerFieldHostState();
}

class _PickerFieldHostState extends State<_PickerFieldHost> {
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DateTimePickerField(
            option: widget.option,
            showSeconds: widget.showSeconds,
            onDateTimeSelected: (d) => setState(() => _selected = d),
            child: _FieldTrigger(selected: _selected),
          ),
          _selectedDisplay(context, 'Selected', _selected),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _FieldTrigger
// ---------------------------------------------------------------------------

class _FieldTrigger extends StatelessWidget {
  const _FieldTrigger({required this.selected});

  final DateTime? selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selected?.toString() ?? 'Tap to pick…',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Icon(Icons.calendar_today, size: 18),
        ],
      ),
    );
  }
}
