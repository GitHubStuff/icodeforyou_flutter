// edittext_popover/lib/src/full_screen_editor.dart
import 'package:edittext_popover/src/constants.dart';
import 'package:edittext_popover/src/widgets/editor_card.dart';
import 'package:flutter/material.dart';

/// Full-screen editor layout for phones and narrow viewports.
///
/// Positions the [EditorCard] below the safe area top and above the virtual
/// keyboard. The text field height is calculated as [kFullScreenTextFieldRatio]
/// of the remaining vertical space after accounting for the stats bar,
/// action buttons, and padding.
class FullScreenEditor extends StatelessWidget {
  /// Creates a [FullScreenEditor] with the required controller, focus, style,
  /// action widgets, callbacks, and layout insets.
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

  /// Controls the editable text content.
  final TextEditingController textController;

  /// Manages focus for the text field.
  final FocusNode focusNode;

  /// The [TextStyle] applied to the editable text.
  final TextStyle textStyle;

  /// Widget rendered as the save action button.
  final Widget saveWidget;

  /// Widget rendered as the cancel action button.
  final Widget cancelWidget;

  /// Called when the user confirms the edit.
  final VoidCallback onSave;

  /// Called when the user dismisses without saving.
  final VoidCallback onCancel;

  /// The current device safe area insets.
  final EdgeInsets safeArea;

  /// The current keyboard view insets.
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
