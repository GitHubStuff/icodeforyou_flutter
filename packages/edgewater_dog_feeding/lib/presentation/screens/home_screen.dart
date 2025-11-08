// home_screen.dart
import 'package:flutter/material.dart';
import 'feeding_screen.dart';
import 'settings_screen.dart';

/// Home screen that displays feeding tracker
/// Single Responsibility: Main app navigation container
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding Critter Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: const FeedingScreen(),
    );
  }
}
