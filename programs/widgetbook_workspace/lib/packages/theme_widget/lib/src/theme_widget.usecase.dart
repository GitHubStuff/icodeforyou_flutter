// lib/packages/theme_widget/lib/src/theme_widget.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:theme_manager/theme_manager.dart';
import 'package:theme_widget/theme_widget.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ThemeWidget)
Widget themeWidgetUseCase(BuildContext context) {
  final title = context.knobs.string(
    label: 'title',
    initialValue: 'Appearance',
  );

  return _ThemeWidgetShowcase(title: title);
}

class _ThemeWidgetShowcase extends StatefulWidget {
  const _ThemeWidgetShowcase({required this.title});

  final String title;

  @override
  State<_ThemeWidgetShowcase> createState() => _ThemeWidgetShowcaseState();
}

class _ThemeWidgetShowcaseState extends State<_ThemeWidgetShowcase> {
  late final MaterialThemeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = MaterialThemeCubit(
      theme: MaterialTheme(),
      themeModeStorage: _InMemoryThemePersistence(),
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ThemeWidget(cubit: _cubit, title: widget.title),
        ),
      ),
    );
  }
}

class _InMemoryThemePersistence implements ThemePersistenceAbstract {
  ThemeMode _mode = ThemeMode.dark;

  @override
  ThemeMode load() => _mode;

  @override
  void save(ThemeMode mode) => _mode = mode;
}
