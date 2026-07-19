// theme_manager/lib/src/widgets/preference/theme_radio_row.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:theme_manager/src/widgets/preference/theme_option.dart'
    show ThemeOption;
import 'package:theme_manager/src/widgets/preference/theme_radio_row.dart'
    show ThemeRadioRow;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

final _kIconNames = <IconData, String>{
  Icons.brightness_auto: 'brightness_auto',
  Icons.dark_mode: 'dark_mode',
  Icons.nights_stay: 'nights_stay',
  Icons.light_mode: 'light_mode',
  Icons.wb_sunny: 'wb_sunny',
};

const _kIcons = <IconData>[
  Icons.brightness_auto,
  Icons.dark_mode,
  Icons.nights_stay,
  Icons.light_mode,
  Icons.wb_sunny,
];

String _iconLabel(IconData icon) => _kIconNames[icon] ?? 'icon';

/// Showcases a single selectable row.
///
/// [ThemeRadioRow] draws its [Radio] state from an ancestor [RadioGroup],
/// so the host supplies one and toggles the group value on tap to make the
/// selected state observable.
@widgetbook.UseCase(name: 'Default', type: ThemeRadioRow)
Widget buildThemeRadioRowUseCase(BuildContext context) {
  final option = ThemeOption(
    mode: context.knobs.object.dropdown<ThemeMode>(
      label: 'Mode',
      options: ThemeMode.values,
      initialOption: ThemeMode.dark,
      labelBuilder: (mode) => mode.name,
    ),
    icon: context.knobs.object.dropdown<IconData>(
      label: 'Icon',
      options: _kIcons,
      initialOption: Icons.dark_mode,
      labelBuilder: _iconLabel,
    ),
    label: context.knobs.string(
      label: 'Label',
      initialValue: 'Dark',
    ),
  );

  return _ThemeRadioRowDemo(option: option);
}

class _ThemeRadioRowDemo extends StatefulWidget {
  const _ThemeRadioRowDemo({required this.option});

  final ThemeOption option;

  @override
  State<_ThemeRadioRowDemo> createState() => _ThemeRadioRowDemoState();
}

class _ThemeRadioRowDemoState extends State<_ThemeRadioRowDemo> {
  ThemeMode? _group;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: RadioGroup<ThemeMode>(
              groupValue: _group,
              onChanged: (mode) => setState(() => _group = mode),
              child: ThemeRadioRow(
                option: widget.option,
                onChanged: (mode) => setState(() => _group = mode),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
