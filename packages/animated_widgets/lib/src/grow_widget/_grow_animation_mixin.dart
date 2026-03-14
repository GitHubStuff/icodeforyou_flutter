// lib/src/grow_widget/_grow_animation_mixin.dart

import 'package:flutter/widgets.dart';

/// Encapsulates [AnimationController] lifecycle for a scale 0→1 effect.
mixin GrowAnimationMixin {
  late AnimationController _growController;
  late Animation<double> scaleAnimation;

  /// Exposed for mixins that share the same
  /// controller (e.g. [FadeAnimationMixin]).
  @protected
  AnimationController get growController => _growController;

  void initAnimation({
    required TickerProvider vsync,
    required Duration duration,
    required Curve curve,
    VoidCallback? onComplete,
  }) {
    _growController = AnimationController(vsync: vsync, duration: duration);

    scaleAnimation = CurvedAnimation(
      parent: _growController,
      curve: curve,
    );

    if (onComplete != null) {
      _growController.addStatusListener((status) {
        if (status == AnimationStatus.completed) onComplete();
      });
    }
  }

  void startAnimation() => _growController.forward();

  void disposeAnimation() => _growController.dispose();
}
