// programs/pookie/lib/main.dart

import 'package:flutter/material.dart';
import 'package:island_control/island_control.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //IslandControl.setIsland(isHidden: true);
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
        body: Center(child: Text('Hello World!')),
      ),
    );
  }
}
