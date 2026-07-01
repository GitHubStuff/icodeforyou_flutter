// theme_manager/lib/src/widgets/preference/theme_selection_body.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:theme_manager/src/widgets/preference/theme_option.dart'
    show ThemeOption;
import 'package:theme_manager/src/widgets/preference/theme_selection_body.dart'
    show ThemeSelectionBody;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

const _kOptions = <ThemeOption>[
  ThemeOption(
    mode: ThemeMode.system,
    icon: Icons.brightness_auto,
    label: 'System',
  ),
  ThemeOption(
    mode: ThemeMode.dark,
    icon: Icons.dark_mode,
    label: 'Dark',
  ),
  ThemeOption(
    mode: ThemeMode.light,
    icon: Icons.light_mode,
    label: 'Light',
  ),
];

/// Showcases the presentational selection body in isolation.
///
/// The widget is stateless, so a thin stateful host owns the selected mode
/// and reflects taps back into the [ThemeSelectionBody.current] value.
@widgetbook.UseCase(name: 'Default', type: ThemeSelectionBody)
Widget buildThemeSelectionBodyUseCase(BuildContext context) {
  return _ThemeSelectionBodyDemo(
    title: context.knobs.string(
      label: 'Title',
      initialValue: 'Theme',
    ),
  );
}

class _ThemeSelectionBodyDemo extends StatefulWidget {
  const _ThemeSelectionBodyDemo({required this.title});

  final String title;

  @override
  State<_ThemeSelectionBodyDemo> createState() =>
      _ThemeSelectionBodyDemoState();
}

class _ThemeSelectionBodyDemoState extends State<_ThemeSelectionBodyDemo> {
  ThemeMode _current = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Card(
          margin: const EdgeInsets.all(16),
          child: ThemeSelectionBody(
            title: widget.title,
            options: _kOptions,
            current: _current,
            onChanged: (mode) => setState(() => _current = mode),
          ),
        ),
      ),
    );
  }
}
