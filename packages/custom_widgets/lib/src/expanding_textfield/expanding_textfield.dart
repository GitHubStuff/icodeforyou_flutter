// packages/custom_widgets/lib/src/expanding_textfield/expanding_textfield.dart

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

/// A multiline text field configured for code or plain-text editing that
/// expands dynamically between [minLines] and [maxLines].
///
/// Disables autocorrect, text capitalization, smart punctuation, and
/// suggestions by default, making it suitable for structured data entry.
class ExpandingTextField extends StatelessWidget {
  /// Creates an [ExpandingTextField].
  ///
  /// The [minLines] must be greater than or equal to 1, and [maxLines]
  /// must be greater than or equal to [minLines].
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

  /// Defines the keyboard focus for this widget.
  final FocusNode? focusNode;

  /// The type of keyboard to use for editing the text.
  final TextInputType keyboardType;

  /// Controls the text being edited.
  final TextEditingController controller;

  /// The minimum number of lines to occupy when content is short.
  final int minLines;

  /// The maximum number of lines to show before the field scrolls internally.
  final int? maxLines;

  /// Called when the user initiates a change to the text field content.
  final ValueChanged<String> onChanged;

  /// The color to use for the field's outline border.
  ///
  /// Defaults to [ColorScheme.primary] if null.
  final Color? borderColor;

  /// The text style applied to the editable text.
  final TextStyle _textStyle;

  /// Optional text displayed when the text field is empty.
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
