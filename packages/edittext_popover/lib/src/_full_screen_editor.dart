// lib/src/_full_screen_editor.dart
import 'package:edittext_popover/src/_constants.dart';
import 'package:edittext_popover/src/_editor_card.dart';
import 'package:flutter/material.dart';

/// Full-screen editor layout for phones and narrow viewports.
/// Positions the editor card below safe area and above virtual keyboard.
/// Text field height is calculated as 70% of available vertical space.

class FullScreenEditor extends StatelessWidget {
  const FullScreenEditor({
    required this.textController,
    required this.focusNode,
    required this.textStyle,
    required this.saveWidget,
    required this.cancelWidget,
    required this.onSave,
    required this.onCancel,
    required this.safeArea,
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
  final EdgeInsets safeArea;
  final EdgeInsets viewInsets;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final availableHeight =
        screenHeight - safeArea.top - safeArea.bottom - viewInsets.bottom;

    final textFieldHeight =
        (availableHeight - kStatsHeight - kButtonHeight - kButtonPadding * 2) *
        kFullScreenTextFieldRatio;

    return Positioned(
      top: safeArea.top,
      left: 0,
      right: 0,
      bottom: viewInsets.bottom,
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
}
