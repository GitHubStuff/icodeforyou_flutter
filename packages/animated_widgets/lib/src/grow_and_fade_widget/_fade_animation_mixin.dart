// lib/src/grow_and_fade_widget/_fade_animation_mixin.dart

import 'package:flutter/widgets.dart';

/// Encapsulates opacity 0→1 animation sharing an existing [AnimationController]
mixin FadeAnimationMixin {
  late Animation<double> fadeAnimation;

  void initFadeAnimation({
    required AnimationController controller,
    required Curve curve,
  }) {
    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }
}
