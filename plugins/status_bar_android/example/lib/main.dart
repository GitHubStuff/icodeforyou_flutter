// plugins/status_bar_android/example/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:status_bar_android/status_bar_android.dart' show StatusBar;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /*
  Two things to know:
  - The example app’s SystemUiMode.edgeToEdge call in main() stays. Without 
    it the window still “fits system windows”, so hiding the bar would resize 
    the Flutter view instead of just changing the inset.

  - Once this is wired, lib/src/status_bar.dart stops calling SystemChrome
    and goes through the channel instead — that’s in the Dart batch after
    the Kotlin test.
  */

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await StatusBar.setVisibility(isHidden: true);
  runApp(const StatusBarExampleApp());
}

/// Proof-of-concept app that toggles the status bar visibility.
class StatusBarExampleApp extends StatelessWidget {
  /// Creates the example app.
  const StatusBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: StatusBarTogglePage());
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
