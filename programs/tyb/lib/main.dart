// programs/tyb/lib/main.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:island_control_ios/island_control_ios.dart'
    show IslandControlIos;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(IslandControlIos.setIsland(isHidden: true));
  runApp(const MainApp());
}

/// Run point of the app
class MainApp extends StatelessWidget {
  /// Simple stateless widget
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: IslandToggle()),
      ),
    );
  }
}

/// One button: tapping it toggles the island between hidden and shown.
class IslandToggle extends StatefulWidget {
  /// Creates the toggle, starting from a hidden island.
  const IslandToggle({super.key});

  @override
  State<IslandToggle> createState() => _IslandToggleState();
}

class _IslandToggleState extends State<IslandToggle> {
  bool _isHidden = true;

  void _toggle() {
    final isHidden = !_isHidden;
    setState(() => _isHidden = isHidden);
    unawaited(IslandControlIos.setIsland(isHidden: isHidden));
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _toggle,
      child: Text(
        _isHidden ? 'Show island' : 'Hide island',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
