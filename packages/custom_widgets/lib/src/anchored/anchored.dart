// packages/custom_widgets/lib/src/anchored/anchored.dart

import 'package:extensions/enum/src/placement.dart' show Placement;
import 'package:flutter/widgets.dart';

/// Positions a child relative to an anchor widget, using a [Placement] plus
/// an optional additive [offset].
///
/// The anchor ([toAnchor]) is laid out first and defines the box the child
/// ([child]) is positioned within; the child is then aligned to
/// [atPlacement] over that box. [offset] is applied after alignment,
/// nudging the child away from the resolved position — e.g.,
/// [Placement.center] with `offset: Offset(0, -8)` sits centered, then 8
/// logical pixels up.
///
/// The child is not clipped to the anchor ([Clip.none]), so it may
/// overhang. This is intended for badges, markers, and decorations that sit
/// on an edge.
///
/// The anchor ([toAnchor]) must take a definite size from its own
/// constraints, as the surrounding [Stack] sizes to it.
class Anchored extends StatelessWidget {
  /// Creates a widget that positions a [child] relative to a [toAnchor]
  /// widget.
  const Anchored({
    required this.child,
    required this.atPlacement,
    required this.toAnchor,
    this.offset = Offset.zero,
    super.key,
  });

  /// The element being positioned.
  final Widget child;

  /// Where the [child] sits relative to the [toAnchor].
  final Placement atPlacement;

  /// The anchor that the [child] is positioned relative to.
  final Widget toAnchor;

  /// An additive nudge applied after alignment.
  ///
  /// Defaults to [Offset.zero].
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        toAnchor,
        Positioned.fill(
          child: Align(
            alignment: atPlacement.toAlignment,
            child: Transform.translate(offset: offset, child: child),
          ),
        ),
      ],
    );
  }
}
