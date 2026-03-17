// packages/rail_menu/lib/src/model/rail_menu_item.dart

import 'package:flutter/widgets.dart';

/// Controls how a [RailMenuItem] animates onto the screen when navigated to.
enum RailMenuTransition {
  /// Slides in from the left edge.
  slideFromLeft,

  /// Slides in from the right edge.
  slideFromRight,

  /// Fades in.
  fade,

  /// No animation.
  none,
}

/// A single item in a [RailMenu].
///
/// The [child] must be a purely visual widget with no embedded
/// gesture detection. All tap handling is owned by [onTap], which
/// the package invokes safely after dismissing any visible modal.
class RailMenuItem {
  /// Creates a [RailMenuItem].
  const RailMenuItem({
    required this.child,
    this.onTap,
    this.enableHaptic = true,
    this.transitionFromLeft = RailMenuTransition.slideFromLeft,
    this.transitionFromRight = RailMenuTransition.slideFromRight,
  });

  /// The visual representation of this item.
  ///
  /// Must be a pure visual widget with no embedded gesture detection.
  final Widget child;

  /// Called after any visible modal has been fully dismissed.
  final VoidCallback? onTap;

  /// Whether to trigger haptic feedback when this item is tapped.
  ///
  /// Haptic fires only when the tap is not a no-op (i.e. item is not active).
  final bool enableHaptic;

  /// The transition used when navigating to this item from a higher index.
  final RailMenuTransition transitionFromLeft;

  /// The transition used when navigating to this item from a lower index.
  final RailMenuTransition transitionFromRight;
}
