// lib/src/_settings_transition.dart

import 'package:flutter/material.dart';
import 'package:settings_widget/src/_settings_direction.dart';

class SettingsTransition extends StatelessWidget {
  const SettingsTransition({
    required this.animation,
    required this.direction,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final SettingsDirection direction;
  final Widget child;

  Offset _beginOffset() {
    return switch (direction) {
      SettingsDirection.bottom => const Offset(0, 1),
      SettingsDirection.top    => const Offset(0, -1),
      SettingsDirection.left   => const Offset(-1, 0),
      SettingsDirection.right  => const Offset(1, 0),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: _beginOffset(),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      ),
      child: child,
    );
  }
}
