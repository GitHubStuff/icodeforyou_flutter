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
class SaveCancelBar extends StatelessWidget {
  const SaveCancelBar({
    required this.onSave,
    required this.onCancel,
    this.axis = Axis.horizontal,
    super.key,
  });

  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final cancel = OutlinedButton(
      onPressed: onCancel,
      child: const Text('Cancel'),
    );
    final save = FilledButton(
      onPressed: onSave,
      child: const Text('Save'),
    );

    final children = switch (axis) {
      Axis.horizontal => [cancel, save],
      Axis.vertical => [save, cancel],
    };

    // spacing defaults to DipScale.sm inside UniformCluster.
    return UniformCluster(axis: axis, children: children);
  }
}
