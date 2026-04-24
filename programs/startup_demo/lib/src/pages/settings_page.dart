// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:theme_manager/theme_manager.dart' show ThemeCubitBase;
import 'package:theme_widget/theme_widget.dart' show ThemeWidget;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ThemeWidget(
            cubit: GetIt.instance<ThemeCubitBase>(),
          ),
        ),
      ),
    );
  }
}
