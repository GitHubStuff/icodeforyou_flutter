// scrolling_datetime_pickers_demo_widgets.dart
part of 'scrolling_datetime_pickers_widgetbook.dart';

class _InteractiveTimePickerDemo extends StatefulWidget {
  const _InteractiveTimePickerDemo();

  @override
  State<_InteractiveTimePickerDemo> createState() =>
      _InteractiveTimePickerDemoState();
}

class _InteractiveTimePickerDemoState
    extends State<_InteractiveTimePickerDemo> {
  DateTime _selectedTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Interactive Time Picker',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Gap(16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Selected Time',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Gap(4),
              Text(
                '${_selectedTime.hour.toString().padLeft(2, '0')}:'
                '${_selectedTime.minute.toString().padLeft(2, '0')}:'
                '${_selectedTime.second.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const Gap(24),
        ScrollingTimePicker(
          initialDateTime: _selectedTime,
          showSeconds: true,
          borderRadius: 12.0,
          dividerConfiguration: DividerConfiguration.withGlow(
            color: Theme.of(context).colorScheme.primary,
          ),
          onDateTimeChanged: (dateTime) {
            setState(() {
              _selectedTime = dateTime;
            });
          },
        ),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.tonal(
              onPressed: () {
                setState(() {
                  _selectedTime = DateTime.now();
                });
              },
              child: const Text('Reset to Now'),
            ),
            const Gap(12),
            FilledButton.tonal(
              onPressed: () {
                setState(() {
                  _selectedTime = DateTime(
                    _selectedTime.year,
                    _selectedTime.month,
                    _selectedTime.day,
                    12,
                    0,
                    0,
                  );
                });
              },
              child: const Text('Set to Noon'),
            ),
          ],
        ),
      ],
    );
  }
}

class _InteractiveDatePickerDemo extends StatefulWidget {
  const _InteractiveDatePickerDemo();

  @override
  State<_InteractiveDatePickerDemo> createState() =>
      _InteractiveDatePickerDemoState();
}

class _InteractiveDatePickerDemoState
    extends State<_InteractiveDatePickerDemo> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Interactive Date Picker',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Gap(16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Selected Date',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Gap(4),
              Text(
                '${_selectedDate.year}-'
                '${_selectedDate.month.toString().padLeft(2, '0')}-'
                '${_selectedDate.day.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const Gap(24),
        ScrollingDatePicker(
          initialDate: _selectedDate,
          borderRadius: 12.0,
          dividerConfiguration: DividerConfiguration.withGlow(
            color: Theme.of(context).colorScheme.primary,
          ),
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        ),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.tonal(
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime.now();
                });
              },
              child: const Text('Reset to Today'),
            ),
            const Gap(12),
            FilledButton.tonal(
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime(2000, 1, 1);
                });
              },
              child: const Text('Set to Y2K'),
            ),
          ],
        ),
      ],
    );
  }
}
