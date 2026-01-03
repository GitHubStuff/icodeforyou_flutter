// lib/packages/scrolling_datetime_pickers/_datetime_popover_demos.dart

part of 'scrolling_datetime_pickers_widgetbook.dart';

class _DateTimePopoverDemo extends StatefulWidget {
  const _DateTimePopoverDemo({required this.option});

  final DateTimeOption option;

  @override
  State<_DateTimePopoverDemo> createState() => _DateTimePopoverDemoState();
}

class _DateTimePopoverDemoState extends State<_DateTimePopoverDemo> {
  final GlobalKey _anchorKey = GlobalKey();
  DateTime? _selectedDateTime;

  Future<void> _showPopover() async {
    final result = await DateTimePickerPopover.show(
      context: context,
      anchorKey: _anchorKey,
      initialDateTime: _selectedDateTime ?? DateTime.now(),
      option: widget.option,
    );

    if (result != null) {
      setState(() {
        _selectedDateTime = result;
      });
    }
  }

  String _formatDateTime() {
    if (_selectedDateTime == null) return 'Tap to select';

    final dateStr = DateFormat('EEE, dd-MMM-yyyy').format(_selectedDateTime!);
    final timeStr = DateFormat('hh:mm:ss a').format(_selectedDateTime!);

    return '$dateStr\n$timeStr';
  }

  String _getOptionLabel() {
    switch (widget.option) {
      case DateTimeOption.dateTime:
        return 'Date & Time';
      case DateTimeOption.date:
        return 'Date Only';
      case DateTimeOption.time:
        return 'Time Only';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'DateTimePickerPopover - ${_getOptionLabel()}',
          style: theme.textTheme.titleLarge,
        ),
        const Gap(24),
        GestureDetector(
          key: _anchorKey,
          onTap: _showPopover,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                const Gap(12),
                Text(
                  _formatDateTime(),
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const Gap(16),
        Text(
          'Tap the field above to open the popover',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
