// lib/src/settings_page.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:theme_selection_widget/theme_selection_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ThemeSelectionWidget(
                cubit: GetIt.instance<ThemeCubitBase>(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
