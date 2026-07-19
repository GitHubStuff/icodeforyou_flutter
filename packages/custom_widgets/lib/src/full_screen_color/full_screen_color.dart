// packages/custom_widgets/lib/src/full_screen_color/full_screen_color.dart

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
