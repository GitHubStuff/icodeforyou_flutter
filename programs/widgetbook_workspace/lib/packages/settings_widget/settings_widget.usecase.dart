// lib/packages/settings_widget/settings_widget.usecase.dart

import 'package:flutter/material.dart';
import 'package:settings_widget/settings_widget.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// Stub entry
// ---------------------------------------------------------------------------

class _StubSettingsEntry extends AppSettingsEntry {
  const _StubSettingsEntry({required this.label});

  final String label;

  @override
  Widget get title => Text(label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared host
// ---------------------------------------------------------------------------

class _SettingsHost extends StatelessWidget {
  const _SettingsHost({
    required this.entries,
    required this.label,
    this.title,
    this.breakpoint,
    this.direction = SettingsDirection.bottom,
    this.edgeGap = 16,
  });

  final List<AppSettingsEntry> entries;
  final String label;
  final Widget? title;
  final double? breakpoint;
  final SettingsDirection direction;
  final double edgeGap;


  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => SettingsWidget.show(
          context,
          entries: entries,
          title: title ??
              const Text(
                'Settings...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
          breakpoint: breakpoint ?? 600,
          direction: direction,
          edgeGap: edgeGap,
        ),
        child: Text(label),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Use cases — direction
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Slide from Bottom', type: SettingsWidget)
Widget settingsWidgetDefault(BuildContext context) {
  return const _SettingsHost(
    label: 'Open Settings',
    direction: SettingsDirection.bottom,
    entries: [
      _StubSettingsEntry(label: 'Setting One'),
      _StubSettingsEntry(label: 'Setting Two'),
      _StubSettingsEntry(label: 'Setting Three'),
    ],
  );
}

@widgetbook.UseCase(name: 'Slide from Top', type: SettingsWidget)
Widget settingsWidgetFromTop(BuildContext context) {
  return const _SettingsHost(
    label: 'Open Settings (Top)',
    direction: SettingsDirection.top,
    entries: [
      _StubSettingsEntry(label: 'Setting One'),
      _StubSettingsEntry(label: 'Setting Two'),
      _StubSettingsEntry(label: 'Setting Three'),
    ],
  );
}

@widgetbook.UseCase(name: 'Slide from Left', type: SettingsWidget)
Widget settingsWidgetFromLeft(BuildContext context) {
  return const _SettingsHost(
    label: 'Open Settings (Left)',
    direction: SettingsDirection.left,
    entries: [
      _StubSettingsEntry(label: 'Setting One'),
      _StubSettingsEntry(label: 'Setting Two'),
      _StubSettingsEntry(label: 'Setting Three'),
    ],
  );
}

@widgetbook.UseCase(name: 'Slide from Right', type: SettingsWidget)
Widget settingsWidgetFromRight(BuildContext context) {
  return const _SettingsHost(
    label: 'Open Settings (Right)',
    direction: SettingsDirection.right,
    entries: [
      _StubSettingsEntry(label: 'Setting One'),
      _StubSettingsEntry(label: 'Setting Two'),
      _StubSettingsEntry(label: 'Setting Three'),
    ],
  );
}

// ---------------------------------------------------------------------------
// Use cases — edge gap
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Large Edge Gap', type: SettingsWidget)
Widget settingsWidgetLargeGap(BuildContext context) {
  return const _SettingsHost(
    label: 'Open Settings (Large Gap)',
    edgeGap: 48,
    entries: [
      _StubSettingsEntry(label: 'Setting One'),
      _StubSettingsEntry(label: 'Setting Two'),
      _StubSettingsEntry(label: 'Setting Three'),
    ],
  );
}

@widgetbook.UseCase(name: 'No Edge Gap', type: SettingsWidget)
Widget settingsWidgetNoGap(BuildContext context) {
  return const _SettingsHost(
    label: 'Open Settings (No Gap)',
    edgeGap: 0,
    entries: [
      _StubSettingsEntry(label: 'Setting One'),
      _StubSettingsEntry(label: 'Setting Two'),
      _StubSettingsEntry(label: 'Setting Three'),
    ],
  );
}

// ---------------------------------------------------------------------------
// Use cases — layout
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Custom Title', type: SettingsWidget)
Widget settingsWidgetCustomTitle(BuildContext context) {
  return const _SettingsHost(
    label: 'Open Settings (Custom Title)',
    title: Text(
      'Preferences',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    entries: [
      _StubSettingsEntry(label: 'Setting One'),
      _StubSettingsEntry(label: 'Setting Two'),
    ],
  );
}

@widgetbook.UseCase(name: 'Many Entries (Scrollable)', type: SettingsWidget)
Widget settingsWidgetScrollable(BuildContext context) {
  return const _SettingsHost(
    label: 'Open Settings (Scrollable)',
    entries: [
      _StubSettingsEntry(label: 'Setting One'),
      _StubSettingsEntry(label: 'Setting Two'),
      _StubSettingsEntry(label: 'Setting Three'),
      _StubSettingsEntry(label: 'Setting Four'),
      _StubSettingsEntry(label: 'Setting Five'),
      _StubSettingsEntry(label: 'Setting Six'),
      _StubSettingsEntry(label: 'Setting Seven'),
      _StubSettingsEntry(label: 'Setting Eight'),
    ],
  );
}

@widgetbook.UseCase(name: 'Single Entry', type: SettingsWidget)
Widget settingsWidgetSingleEntry(BuildContext context) {
  return const _SettingsHost(
    label: 'Open Settings (Single)',
    entries: [
      _StubSettingsEntry(label: 'Only Setting'),
    ],
  );
}

@widgetbook.UseCase(name: 'Force Tablet Layout', type: SettingsWidget)
Widget settingsWidgetTablet(BuildContext context) {
  return const _SettingsHost(
    label: 'Open Settings (Tablet)',
    breakpoint: 0,
    entries: [
      _StubSettingsEntry(label: 'Setting One'),
      _StubSettingsEntry(label: 'Setting Two'),
      _StubSettingsEntry(label: 'Setting Three'),
    ],
  );
}

@widgetbook.UseCase(name: 'Force Phone Layout', type: SettingsWidget)
Widget settingsWidgetPhone(BuildContext context) {
  return const _SettingsHost(
    label: 'Open Settings (Phone)',
    breakpoint: double.infinity,
    entries: [
      _StubSettingsEntry(label: 'Setting One'),
      _StubSettingsEntry(label: 'Setting Two'),
      _StubSettingsEntry(label: 'Setting Three'),
    ],
  );
}
