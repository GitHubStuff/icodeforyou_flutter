// packages/custom_widgets/lib/src/anchored.dart
// ignore_for_file: public_member_api_docs

import 'package:extensions/placement/placement.dart' show Placement;
import 'package:flutter/widgets.dart';

/// Positions a child relative to an anchor widget, using a [Placement] plus an
/// optional additive [offset].
///
/// The anchor ([toAnchor]) is laid out first and defines the box the child
/// ([child]) is positioned within; the child is then aligned to [atPlacement]
/// over that box. [offset] is applied after alignment, nudging the child away
/// from the resolved position — e.g. [Placement.center] with
/// `offset: Offset(0, -8)` sits centered, then 8 logical pixels up.
///
/// The child is not clipped to the anchor ([Clip.none]), so it may overhang —
/// intended for badges, markers, and decorations that sit on an edge.
///
/// The anchor ([toAnchor]) must take a definite size from its own constraints,
/// as the surrounding [Stack] sizes to it.
class Anchored extends StatelessWidget {
  const Anchored({
    required this.child,
    required this.atPlacement,
    required this.toAnchor,
    this.offset = Offset.zero,
    super.key,
  });

  /// The element being positioned.
  final Widget child;

  /// Where [child] sits relative to [toAnchor].
  final Placement atPlacement;

  /// The anchor [child] is positioned relative to.
  final Widget toAnchor;

  /// Additive nudge applied after alignment. Defaults to [Offset.zero].
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
