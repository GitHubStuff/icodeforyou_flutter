// packages/custom_widgets/lib/src/uniform_cluster/save_cancel_bar.dart
// ignore_for_file: public_member_api_docs

import 'package:custom_widgets/src/uniform_cluster/uniform_cluster.dart'
    show UniformCluster;
import 'package:flutter/material.dart';

/// A Save / Cancel action pair with equal-width buttons.
///
/// - **Horizontal**: Cancel (outlined) leading, Save (filled) trailing,
///   each taking an equal share of the width. Logical order, so it mirrors
///   correctly in RTL via [Directionality].
/// - **Vertical**: Save (filled) on top, Cancel (outlined) below, each
///   stretched to the width of the wider label.
///
/// Save is the emphasized (filled) action; Cancel steps down (outlined).
/// [UniformCluster] equalizes the two buttons, so their differing label
/// lengths produce no width mismatch.
class ButtonPair extends StatelessWidget {
  const ButtonPair({
    required this.onPrimary,
    required this.onSecondary,
    this.primaryText = 'Save',
    this.secondaryText = 'Cancel',
    this.axis = Axis.horizontal,
    super.key,
  });

  final String primaryText;
  final String secondaryText;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final secondaryButton = OutlinedButton(
      onPressed: onSecondary,
      child: Text(secondaryText),
    );
    final primaryButton = FilledButton(
      onPressed: onPrimary,
      child: Text(primaryText),
    );

    final children = switch (axis) {
      Axis.horizontal => [secondaryButton, primaryButton],
      Axis.vertical => [primaryButton, secondaryButton],
    };

    // spacing defaults to DipScale.sm inside UniformCluster.
    return UniformCluster(axis: axis, children: children);
  }
}
