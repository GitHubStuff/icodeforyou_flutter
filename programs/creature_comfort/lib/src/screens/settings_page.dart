// programs/creature_comfort/lib/src/screens/settings_page.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:service_locator/service_locator.dart' show ServiceRegistry;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Dont use as this..'),
        ),
      ),
    );
  }
}
