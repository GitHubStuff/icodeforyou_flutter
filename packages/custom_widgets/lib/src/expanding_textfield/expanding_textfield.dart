// packages/custom_widgets/lib/src/expanding_textfield.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

const int _minimalLines = 4;
const int _maxiumLines = 10;
const EdgeInsets _insets = EdgeInsets.symmetric(vertical: 8, horizontal: 8);

const TextStyle _defaultTextStyle = TextStyle(
  fontFamily: 'monospace',
  fontSize: 18,
  fontWeight: FontWeight.bold,
  height: 1.4,
);

InputDecoration _inputDecoration({
  required BuildContext context,
  required Color border,
  String? hintText,
}) => InputDecoration(
  fillColor: Theme.of(context).colorScheme.surface,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: border),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: border, width: 2),
  ),
  contentPadding: _insets,
  hintText: hintText,
);

class ExpandingTextField extends StatelessWidget {
  const ExpandingTextField({
    required this.controller,
    required this.onChanged,
    this.minLines = _minimalLines,
    this.maxLines = _maxiumLines,
    this.borderColor,
    TextStyle? textStyle,
    this.keyboardType = TextInputType.multiline,
    this.hintText,
    this.focusNode,
    super.key,
  }) : _textStyle = textStyle ?? _defaultTextStyle,
       assert(
         (maxLines ?? double.infinity) >= minLines,
         'maxLines less than minLines',
       ),
       assert(minLines >= 1, 'minLines >= 1');

  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final int minLines;
  final int? maxLines;
  final ValueChanged<String> onChanged;
  final Color? borderColor;
  final TextStyle _textStyle;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? Theme.of(context).colorScheme.primary;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: _textStyle,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      focusNode: focusNode,
      autofocus: true,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      decoration: _inputDecoration(
        context: context,
        border: border,
        hintText: hintText,
      ),
    );
  }
}
