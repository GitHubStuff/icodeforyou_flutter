// edittext_popover/lib/src/editor_text_field.dart
// ignore_for_file: comment_references

import 'package:edittext_popover/edittext_popover.dart'
    show EditorCompleted, EditorResult;
import 'package:edittext_popover/src/show_editor.dart';
import 'package:flutter/material.dart';

/// A read-only [TextField] that opens a popover editor on tap.
///
/// Wraps a [TextEditingController] and delegates editing to [showEditor],
/// updating the controller text on a successful [EditorCompleted] result.
class EditorTextField extends StatefulWidget {
  /// Creates an [EditorTextField].
  const EditorTextField({
    required this.controller,
    this.decoration,
    this.style,
    this.editorTextStyle,
    this.editorBarrierColor,
    this.editorSaveWidget,
    this.editorCancelWidget,
    this.onResult,
    super.key,
  });

  /// Controls the text displayed in the field.
  final TextEditingController controller;

  /// Decoration applied to the underlying [TextField].
  final InputDecoration? decoration;

  /// Text style applied to the underlying [TextField].
  final TextStyle? style;

  /// Text style used inside the popover editor.
  final TextStyle? editorTextStyle;

  /// Barrier color behind the popover editor.
  final Color? editorBarrierColor;

  /// Widget used as the save action in the popover editor.
  final Widget? editorSaveWidget;

  /// Widget used as the cancel action in the popover editor.
  final Widget? editorCancelWidget;

  /// Called with the [EditorResult] when the popover editor closes.
  final void Function(EditorResult result)? onResult;

  @override
  State<EditorTextField> createState() => _EditorTextFieldState();
}

class _EditorTextFieldState extends State<EditorTextField> {
  final GlobalKey _fieldKey = GlobalKey();

  Future<void> _showEditor() async {
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;

    Rect? targetRect;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      targetRect = Rect.fromLTWH(
        position.dx,
        position.dy,
        renderBox.size.width,
        renderBox.size.height,
      );
    }

    final result = await showEditor(
      context: context,
      initialText: widget.controller.text,
      textStyle: widget.editorTextStyle,
      barrierColor: widget.editorBarrierColor,
      saveWidget: widget.editorSaveWidget,
      cancelWidget: widget.editorCancelWidget,
      targetRect: targetRect,
    );

    if (result is EditorCompleted) {
      widget.controller.text = result.text;
    }
    widget.onResult?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showEditor,
      child: AbsorbPointer(
        child: TextField(
          key: _fieldKey,
          controller: widget.controller,
          decoration: widget.decoration,
          style: widget.style,
          readOnly: true,
          maxLines: 1,
        ),
      ),
    );
  }
}
