// lib/src/landing_page.dart

import 'package:flutter/material.dart';
import 'package:startup_demo/src/settings_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Landing Page')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage())),
        child: const Icon(Icons.settings),
      ),
    );
  }
}
