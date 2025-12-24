// lib/src/editor_text_field.dart
import 'package:edittext_popover/src/editor_result.dart';
import 'package:edittext_popover/src/show_editor.dart';
import 'package:flutter/material.dart';

/// A convenience widget that wraps a TextField and automatically shows
/// the editor popover when tapped.
///
/// The [controller] text is passed to the editor as initial content.
/// When the editor is saved, the controller text is updated.
/// When dismissed, the original text is preserved.

class EditorTextField extends StatefulWidget {
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

  final TextEditingController controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextStyle? editorTextStyle;
  final Color? editorBarrierColor;
  final Widget? editorSaveWidget;
  final Widget? editorCancelWidget;
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
          // ignore: avoid_redundant_argument_values
          maxLines: 1,
        ),
      ),
    );
  }
}
