// packages/custom_widgets/lib/src/full_screen_color/full_screen_color.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

class FullScreenColor extends StatelessWidget {
  const FullScreenColor({this.color = Colors.black, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(color: color),
    );
  }
}
