// programs/{{name.snakeCase()}}/lib/main.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:island_control_android/island_control_android.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(IslandControlAndroid().setIsland(isHidden: true));
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
