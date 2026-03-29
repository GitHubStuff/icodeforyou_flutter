// edittext_popover/lib/src/_editor_card.dart
import 'package:edittext_popover/src/_constants.dart';
import 'package:edittext_popover/src/_editor_button_row.dart';
import 'package:edittext_popover/src/_editor_stats_row.dart';
import 'package:edittext_popover/src/_editor_text_field.dart';
import 'package:flutter/material.dart';

/// A card widget that composes the full text editor UI:
/// stats row, text field, and save/cancel button row.
class EditorCard extends StatelessWidget {
  /// Creates an [EditorCard] with the required controller, focus, styling,
  /// action widgets, and callbacks.
  const EditorCard({
    required this.textController,
    required this.focusNode,
    required this.textStyle,
    required this.saveWidget,
    required this.cancelWidget,
    required this.onSave,
    required this.onCancel,
    required this.textFieldHeight,
    super.key,
  });

  /// Controls the editable text content.
  final TextEditingController textController;

  /// Manages keyboard focus for the text field.
  final FocusNode focusNode;

  /// The [TextStyle] applied to the editor text field.
  final TextStyle textStyle;

  /// The widget rendered as the save action button.
  final Widget saveWidget;

  /// The widget rendered as the cancel action button.
  final Widget cancelWidget;

  /// Called when the user confirms the edit.
  final VoidCallback onSave;

  /// Called when the user dismisses the editor without saving.
  final VoidCallback onCancel;

  /// The fixed height of the text field area.
  final double textFieldHeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surface,
      elevation: kCardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kCardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const EditorStatsRow(),
            const SizedBox(height: kSpacingAfterStats),
            EditorTextFieldWidget(
              controller: textController,
              focusNode: focusNode,
              textStyle: textStyle,
              height: textFieldHeight,
            ),
            const SizedBox(height: kSpacingAfterTextField),
            EditorButtonRow(
              saveWidget: saveWidget,
              cancelWidget: cancelWidget,
              onSave: onSave,
              onCancel: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}
