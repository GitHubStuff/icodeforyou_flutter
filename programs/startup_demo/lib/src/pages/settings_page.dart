// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:theme_selection_widget/theme_selection_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ThemeSelectionWidget(
            cubit: GetIt.instance<ThemeCubitBase>(),
          ),
        ),
      ),
    );
  }
}
