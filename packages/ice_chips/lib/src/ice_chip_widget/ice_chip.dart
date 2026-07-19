// packages/ice_chip/lib/src/ice_chip.dart
// ignore_for_file: public_member_api_docs

import 'package:extensions/color/color_ext.dart' show ColorExt;
import 'package:flutter/material.dart';

class IceChip extends StatelessWidget {
  const IceChip(
    this.message, {
    required this.backgroundColorInt,
    required this.showBorder,
    required this.onPress,
    this.style,
    super.key,
  });

  final String message;
  final int backgroundColorInt;
  final bool showBorder;
  final VoidCallback onPress;
  final TextStyle? style;

  Color get _backgroundColor => Color(backgroundColorInt);

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: _textColor,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ).merge(style);

    return FilterChip(
      label: Text(message),
      onSelected: (_) => onPress(),
      labelStyle: labelStyle,
      backgroundColor: _backgroundColor,
      selectedColor: _backgroundColor,
      selected: false,
      showCheckmark: false,
      shape: const StadiumBorder(),
      side: BorderSide(
        color: showBorder ? _borderColor(context) : Colors.transparent,
        width: 2,
      ),
    );
  }

  Color get _textColor => _backgroundColor.contrastingTextColor();

  Color _borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.black;
  }
}
