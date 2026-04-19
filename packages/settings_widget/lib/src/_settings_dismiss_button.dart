// ignore_for_file: public_member_api_docs

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
