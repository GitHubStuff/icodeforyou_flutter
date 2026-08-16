// programs/startup_demo/lib/src/pages/settings_page.dart

import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Deprecated',
          ),
        ),
      ),
    );
  }
}
