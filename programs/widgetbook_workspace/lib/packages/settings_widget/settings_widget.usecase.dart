// lib/packages/settings_widget/lib/src/settings_widget.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:settings_widget/settings_widget.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: SettingsWidgetShowcase)
Widget settingsWidgetUseCase(BuildContext context) {
  final direction = context.knobs.object.dropdown<SettingsDirection>(
    label: 'direction',
    options: SettingsDirection.values,
    initialOption: SettingsDirection.bottom,
    labelBuilder: (d) => d.name,
  );

  final edgeGap = context.knobs.double.slider(
    label: 'edgeGap',
    initialValue: 16,
    min: 0,
    max: 80,
  );

  return SettingsWidgetShowcase(direction: direction, edgeGap: edgeGap);
}

/// Showcase for [SettingsWidget.show], a static method on a non-widget class.
/// Builds three concrete [AppSettingsEntry] subclasses and surfaces a button
/// that opens the sheet.
class SettingsWidgetShowcase extends StatelessWidget {
  const SettingsWidgetShowcase({
    required this.direction,
    required this.edgeGap,
    super.key,
  });

  final SettingsDirection direction;
  final double edgeGap;

  void _open(BuildContext context) {
    SettingsWidget.show(
      context,
      direction: direction,
      edgeGap: edgeGap,
      entries: const [
        _ToggleEntry(label: 'Enable haptics', initial: true),
        _ToggleEntry(label: 'Show seconds', initial: false),
        _LinkEntry(label: 'About'),
        _LinkEntry(label: 'Privacy policy'),
        _LinkEntry(label: 'Open source licenses'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        onPressed: () => _open(context),
        icon: const Icon(Icons.settings),
        label: const Text('Open settings'),
      ),
    );
  }
}

class _ToggleEntry extends AppSettingsEntry {
  const _ToggleEntry({required this.label, required this.initial});

  final String label;
  final bool initial;

  @override
  Widget get title => Text(label);

  @override
  Widget build(BuildContext context) {
    return _ToggleEntryView(title: title, initial: initial);
  }
}

class _ToggleEntryView extends StatefulWidget {
  const _ToggleEntryView({required this.title, required this.initial});

  final Widget title;
  final bool initial;

  @override
  State<_ToggleEntryView> createState() => _ToggleEntryViewState();
}

class _ToggleEntryViewState extends State<_ToggleEntryView> {
  late bool _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Expanded(child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 16),
            child: widget.title,
          )),
          const Gap(12),
          Switch(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
          ),
        ],
      ),
    );
  }
}

class _LinkEntry extends AppSettingsEntry {
  const _LinkEntry({required this.label});

  final String label;

  @override
  Widget get title => Text(label);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Expanded(child: DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 16),
              child: title,
            )),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
