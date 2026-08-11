// packages/stacking_widgets/lib/src/piled_widget.dart
import 'package:flutter/material.dart';

/// {@template piled_widget.dart}
/// A widget that positions its [child] within an unclipped [Stack] and
/// applies a 2D translation specified by [offset].
///
/// Useful for creating stacked, overlapping, or custom-layered UI elements
/// where children need to extend outside their normal bounding boxes without
/// being clipped.
/// {@endtemplate}
class PiledWidget extends StatelessWidget {
  /// {@macro piled_widget.dart}
  const PiledWidget({
    required this.child,
    this.offset = Offset.zero,
    super.key,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// The 2D displacement applied to the [child] relative to its original position.
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Transform.translate(
          offset: offset,
          child: child,
        ),
      ],
    );
  }
}
