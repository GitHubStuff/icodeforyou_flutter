// packages/sequenced_animations/lib/src/widgets/sequenced_rotation.dart

import 'package:flutter/widgets.dart';
import 'package:sequenced_animations/src/core/range_sequence_widget.dart'
    show RangeSequenceState, RangeSequenceWidget;

/// Rotates [child] through `ranges`, in order.
///
/// Range values are turns: `0.0` = no rotation, `0.25` = 90°,
/// `0.5` = 180°, `0.75` = 270°, `1.0` = one full clockwise turn.
/// Decreasing values rotate counter-clockwise. Rotation is about
/// [alignment].
class SequencedRotation extends RangeSequenceWidget {
  const SequencedRotation({
    required super.child,
    required super.ranges,
    super.onFinally,
    super.key,
    super.controller,
    this.alignment = Alignment.center,
  });

  /// The point about which [child] is rotated.
  final Alignment alignment;

  @override
  RangeSequenceState<SequencedRotation> createState() =>
      _SequencedRotationState();
}

class _SequencedRotationState extends RangeSequenceState<SequencedRotation> {
  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: animation,
    alignment: widget.alignment,
    child: widget.child,
  );
}
