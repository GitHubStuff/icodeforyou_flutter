// scrolling_datetime_pickers_widgetbook.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:scrolling_datetime_pickers/scrolling_datetime_pickers.dart'
    show ScrollingTimePicker, ScrollingDatePicker, DividerConfiguration;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

part 'scrolling_datetime_pickers_demo_widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SCROLLING TIME PICKER USE CASES
// ═══════════════════════════════════════════════════════════════════════════

@widgetbook.UseCase(name: 'Default', type: ScrollingTimePicker)
Widget buildScrollingTimePickerDefaultCase(BuildContext context) {
  return Center(
    child: ScrollingTimePicker(
      initialDateTime: DateTime.now(),
      onDateTimeChanged: (dateTime) {
        debugPrint('Time changed: ${dateTime.hour}:${dateTime.minute}');
      },
    ),
  );
}

@widgetbook.UseCase(name: 'With Seconds', type: ScrollingTimePicker)
Widget buildScrollingTimePickerWithSecondsCase(BuildContext context) {
  return Center(
    child: ScrollingTimePicker(
      initialDateTime: DateTime.now(),
      showSeconds: true,
      onDateTimeChanged: (dateTime) {
        debugPrint(
          'Time changed: ${dateTime.hour}:${dateTime.minute}:${dateTime.second}',
        );
      },
    ),
  );
}

@widgetbook.UseCase(name: 'Custom Styling', type: ScrollingTimePicker)
Widget buildScrollingTimePickerCustomStylingCase(BuildContext context) {
  final backgroundColor = context.knobs.colorOrNull(
    label: 'Background Color',
    initialValue: const Color(0xFF1A1A2E),
  );

  final dividerColor = context.knobs.colorOrNull(
    label: 'Divider Color',
    initialValue: Colors.blue,
  );

  final borderRadius = context.knobs.double.slider(
    label: 'Border Radius',
    initialValue: 12.0,
    min: 0.0,
    max: 24.0,
  );

  final showSeconds = context.knobs.boolean(
    label: 'Show Seconds',
    initialValue: false,
  );

  final enableHaptics = context.knobs.boolean(
    label: 'Enable Haptics',
    initialValue: true,
  );

  return Center(
    child: ScrollingTimePicker(
      initialDateTime: DateTime.now(),
      showSeconds: showSeconds,
      enableHaptics: enableHaptics,
      backgroundColor: backgroundColor ?? const Color(0xFF1A1A2E),
      borderRadius: borderRadius,
      dividerConfiguration: DividerConfiguration(
        color: dividerColor ?? Colors.blue,
        thickness: 2.0,
      ),
      timeStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      onDateTimeChanged: (dateTime) {
        debugPrint('Time changed: $dateTime');
      },
    ),
  );
}

