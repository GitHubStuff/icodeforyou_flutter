// packages/sequenced_animations/lib/src/widgets/sequenced_opacity.dart

import 'package:flutter/widgets.dart';
import 'package:sequenced_animations/src/core/range_sequence_widget.dart';

/// Fades [child] through `ranges`, in order.
///
/// Range values are opacity: `0.0` = transparent, `1.0` = opaque.
class SequencedOpacity extends RangeSequenceWidget {
  const SequencedOpacity({
    required super.child,
    required super.ranges,
    super.onFinally,
    super.key,
    super.controller,
  });

  @override
  State<SequencedOpacity> createState() => _SequencedOpacityState();
}

class _SequencedOpacityState extends RangeSequenceState<SequencedOpacity> {
  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: animation, child: widget.child);
}
