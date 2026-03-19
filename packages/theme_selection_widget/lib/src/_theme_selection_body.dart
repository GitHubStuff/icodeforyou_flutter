// lib/src/_theme_selection_body.dart

import 'package:flutter/material.dart';
import 'package:theme_selection_widget/src/_theme_option.dart';
import 'package:theme_selection_widget/src/_theme_radio_row.dart';

class ThemeSelectionBody extends StatelessWidget {
  const ThemeSelectionBody({
    required this.title,
    required this.options,
    required this.current,
    required this.onChanged,
    super.key,
  });

  final String title;
  final List<ThemeOption> options;
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          ...options.map(
            (option) => ThemeRadioRow(
              option: option,
              selected: current == option.mode,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
