// lib/widgets/sql_text_field.dart

import 'package:flutter/material.dart';

const TextStyle _sqlTextStyle = TextStyle(
  fontFamily: 'monospace',
  fontSize: 18,
  fontWeight: FontWeight.bold,
  height: 1.4,
);

class SqlTextField extends StatelessWidget {
  const SqlTextField({
    required this.controller,
    required this.onChanged,
    this.maxLines = 10,
    this.borderColor,
    super.key,
  });

  final TextEditingController controller;
  final int? maxLines;
  final ValueChanged<String> onChanged;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? Theme.of(context).colorScheme.primary;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: _sqlTextStyle,
      minLines: 4,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: border, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        hintText: 'SELECT * FROM ...',
      ),
    );
  }
}
