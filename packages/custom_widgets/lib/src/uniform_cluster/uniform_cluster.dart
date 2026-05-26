// packages/custom_widgets/lib/src/uniform_cluster/uniform_cluster.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:platform_utils/platform_utils.dart' show DipScale, Spacing;

/// Lays out [children] along [axis] so they all share a uniform main-axis
/// extent (e.g. equal-width buttons), keyed off the longest child.
///
/// Sizing strategy depends on [axis]:
///
/// - **Vertical** ([Axis.vertical]): every child stretches to the width of
///   the widest child, via [IntrinsicWidth] + [CrossAxisAlignment.stretch].
///   The cluster is only as wide as its longest child.
/// - **Horizontal** ([Axis.horizontal], the default): every child is wrapped
///   in [Expanded] so they each take an equal share of the available width,
///   ending up the same width as one another.
///
/// [spacing] uses the native [Flex] spacing (Flutter 3.27+) and applies
/// between children only. Defaults to [DipScale.sm].
///
/// Note: the horizontal strategy fills the available width equally; it does
/// not size to the longest label. Sizing a *horizontal* cluster to its
/// longest child instead requires measuring and is intentionally not done
/// here — equal share is the idiomatic button-bar behavior.
class UniformCluster extends StatelessWidget {
  const UniformCluster({
    required this.children,
    this.axis = Axis.horizontal,
    this.spacing = DipScale.sm,
    super.key,
  });

  /// The widgets to lay out with uniform main-axis sizing.
  final List<Widget> children;

  /// The layout axis. Defaults to [Axis.horizontal].
  final Axis axis;

  /// Fixed gap between children, in logical pixels. Defaults to [DipScale.sm].
  final Spacing spacing;

  @override
  Widget build(BuildContext context) {
    return switch (axis) {
      Axis.vertical => IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: spacing,
          children: children,
        ),
      ),
      Axis.horizontal => Row(
        spacing: spacing,
        children: [
          for (final child in children) Expanded(child: child),
        ],
      ),
    };
  }
}
