// theme_widget/lib/src/theme_selection_body.dart
import 'package:flutter/material.dart';
import 'package:theme_widget/src/theme_option.dart' show ThemeOption;
import 'package:theme_widget/src/theme_radio_row.dart' show ThemeRadioRow;

/// The body of the theme selection screen.
///
/// Owns the [RadioGroup] for the collection of [ThemeOption]s and renders
/// one [ThemeRadioRow] per option. The [current] mode drives the group's
/// selected value, and [onChanged] is invoked whenever any row is tapped
/// or the group's selection changes via keyboard navigation.
///
/// This widget is the single source of truth for the selection: individual
/// rows do not maintain their own [RadioGroup] scope.
class ThemeSelectionBody extends StatelessWidget {
  /// Creates a [ThemeSelectionBody].
  ///
  /// * [title] — heading displayed above the list of options.
  /// * [options] — the set of [ThemeOption]s presented to the user.
  /// * [current] — the currently selected [ThemeMode].
  /// * [onChanged] — callback invoked when the user selects a different
  ///   option.
  const ThemeSelectionBody({
    required this.title,
    required this.options,
    required this.current,
    required this.onChanged,
    super.key,
  });

  /// Heading displayed above the list of options.
  final String title;

  /// The set of [ThemeOption]s presented to the user.
  final List<ThemeOption> options;

  /// The currently selected [ThemeMode].
  final ThemeMode current;

  /// Callback invoked when the user selects a different option.
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          RadioGroup<ThemeMode>(
            groupValue: current,
            onChanged: (mode) {
              if (mode != null) onChanged(mode);
            },
            child: Column(
              children: [
                for (final option in options)
                  ThemeRadioRow(
                    option: option,
                    onChanged: onChanged,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
