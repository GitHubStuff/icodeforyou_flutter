// lib/src/_editor_button_row.dart
import 'package:edittext_popover/src/_constants.dart';
import 'package:flutter/material.dart';

/// Provides the button row widget for the editor overlay.
/// Contains Save and Cancel buttons using Material Design rounded
/// FilledButtons.
/// Colors are derived from the app's ColorScheme for automatic theme support.

class EditorButtonRow extends StatelessWidget {
  const EditorButtonRow({
    required this.saveWidget,
    required this.cancelWidget,
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  final Widget saveWidget;
  final Widget cancelWidget;
  final VoidCallback onSave;
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
