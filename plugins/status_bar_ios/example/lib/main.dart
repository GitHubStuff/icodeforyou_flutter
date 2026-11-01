// plugins/status_bar_ios/example/lib/main.dart

import 'package:flutter/material.dart';
import 'package:status_bar_ios/status_bar_ios.dart' show StatusBar;

Future<void> main() async {
  // Required before any plugin call that happens before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Hide before the first frame so the bar is never seen at launch.
  await StatusBar.setVisibility(isHidden: true);
  runApp(const StatusBarExampleApp());
}

/// Proof-of-concept app that toggles the status bar visibility.
class StatusBarExampleApp extends StatelessWidget {
  /// Creates the example app.
  const StatusBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      home: const StatusBarTogglePage(),
    );
  }
}

/// Page with a single centered button that toggles the status bar.
class StatusBarTogglePage extends StatefulWidget {
  /// Creates the toggle page.
  const StatusBarTogglePage({super.key});

  @override
  State<StatusBarTogglePage> createState() => _StatusBarTogglePageState();
}

class _StatusBarTogglePageState extends State<StatusBarTogglePage> {
  /// Mirrors the call made in `main()`.
  bool _isHidden = true;

  Future<void> _toggle() async {
    final isHidden = !_isHidden;
    await StatusBar.setVisibility(isHidden: isHidden);
    if (!mounted) {
      return;
    }
    setState(() {
      _isHidden = isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = _isHidden ? 'Show Status Bar' : 'Hide Status Bar';
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: _toggle, child: Text(label)),
      ),
    );
  }
}
