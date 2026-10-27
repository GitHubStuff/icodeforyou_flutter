// programs/{{name.snakeCase()}}/lib/main.dart

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

/// Run point of the app
class MainApp extends StatelessWidget {
  /// Simple stateless widget
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
