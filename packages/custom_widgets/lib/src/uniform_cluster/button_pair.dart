// packages/custom_widgets/lib/src/uniform_cluster/button_pair.dart

import 'package:custom_widgets/src/uniform_cluster/uniform_cluster.dart'
    show UniformCluster;
import 'package:flutter/material.dart';

/// {@template save_cancel_bar.dart}
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
/// {@endtemplate}
class ButtonPair extends StatelessWidget {
  /// {@macro save_cancel_bar.dart}
  const ButtonPair({
    required this.onPrimary,
    required this.onSecondary,
    this.primaryText = 'Save',
    this.secondaryText = 'Cancel',
    this.axis = Axis.horizontal,
    super.key,
  });

  /// Label for the emphasized (filled) action. Defaults to `'Save'`.
  final String primaryText;

  /// Label for the de-emphasized (outlined) action. Defaults to `'Cancel'`.
  final String secondaryText;

  /// Called when the primary (filled) button is pressed.
  ///
  /// Pass `null` to disable the button.
  final VoidCallback? onPrimary;

  /// Called when the secondary (outlined) button is pressed.
  ///
  /// Pass `null` to disable the button.
  final VoidCallback? onSecondary;

  /// Layout direction of the pair.
  ///
  /// [Axis.horizontal] places Cancel leading and Save trailing;
  /// [Axis.vertical] places Save on top and Cancel below.
  /// Defaults to [Axis.horizontal].
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
