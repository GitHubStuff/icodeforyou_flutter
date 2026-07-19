import 'package:flutter/material.dart';

class PiledWidget extends StatelessWidget {
  const PiledWidget({
    required this.child,
    this.offset = Offset.zero,
    super.key,
  });

  final Widget child;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [Transform.translate(offset: offset, child: child)],
    );
  }
}
