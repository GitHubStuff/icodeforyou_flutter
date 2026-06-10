// programs/startup_demo/lib/src/pages/demo_page.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:settings_widget/settings_widget.dart' show SettingsWidget;
import 'package:startup_demo/src/settings_widget/app_settings_entries.dart'
    show NotificationsEntry, ThemeEntry;

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings Demo')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(
            Icons.lightbulb_sharp,
            size: 40,
          ),
          label: const Text('Demo'),
          onPressed: () => SettingsWidget.show(
            context,
            entries: [
              const ThemeEntry(),
              const NotificationsEntry(),
            ],
          ),
        ),
      ),
    );
  }
}
