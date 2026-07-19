// theme_widget/lib/src/theme_radio_row.dart
// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;

import 'theme_option.dart' show ThemeOption;

/// A selectable row widget that presents a single [ThemeOption] as a
/// radio-style choice within a theme picker.
///
/// Renders the option's [ThemeOption.icon] and [ThemeOption.label] alongside
/// a [Radio] control, with the entire row tappable via [InkWell] to invoke
/// [onChanged]. This row is designed to live inside a [RadioGroup] owned by
/// an ancestor widget (typically the theme selection body), which manages
/// the group's current value and selection callback centrally.
///
/// Tapping anywhere on the row — the icon, the label, or the radio button
/// itself — triggers [onChanged] with the option's mode.
///
/// Example:
/// ```dart
/// RadioGroup<ThemeMode>(
///   groupValue: currentMode,
///   onChanged: (mode) => setState(() => currentMode = mode!),
///   child: Column(
///     children: [
///       for (final option in options)
///         ThemeRadioRow(
///           option: option,
///           onChanged: (mode) => setState(() => currentMode = mode),
///         ),
///     ],
///   ),
/// );
/// ```
class ThemeRadioRow extends StatelessWidget {
  /// Creates a [ThemeRadioRow] bound to a single [ThemeOption].
  ///
  /// * [option] — the [ThemeOption] this row represents.
  /// * [onChanged] — callback invoked with [ThemeOption.mode] when the row
  ///   is tapped.
  const ThemeRadioRow({
    required this.option,
    required this.onChanged,
    super.key,
  });

  /// The theme option rendered by this row.
  final ThemeOption option;

  /// Callback invoked when the row is tapped, receiving the [ThemeMode]
  /// associated with this row's [option].
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(option.mode),
      child: Row(
        children: [
          Icon(option.icon),
          const Gap(12),
          Expanded(
            child: Text(
              option.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Radio<ThemeMode>(value: option.mode),
        ],
      ),
    );
  }
}
