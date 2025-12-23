// lib/src/_editor_text_field.dart
import 'package:edittext_popover/src/_constants.dart';
import 'package:flutter/material.dart';

/// Internal text field widget for the editor overlay.
/// Supports multiline input with expand behavior and top-aligned text.
/// Uses theme-derived colors for fill, border, and focus states.

class EditorTextFieldWidget extends StatelessWidget {
  const EditorTextFieldWidget({
    required this.controller,
    required this.focusNode,
    required this.textStyle,
    required this.height,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle textStyle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: textStyle.copyWith(color: colorScheme.onSurface),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: _buildBorder(colorScheme.outline),
          enabledBorder: _buildBorder(colorScheme.outline),
          focusedBorder: _buildBorder(
            colorScheme.primary,
            width: kTextFieldFocusedBorderWidth,
          ),
          contentPadding: const EdgeInsets.all(kTextFieldContentPadding),
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(kTextFieldRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
