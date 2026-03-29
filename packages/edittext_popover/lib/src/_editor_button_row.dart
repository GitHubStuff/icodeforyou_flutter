// edittext_popover/lib/src/_editor_button_row.dart
import 'package:edittext_popover/src/_constants.dart';
import 'package:flutter/material.dart';

/// The Save/Cancel button row for the editor overlay.
///
/// Colors are derived from the ambient [ColorScheme] for automatic 
/// theme support.
class EditorButtonRow extends StatelessWidget {
  /// Creates an [EditorButtonRow] with the given save and cancel widgets 
  /// and callbacks.
  const EditorButtonRow({
    required this.saveWidget,
    required this.cancelWidget,
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  /// The widget displayed inside the Save button.
  final Widget saveWidget;

  /// The widget displayed inside the Cancel button.
  final Widget cancelWidget;

  /// Called when the Save button is pressed.
  final VoidCallback onSave;

  /// Called when the Cancel button is pressed.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: kButtonHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _EditorActionButton(
            onPressed: onSave,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            child: saveWidget,
          ),
          const SizedBox(width: kButtonSpacing),
          _EditorActionButton(
            onPressed: onCancel,
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            child: cancelWidget,
          ),
        ],
      ),
    );
  }
}

class _EditorActionButton extends StatelessWidget {
  const _EditorActionButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.child,
  });

  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(
          horizontal: kButtonHorizontalPadding,
          vertical: kButtonVerticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kButtonRadius),
        ),
      ),
      child: child,
    );
  }
}
