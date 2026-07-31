// packages/theme_framework/lib/src/theme_mode_card.dart
import 'package:flutter/material.dart';

const EdgeInsets _kHeaderPadding = EdgeInsets.fromLTRB(16, 0, 16, 8);

/// A settings-pane card that selects between the three [ThemeMode] options.
class ThemeModeCard extends StatelessWidget {
  /// Creates a [ThemeModeCard].
  const ThemeModeCard({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The currently selected mode, e.g. the value read at app hydration.
  final ThemeMode value;

  /// Called when the user selects a different mode.
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: _kHeaderPadding,
          child: Text(
            'Appearance',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          color: theme.colorScheme.surfaceContainerHigh,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _ThemeModeTile(
                icon: Icons.light_mode,
                label: 'Light',
                selected: value == ThemeMode.light,
                onTap: () => onChanged(ThemeMode.light),
              ),
              const Divider(height: 1),
              _ThemeModeTile(
                icon: Icons.dark_mode,
                label: 'Dark',
                selected: value == ThemeMode.dark,
                onTap: () => onChanged(ThemeMode.dark),
              ),
              const Divider(height: 1),
              _ThemeModeTile(
                icon: Icons.brightness_auto,
                label: 'System',
                selected: value == ThemeMode.system,
                onTap: () => onChanged(ThemeMode.system),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: selected ? const Icon(Icons.check) : null,
      selected: selected,
      onTap: onTap,
    );
  }
}
