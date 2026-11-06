// packages/demo/lib/popover_toast_demo/static_child_demo.dart

import 'package:flutter/material.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:popover_toast/popover_toast.dart' show PopoverToast;

// import 'package:haptic_intensity/haptic_intensity.dart';
// import 'package:popover_toast/popover_toast.dart';

// void main() => runApp(const ExampleApp());

/// Minimal app that pops a [PopoverToast] from one button.
class StaticChildDemo extends StatelessWidget {
  ///
  const StaticChildDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: ToastButton()),
      ),
    );
  }
}

/// A button that shows a "Saved" toast when tapped.
class ToastButton extends StatelessWidget {
  /// Creates the button.
  const ToastButton({super.key});

  Future<void> _showToast(BuildContext context) {
    return PopoverToast.show<void>(
      context,
      duration: const Duration(milliseconds: 750),
      barrierDismissible: true,
      alignment: const Alignment(0, 0.25),
      barrierColor: Colors.black87,
      haptic: HapticIntensity.light,
      child: const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Saved'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showToast(context),
      child: const Text('Show toast'),
    );
  }
}
