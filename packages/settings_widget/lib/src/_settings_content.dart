// lib/src/_settings_content.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:settings_widget/src/_app_settings_entry.dart';
import 'package:settings_widget/src/_settings_dismiss_button.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({
    required this.title,
    required this.entries,
    required this.onDismiss,
    super.key,
  });

  final Widget title;
  final List<AppSettingsEntry> entries;
  final VoidCallback onDismiss;

  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsDismissButton(onDismiss: onDismiss),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gap),
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            child: title,
          ),
        ),
        const Gap(_gap),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(_gap),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _spacedEntries,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> get _spacedEntries {
    final spaced = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      spaced.add(entries[i]);
      if (i < entries.length - 1) spaced.add(const Gap(_gap));
    }
    return spaced;
  }
}
