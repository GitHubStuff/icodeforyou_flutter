// lib/src/_theme_radio_row.dart

import 'package:flutter/material.dart';
import 'package:theme_selection_widget/src/_theme_option.dart';

class ThemeRadioRow extends StatelessWidget {
  const ThemeRadioRow({
    required this.option,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final ThemeOption option;
  final bool selected;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(option.mode),
      child: Row(
        children: [
          Icon(option.icon),
          const SizedBox(width: 12),
          Expanded(child: Text(option.label)),
          Radio<ThemeMode>(
            value: option.mode,
            groupValue: selected ? option.mode : null,
            onChanged: (_) => onChanged(option.mode),
          ),
        ],
      ),
    );
  }
}
