// lib/src/selector_widget.dart
part of '../theme_package.dart';

/// A simple radio button group for selecting theme mode.
///
/// Displays three options: System, Dark, Light.
/// Automatically updates the app theme and persists the selection.
///
/// ## Example
/// ```dart
/// Scaffold(
///   appBar: AppBar(title: Text('Settings')),
///   body: Column(
///     children: [
///       // Other settings...
///       ThemeSelectorWidget(),
///     ],
///   ),
/// )
/// ```
class ThemeSelectorWidget extends StatelessWidget {
  const ThemeSelectorWidget({super.key}); // coverage:ignore-line

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<_ThemeCubit, _ThemeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Select Theme:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            RadioGroup<ThemeMode>(
              groupValue: state.themeMode,
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  ThemePackage.setTheme(mode);
                }
              },
              child: Column(
                children: const [
                  _ThemeRadioTile(title: 'System', value: ThemeMode.system),
                  _ThemeRadioTile(title: 'Dark', value: ThemeMode.dark),
                  _ThemeRadioTile(title: 'Light', value: ThemeMode.light),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ThemeRadioTile extends StatelessWidget {
  const _ThemeRadioTile({required this.title, required this.value});

  final String title;
  final ThemeMode value;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(title: Text(title), value: value);
  }
}
