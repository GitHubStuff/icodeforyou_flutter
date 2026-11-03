// packages/demo/lib/status_bar_visibility/make_status_bar_ready.dart
import 'dart:async' show unawaited;

import 'package:demo/status_bar_visibility/status_bar_visibility_demo.dart'
    show StatusBarVisibilityDemo;
import 'package:flutter/material.dart';
import 'package:status_bar_visibility/status_bar_visibility.dart'
    show StatusBarVisibility;

/// Initialises [StatusBarVisibility] once, showing a spinner until
/// it is ready, then hands the live instance to [StatusBarVisibilityDemo].
class MakeStatusBarReady extends StatefulWidget {
  /// Creates the gate widget
  const MakeStatusBarReady({super.key});

  @override
  State<MakeStatusBarReady> createState() => _MakeStatusBarReadyState();
}

class _MakeStatusBarReadyState extends State<MakeStatusBarReady> {
  bool _isReady = false;

  late final StatusBarVisibility visibility;

  @override
  void initState() {
    super.initState();
    unawaited(_makeFramework());
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return Center(
      child: StatusBarVisibilityDemo(
        controller: visibility,
      ),
    );
  }

  Future<void> _makeFramework() async {
    visibility = StatusBarVisibility();
    if (!mounted) return;
    setState(() => _isReady = true);
  }
}
