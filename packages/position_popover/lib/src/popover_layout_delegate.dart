// packages/position_popover/lib/src/popover_layout_delegate.dart

import 'package:flutter/material.dart';

/// Positions a popover against an anchor rectangle.
///
/// The delegate receives the full area of its [CustomSingleChildLayout]
/// (normally the navigator's overlay) and places the child so that the
/// child's mirrored alignment point sits on the anchor's alignment point:
///
/// ```text
/// origin = alignment.withinRect(anchor)
///        - (-alignment).alongSize(childSize)
/// ```
///
/// Some consequences of that rule:
///
/// * [Alignment.center] centres the child over [anchor].
/// * [Alignment.topCenter] places the child above [anchor]; the child's
///   bottom-centre touches the anchor's top-centre.
/// * [Alignment.bottomRight] hangs the child below and to the right; the
///   child's top-left corner touches the anchor's bottom-right corner.
/// * A fractional alignment such as `Alignment(0.6, 0.8)` partially
///   overlaps the anchor, biased toward its lower-right.
///
/// ## Overflow
///
/// If the ideal rectangle would leave the available area on either axis,
/// the child is slid back inside along that axis only; the other axis is
/// untouched. The requested alignment is therefore not preserved in that
/// case, and nothing reports the adjustment to the child. A child larger
/// than the area on an axis is pinned to `0` on that axis and clipped at
/// the far edge.
///
/// The child keeps its natural size. Constraints are only loosened, never
/// tightened, so a child with an unbounded preferred size is not
/// protected; cap it in the child itself.
///
/// ## Coordinate space
///
/// [anchor] must be expressed in the same coordinate space the layout is
/// performed in. [PositionPopover] measures its trigger relative to the
/// navigator's overlay, which is also where [PositionPopoverRoute]'s page
/// is laid out, so the two agree.
///
/// See also:
///
/// * [PositionPopoverRoute], which builds a [CustomSingleChildLayout] with
///   this delegate.
/// * [SingleChildLayoutDelegate], the contract this class implements.
class PopoverLayoutDelegate extends SingleChildLayoutDelegate {
  /// Creates a delegate that places the child at [alignment] relative to
  /// [anchor].
  ///
  /// Both arguments are compared by value in [shouldRelayout], so two
  /// delegates built from equal inputs are interchangeable.
  const PopoverLayoutDelegate({
    required this.anchor,
    required this.alignment,
  });

  /// The rectangle the child is positioned against, in the layout's own
  /// coordinate space.
  final Rect anchor;

  /// Which point of [anchor] the child's mirrored point is placed on.
  ///
  /// See the class documentation for worked examples.
  final Alignment alignment;

  /// Loosens the incoming constraints so the child sizes itself.
  ///
  /// The child may still be as large as the area allows; only the minimum
  /// is dropped to zero.
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.loosen();
  }

  /// Computes the ideal origin from [alignment] and [anchor], then clamps
  /// it so a child of [childSize] stays inside [size].
  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final target = alignment.withinRect(anchor);
    final origin = target - (-alignment).alongSize(childSize);
    return _clampToArea(origin, size, childSize);
  }

  /// Slides [origin] along each axis independently so that a child of
  /// [childSize] stays inside [area].
  ///
  /// When the child is larger than [area] on an axis, the origin is pinned
  /// to `0` on that axis and the overflow is clipped at the far edge.
  Offset _clampToArea(Offset origin, Size area, Size childSize) {
    final maxX = _nonNegative(area.width - childSize.width);
    final maxY = _nonNegative(area.height - childSize.height);
    return Offset(
      origin.dx.clamp(0.0, maxX),
      origin.dy.clamp(0.0, maxY),
    );
  }

  /// Returns [value], or `0` if it is negative.
  ///
  /// Guards [num.clamp] against an upper bound below its lower bound, which
  /// throws an [ArgumentError].
  double _nonNegative(double value) => value < 0 ? 0 : value;

  /// Relayout is needed only when [anchor] or [alignment] changed.
  @override
  bool shouldRelayout(PopoverLayoutDelegate oldDelegate) {
    return anchor != oldDelegate.anchor || alignment != oldDelegate.alignment;
  }
}
