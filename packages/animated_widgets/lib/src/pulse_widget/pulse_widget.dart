// packages/animated_widgets/lib/src/pulse_widget/src/pulse_widget.dart
import 'package:animated_widgets/src/combination_animation/extensions/animates_widget.dart'
    show AnimatesWidgetExt;
import 'package:animated_widgets/src/combination_animation/tweens/animation_tween.dart'
    show AnimationTween;
import 'package:flutter/material.dart';

/// Scales [child] through a single pulse: grow, hold, then shrink.
///
/// The motion uses `easeOut` on the way up so it settles into the held
/// peak, and `easeIn` on the way down so it departs the peak smoothly
/// before returning to rest. Tune the motion with [rate] and [peakScale].
class PulseWidget extends StatelessWidget {
  /// Creates a [PulseWidget] that pulses [child] once per build.
  ///
  /// [rate] sets the duration of each leg and [peakScale] the apex scale;
  /// both default to a brisk, attention-drawing pulse. [onComplete] fires
  /// when the pulse finishes.
  const PulseWidget({
    required this.child,
    super.key,
    this.rate = const Duration(milliseconds: 150),
    this.peakScale = 1.15,
    this.onComplete,
  });

  /// The widget scaled by the pulse sequence.
  ///
  /// [PulseWidget] adds no layout of its own, so [child] keeps its natural
  /// size and position apart from the transient scale transform.
  final Widget child;

  /// The duration of each leg of the pulse: grow, hold, and shrink.
  ///
  /// All three legs share this value, so the complete pulse runs for
  /// `rate * 3`. Shorter values read as a sharper, more urgent pulse;
  /// longer values as a slower, breathing one. Defaults to 150ms.
  final Duration rate;

  /// The scale multiplier reached at the apex of the pulse.
  ///
  /// `1.0` leaves [child] at its natural size (no visible pulse); values
  /// above `1.0` enlarge it at the peak, so `1.15` grows [child] by 15%
  /// before returning to rest. Defaults to `1.15`.
  final double peakScale;

  /// Called once when the final shrink leg completes and [child] has
  /// returned to its resting scale.
  ///
  /// Optional; omit it when the caller does not need to react to the end
  /// of the pulse.
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return child
        .animatedSteps(
          scale: AnimationTween.up(start: 1, finish: peakScale),
          duration: rate,
          curve: Curves.easeOut,
        )
        .step(
          scale: AnimationTween(
            start: peakScale,
            finish: peakScale,
          ),
          duration: rate,
        )
        .step(
          scale: AnimationTween.down(
            start: peakScale,
            finish: 1,
          ),
          duration: rate,
          curve: Curves.easeIn,
          onComplete: onComplete,
        );
  }
}
