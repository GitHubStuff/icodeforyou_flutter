// programs/since_when_dev/lib/home/home_screen.dart

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:since_when_dev/main_app/configure_dependencies.dart' show getIt;
import 'package:since_when_dev/menu_bar/menu_bar_screen.dart'
    show MenuBarScreen;
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;

/// POC home: a single switch that hides or shows the status bar.
class HomeScreen extends StatelessWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  /// Route of this screen.
  static const String route = '/home';

  @override
  Widget build(BuildContext context) {
    unawaited(
      getIt<StatusBarVisibilityAbstract>().setStatusBarVisibility(
        isHidden: false,
      ),
    );
    // This is the widget that appears after
    return MenuBarScreen();
  }
}
