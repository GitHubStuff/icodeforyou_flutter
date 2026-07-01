// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:service_locator/service_locator.dart' show ServiceRegistry;
import 'package:theme_manager/theme_manager.dart' show MaterialPreference;
import 'package:theme_service/theme_service.dart' show ThemeService;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: MaterialPreference(
            cubit: ServiceRegistry.R.getSync<ThemeService>('Theme').themeCubit,
            //cubit: GetIt.instance<ThemeCubitBase>(),
          ),
        ),
      ),
    );
  }
}
