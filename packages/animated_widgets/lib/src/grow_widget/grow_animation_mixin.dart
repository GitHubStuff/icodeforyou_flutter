// animated_widgets/lib/src/grow_widget/_grow_animation_mixin.dart
import 'package:animated_widgets/src/grow_and_fade_widget/_fade_animation_mixin.dart'
    show FadeAnimationMixin;
import 'package:flutter/widgets.dart';

/// Encapsulates [AnimationController] lifecycle for a scale 0→1 effect.
mixin GrowAnimationMixin {
  late AnimationController _growController;

  /// The scale animation driven from 0.0 to 1.0.
  late Animation<double> scaleAnimation;

  /// Exposed for mixins that share the same
  /// controller (e.g. [FadeAnimationMixin]).
  @protected
  AnimationController get growController => _growController;

  /// Initialises the [AnimationController] and [scaleAnimation].
  ///
  /// [onComplete] is called once when the animation reaches
  /// [AnimationStatus.completed].
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

  /// Starts the scale animation by running the controller forward.
  void startAnimation() => _growController.forward();

  /// Disposes the [AnimationController] — call from [State.dispose].
  void disposeAnimation() => _growController.dispose();
}
