// packages/settings_widget/lib/src/settings_transition.dart
import 'package:flutter/material.dart';
import 'package:settings_widget/src/settings_direction.dart';

/// Slides its [child] into place from the edge indicated by [direction].
///
/// Wraps a [SlideTransition] whose offset tween begins one full widget-length
/// off-screen — below, above, left, or right per [SettingsDirection] — and
/// ends at [Offset.zero], eased with [Curves.easeOutCubic] for a fast start
/// and gentle settle.
///
/// Reversing [animation] plays the same path backwards, sliding the child
/// out toward its origin edge, so a single instance serves both entrance
/// and exit.
///
/// Typically used as the `transitionBuilder` layer of the settings overlay
/// route, with [animation] supplied by the route itself.
class SettingsTransition extends StatelessWidget {
  /// Creates a directional slide transition for the settings surface.
  const SettingsTransition({
    required this.animation,
    required this.direction,
    required this.child,
    super.key,
  });

  /// The driving animation, expected to run from 0.0 (fully off-screen)
  /// to 1.0 (fully in place).
  ///
  /// Usually a route's animation. The [Curves.easeOutCubic] curve is applied
  /// internally; pass the raw animation, not a pre-curved one.
  final Animation<double> animation;

  /// The screen edge the [child] slides in from.
  final SettingsDirection direction;

  /// The widget being animated — typically the settings panel itself.
  final Widget child;

  /// The tween's starting offset, in fractional units of the child's size,
  /// for the current [direction].
  ///
  /// `(0, 1)` starts one full height below, `(0, -1)` above, `(-1, 0)` to
  /// the left, and `(1, 0)` to the right. The switch is exhaustive over
  /// [SettingsDirection], so adding a new direction is a compile error
  /// until handled here.
  Offset _beginOffset() {
    return switch (direction) {
      SettingsDirection.bottom => const Offset(0, 1),
      SettingsDirection.top => const Offset(0, -1),
      SettingsDirection.left => const Offset(-1, 0),
      SettingsDirection.right => const Offset(1, 0),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position:
          Tween<Offset>(
            begin: _beginOffset(),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
      child: child,
    );
  }
}
