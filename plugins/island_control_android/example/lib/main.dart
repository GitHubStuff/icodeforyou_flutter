import 'dart:async';

import 'package:flutter/material.dart';
import 'package:island_control_android/island_control_android.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final islandControl = IslandControlAndroid();
  unawaited(islandControl.setIsland(isHidden: true));
  runApp(ExampleApp(islandControl: islandControl));
}

/// One switch: on hides the island instantly, off shows it.
class ExampleApp extends StatefulWidget {
  /// Creates the example app.
  const ExampleApp({required this.islandControl, super.key});

  /// Shows or hides the island.
  final IslandControlAndroid islandControl;

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  bool _isHidden = true;

  void _onChanged(bool isHidden) {
    setState(() => _isHidden = isHidden);
    unawaited(widget.islandControl.setIsland(isHidden: isHidden));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Switch(value: _isHidden, onChanged: _onChanged),
        ),
      ),
    );
  }
}
