// animated_widgets/lib/src/grow_and_fade_widget/_fade_animation_mixin.dart
import 'package:flutter/widgets.dart';

/// Encapsulates an opacity 0.0→1.0 animation driven by an
/// existing [AnimationController].
mixin FadeAnimationMixin {
  /// The opacity animation, initialised by [initFadeAnimation].
  late Animation<double> fadeAnimation;

  /// Initialises [fadeAnimation] using the provided [controller] and [curve].
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
