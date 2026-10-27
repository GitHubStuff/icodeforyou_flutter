// packages/sincewhen_screens/lib/src/widgets/since_when_mini_action_bar.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sincewhen_screens/sincewhen_screens.dart'
    show SinceWhenMiniAction;
import 'package:sincewhen_screens/src/util/sincewhen_mini_constants.dart'
    show SinceWhenMiniDimensions;

/// {@template since_when_mini_action_bar}
/// The bottom action bar of the since-when-mini screen: Cancel plus
/// the contextual primary button.
///
/// Takes primitives, not state: [primaryAction] supplies the primary
/// button's label ([SinceWhenMiniAction.label]), [isPrimaryEnabled]
/// its enablement, and the two callbacks its behavior. The *reason*
/// the primary might be disabled is the state's business, not this
/// bar's — it renders the verdict it is handed.
///
/// No bloc dependencies: pump with an action, a flag, and two stub
/// callbacks to test every combination.
/// {@endtemplate}
class SinceWhenMiniActionBar extends StatelessWidget {
  /// {@macro since_when_mini_action_bar}
  const SinceWhenMiniActionBar({
    required this.primaryAction,
    required this.isPrimaryEnabled,
    required this.onPrimaryPressed,
    required this.onCancelPressed,
    super.key,
  });

  /// Label of the Cancel button.
  static const String cancelLabel = 'Cancel';

  /// The contextual action rendered on the primary button.
  final SinceWhenMiniAction primaryAction;

  /// Whether the primary button accepts taps.
  final bool isPrimaryEnabled;

  /// Called when the enabled primary button is pressed.
  final VoidCallback onPrimaryPressed;

  /// Called when the Cancel button is pressed.
  final VoidCallback onCancelPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: onCancelPressed,
          child: const Text(cancelLabel),
        ),
        const Gap(SinceWhenMiniDimensions.actionBarButtonGap),
        FilledButton(
          onPressed: isPrimaryEnabled ? onPrimaryPressed : null,
          child: Text(primaryAction.label),
        ),
      ],
    );
  }
}
