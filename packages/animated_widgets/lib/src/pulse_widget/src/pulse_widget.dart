// ignore_for_file: always_use_package_imports, public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart'
    show AnimationTween, CombinationAnimationStep, CombinationAnimationX;
import 'package:flutter/material.dart';

import 'pulse_config.dart' show PulseConfig;

/// Pulses [child] through a hold → grow → shrink scale sequence.
///
/// [PulseWidget] is layout-transparent: it occupies exactly the space its
/// [child] would have occupied (modulo the scale transform during the pulse)
/// and imposes no alignment of its own. Parents are responsible for
/// positioning.
///
/// The [Key] passed via [key] is used only to identify this widget in its
/// parent's child list, per standard Flutter conventions. The internal
/// animation identity is owned by [PulseWidget] itself and is independent
/// of [key]; callers may pass any key (or none) without affecting animation
/// behavior.
class PulseWidget extends StatefulWidget {
  const PulseWidget({
    required this.child,
    super.key,
    this.config = const PulseConfig(),
  });

  final Widget child;
  final PulseConfig config;

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget> {
  /// Stable identity for the animation, tied to this [State] instance.
  ///
  /// Created once in [initState] so the animation's identity does not change
  /// across rebuilds and is not influenced by whatever [Key] the parent
  /// passes to [PulseWidget].
  late final Key _animationKey;

  late final PulseConfig config;

  @override
  void initState() {
    super.initState();
    _animationKey = UniqueKey();
    config = widget.config;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child.combinationAnimationSequenced(
      key: _animationKey,
      [
        // Hold at rest so the starting size is visible before motion.
        CombinationAnimationStep(
          scale: AnimationTween(
            start: config.pulseStartScale,
            finish: config.pulseRestScale,
          ),
          duration: config.holdDuration,
        ),
        // Grow to peak.
        CombinationAnimationStep(
          scale: AnimationTween(
            start: config.pulseRestScale,
            finish: config.pulsePeakScale,
          ),
          duration: config.growDuration,
          curve: config.growCurve,
        ),
        // Return to rest.
        CombinationAnimationStep(
          scale: AnimationTween(
            start: config.pulsePeakScale,
            finish: config.pulseRestScale,
          ),
          duration: config.shrinkDuration,
          curve: config.shrinkCurve,
        ),
      ],
    );
  }
}
