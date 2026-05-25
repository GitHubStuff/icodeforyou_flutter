// edittext_popover/lib/src/positioned_editor.dart
import 'package:edittext_popover/src/constants.dart';
import 'package:edittext_popover/src/widgets/editor_card.dart';
import 'package:flutter/material.dart';

/// Positioned editor layout for tablets, Mac, and Web.
///
/// Calculates position relative to [targetRect] with screen boundary clamping.
/// Falls back to upper-left positioning if the editor would overflow
/// screen edges.
class PositionedEditor extends StatelessWidget {
  /// Creates a [PositionedEditor] anchored to [targetRect].
  const PositionedEditor({
    required this.textController,
    required this.focusNode,
    required this.textStyle,
    required this.saveWidget,
    required this.cancelWidget,
    required this.onSave,
    required this.onCancel,
    required this.targetRect,
    required this.viewInsets,
    super.key,
  });

  /// Controls the editable text content.
  final TextEditingController textController;

  /// Manages focus for the text field.
  final FocusNode focusNode;

  /// Style applied to the editor's text field.
  final TextStyle textStyle;

  /// Widget rendered as the save action button.
  final Widget saveWidget;

  /// Widget rendered as the cancel action button.
  final Widget cancelWidget;

  /// Called when the user confirms the edit.
  final VoidCallback onSave;

  /// Called when the user dismisses the editor without saving.
  final VoidCallback onCancel;

  /// The screen rect of the element that triggered the editor.
  /// Defaults to [Rect.zero] when null.
  final Rect? targetRect;

  /// Current view insets, used to avoid the on-screen keyboard.
  final EdgeInsets viewInsets;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final rect = targetRect ?? Rect.zero;
    final position = _calculatePosition(screenSize, rect);
    const textFieldHeight =
        kEditorHeight -
        kStatsHeight -
        kButtonHeight -
        kButtonPadding * 2 -
        kCardPadding * 2;

    return Positioned(
      left: position.dx,
      top: position.dy,
      width: kEditorWidth,
      child: EditorCard(
        textController: textController,
        focusNode: focusNode,
        textStyle: textStyle,
        saveWidget: saveWidget,
        cancelWidget: cancelWidget,
        onSave: onSave,
        onCancel: onCancel,
        textFieldHeight: textFieldHeight,
      ),
    );
  }

  Offset _calculatePosition(Size screenSize, Rect rect) {
    var left = rect.left;
    var top = rect.bottom + kEditorGap;

    if (left + kEditorWidth > screenSize.width) {
      left = screenSize.width - kEditorWidth - kEditorMargin;
    }
    if (left < kEditorMargin) {
      left = kEditorMargin;
    }
    if (top + kEditorHeight >
        screenSize.height - viewInsets.bottom - kEditorMargin) {
      top = rect.top - kEditorHeight - kEditorGap;
    }
    if (top < kEditorMargin) {
      top = kEditorMargin;
    }

    return Offset(left, top);
  }
}
