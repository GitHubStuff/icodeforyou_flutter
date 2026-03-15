// lib/src/_settings_dismiss_button.dart

import 'package:flutter/material.dart';

class SettingsDismissButton extends StatelessWidget {
  const SettingsDismissButton({
    required this.onDismiss,
    super.key,
  });

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onDismiss,
      ),
    );
  }
}
