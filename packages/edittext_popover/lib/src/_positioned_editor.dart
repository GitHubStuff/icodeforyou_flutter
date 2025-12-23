// lib/src/_positioned_editor.dart
import 'package:edittext_popover/src/_constants.dart';
import 'package:edittext_popover/src/_editor_card.dart';
import 'package:flutter/material.dart';

/// Positioned editor layout for tablets, Mac, and Web.
/// Calculates position relative to targetRect with screen boundary clamping.
/// Falls back to upper-left positioning if editor would overflow screen edges.

class PositionedEditor extends StatelessWidget {
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

  final TextEditingController textController;
  final FocusNode focusNode;
  final TextStyle textStyle;
  final Widget saveWidget;
  final Widget cancelWidget;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final Rect? targetRect;
  final EdgeInsets viewInsets;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final rect = targetRect ?? Rect.zero;
    final position = _calculatePosition(screenSize, rect);

    final textFieldHeight =
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
