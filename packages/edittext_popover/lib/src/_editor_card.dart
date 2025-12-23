// lib/src/_editor_card.dart
import 'package:edittext_popover/src/_constants.dart';
import 'package:edittext_popover/src/_editor_button_row.dart';
import 'package:edittext_popover/src/_editor_stats_row.dart';
import 'package:edittext_popover/src/_editor_text_field.dart';
import 'package:flutter/material.dart';

/// Provides the card container for the editor overlay.
/// Composes the stats row, text field, and button row into a styled Card.
/// Uses theme-derived colors and rounded corners for Material Design
/// compliance.

class EditorCard extends StatelessWidget {
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

  final TextEditingController textController;
  final FocusNode focusNode;
  final TextStyle textStyle;
  final Widget saveWidget;
  final Widget cancelWidget;
  final VoidCallback onSave;
  final VoidCallback onCancel;
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
