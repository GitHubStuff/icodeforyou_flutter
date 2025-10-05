// radiobuttonandlabel.dart
import 'package:flutter/material.dart';

class RadiobuttonAndLabel<S> extends StatelessWidget {
  const RadiobuttonAndLabel({
    required this.value,
    required this.label,
    required this.onChanged,
    super.key,
  });

  final S value;
  final Widget label;
  final ValueChanged<S?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: label,
      leading: Radio<S>(value: value),
      onTap: () => onChanged(value),
      visualDensity: VisualDensity.compact,
      dense: true,
    );
  }
}
