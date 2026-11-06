// packages/sequenced_animations/lib/src/widgets/sequenced_grow.dart

import 'package:flutter/widgets.dart';
import 'package:sequenced_animations/src/core/range_sequence_widget.dart'
    show RangeSequenceState, RangeSequenceWidget;

/// Scales [child] through `ranges`, in order.
///
/// Range values are uniform scale factors: `1.0` = natural size,
/// `0.5` = half, `2.0` = double. Scaling is about [alignment].
class SequencedGrow extends RangeSequenceWidget {
  const SequencedGrow({
    required super.child,
    required super.ranges,
    super.onFinally,
    super.key,
    super.controller,
    this.alignment = Alignment.center,
  });

  /// The point about which [child] is scaled.
  final Alignment alignment;

  @override
  State<SequencedGrow> createState() => _SequencedGrowState();
}

class _SequencedGrowState extends RangeSequenceState<SequencedGrow> {
  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: animation,
    alignment: widget.alignment,
    child: widget.child,
  );
}
