// programs/since_when_dev/lib/main_body.dart

import 'package:flutter/material.dart';
import 'package:place_holder_widget/place_holder_widget.dart'
    show PlaceholderWidget;

import '../home/home_screen.dart' show HomeScreen;

/// Root of the development app.
class MainBody extends StatelessWidget {
  /// Creates the app.
  const MainBody({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Since When (dev)',
      theme: ThemeData.dark(),
    );
  }
}

/// The app's launch splash: black to match the native launch screen, with
/// the startup tasks wired in.
class _LaunchSplash extends StatelessWidget {
  const _LaunchSplash();

  static const Duration _timeout = Duration(seconds: 3);

  @override
  Widget build(BuildContext context) {
    return const PlaceholderWidget();
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(HomeScreen.route);
  }

  /// POC policy: a launch failure is fatal and should be loud.
  void _failFast(BuildContext context, Object error) {
    throw StateError('Launch failed: $error');
  }
}