@widgetbook.UseCase(name: 'Divider Styles', type: ScrollingTimePicker)
Widget buildScrollingTimePickerDividerStylesCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Divider Style Variants',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Gap(24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text('Default'),
                const Gap(8),
                ScrollingTimePicker(
                  portraitSize: const Size(140, 160),
                  initialDateTime: DateTime.now(),
                  dividerConfiguration: const DividerConfiguration(),
                  onDateTimeChanged: (_) {},
                ),
              ],
            ),
            Column(
              children: [
                const Text('With Glow'),
                const Gap(8),
                ScrollingTimePicker(
                  portraitSize: const Size(140, 160),
                  initialDateTime: DateTime.now(),
                  dividerConfiguration: DividerConfiguration.withGlow(
                    color: Colors.cyan,
                    transparency: 0.9,
                  ),
                  onDateTimeChanged: (_) {},
                ),
              ],
            ),
            Column(
              children: [
                const Text('With Blur'),
                const Gap(8),
                ScrollingTimePicker(
                  portraitSize: const Size(140, 160),
                  initialDateTime: DateTime.now(),
                  dividerConfiguration: DividerConfiguration.withBlur(
                    color: Colors.purple,
                    transparency: 0.8,
                  ),
                  onDateTimeChanged: (_) {},
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive Demo', type: ScrollingTimePicker)
Widget buildScrollingTimePickerInteractiveCase(BuildContext context) {
  return const Center(child: _InteractiveTimePickerDemo());
}

// ═══════════════════════════════════════════════════════════════════════════
// SCROLLING DATE PICKER USE CASES
// ═══════════════════════════════════════════════════════════════════════════

@widgetbook.UseCase(name: 'Default', type: ScrollingDatePicker)
Widget buildScrollingDatePickerDefaultCase(BuildContext context) {
  return Center(
    child: ScrollingDatePicker(
      initialDate: DateTime.now(),
      onDateChanged: (date) {
        debugPrint('Date changed: ${date.year}-${date.month}-${date.day}');
      },
    ),
  );
}

@widgetbook.UseCase(name: 'Year-Month-Day Order', type: ScrollingDatePicker)
Widget buildScrollingDatePickerYMDCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Column Order Comparison',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Gap(24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text('Day-Month-Year'),
                const Gap(8),
                ScrollingDatePicker(
                  portraitSize: const Size(160, 180),
                  initialDate: DateTime.now(),
                  dayAscending: true,
                  onDateChanged: (_) {},
                ),
              ],
            ),
            Column(
              children: [
                const Text('Year-Month-Day'),
                const Gap(8),
                ScrollingDatePicker(
                  portraitSize: const Size(160, 180),
                  initialDate: DateTime.now(),
                  dayAscending: false,
                  onDateChanged: (_) {},
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Custom Styling', type: ScrollingDatePicker)
Widget buildScrollingDatePickerCustomStylingCase(BuildContext context) {
  final backgroundColor = context.knobs.colorOrNull(
    label: 'Background Color',
    initialValue: const Color(0xFF1A1A2E),
  );

  final dividerColor = context.knobs.colorOrNull(
    label: 'Divider Color',
    initialValue: Colors.green,
  );

  final borderRadius = context.knobs.double.slider(
    label: 'Border Radius',
    initialValue: 12.0,
    min: 0.0,
    max: 24.0,
  );

  final dayAscending = context.knobs.boolean(
    label: 'Day-Month-Year Order',
    initialValue: true,
  );

  final enableHaptics = context.knobs.boolean(
    label: 'Enable Haptics',
    initialValue: true,
  );

  return Center(
    child: ScrollingDatePicker(
      initialDate: DateTime.now(),
      dayAscending: dayAscending,
      enableHaptics: enableHaptics,
      backgroundColor: backgroundColor ?? const Color(0xFF1A1A2E),
      borderRadius: borderRadius,
      dividerConfiguration: DividerConfiguration(
        color: dividerColor ?? Colors.green,
        thickness: 2.0,
      ),
      dateStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      onDateChanged: (date) {
        debugPrint('Date changed: $date');
      },
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive Demo', type: ScrollingDatePicker)
Widget buildScrollingDatePickerInteractiveCase(BuildContext context) {
  return const Center(child: _InteractiveDatePickerDemo());
}

@widgetbook.UseCase(name: 'Theme Showcase', type: ScrollingDatePicker)
Widget buildScrollingDatePickerThemeShowcaseCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Theme Showcase', style: Theme.of(context).textTheme.titleLarge),
        const Gap(24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text('Dark'),
                const Gap(8),
                ScrollingDatePicker(
                  portraitSize: const Size(150, 170),
                  initialDate: DateTime.now(),
                  backgroundColor: const Color(0xFF0D0D0D),
                  borderRadius: 16.0,
                  dividerConfiguration: DividerConfiguration.withGlow(
                    color: Colors.white24,
                  ),
                  dateStyle: const TextStyle(color: Colors.white, fontSize: 16),
                  onDateChanged: (_) {},
                ),
              ],
            ),
            Column(
              children: [
                const Text('Light'),
                const Gap(8),
                ScrollingDatePicker(
                  portraitSize: const Size(150, 170),
                  initialDate: DateTime.now(),
                  backgroundColor: Colors.white,
                  borderRadius: 16.0,
                  dividerConfiguration: const DividerConfiguration(
                    color: Colors.black12,
                  ),
                  dateStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  onDateChanged: (_) {},
                ),
              ],
            ),
            Column(
              children: [
                const Text('Accent'),
                const Gap(8),
                ScrollingDatePicker(
                  portraitSize: const Size(150, 170),
                  initialDate: DateTime.now(),
                  backgroundColor: const Color(0xFF1B5E20),
                  borderRadius: 16.0,
                  dividerConfiguration: DividerConfiguration.withGlow(
                    color: Colors.lightGreenAccent,
                    transparency: 0.8,
                  ),
                  dateStyle: const TextStyle(
                    color: Colors.lightGreenAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  onDateChanged: (_) {},
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
