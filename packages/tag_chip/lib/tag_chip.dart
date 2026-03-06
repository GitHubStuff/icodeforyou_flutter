// ignore_for_file: document_ignores, public_member_api_docs

import 'package:flutter/material.dart';

enum TagChipState { disabled, enabled, none }

typedef CallbackState = void Function(TagChipState state)?;

class TagChip extends StatelessWidget {
  const TagChip({
    required this.backgroundColor,
    required this.text,
    super.key,
    this.state = TagChipState.none,
    this.onPressed,
    this.minimumWidth = 32,
    this.fontSize = 16,
  });

  final Color backgroundColor;
  final String text;
  final TagChipState state;
  final CallbackState onPressed;
  final double minimumWidth;
  final double fontSize;

  Color get _borderColor {
    final lum = backgroundColor.computeLuminance();
    return lum > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minimumWidth),
      child: ActionChip(
        label: Text(
          text,
          style: TextStyle(fontSize: fontSize, height: 1, color: _borderColor),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 3),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        backgroundColor: backgroundColor,
        shape: StadiumBorder(
          side: state == TagChipState.enabled
              ? BorderSide(color: _borderColor, width: 2)
              : BorderSide.none,
        ),
        onPressed: () => onPressed?.call(state),
      ),
    );
  }
}
