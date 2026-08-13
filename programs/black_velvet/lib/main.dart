// programs/since_when_dev/lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;
import 'package:theme_framework/theme_framework.dart'
    show SharedPreferencesThemeStorage;

import 'application_startup.dart' show ApplicationStartup;

// NOTE: Android has a choke-hold on the splash screen on cold-start
// So there is a small 'flash' of the screen status bar.
// CONCLUSION: Avoid Android

// COOKBOOK: Brief check list of making custom actions/buttons
// [] Create background tasks that run 'under' the splash screen (this file)
// [] EDIT: programs/{new app}/lib/app_rail_navigation/rail_destination_enum.dart
// [] EDIT: programs/{new app}/lib/screens/rail_screen.dart and screen(s)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide the bar with time/battery so the splash screen is on a black page
  await StatusBarChameleon.setStatusBarHidden(hidden: true);

  // Preferenes are created here because it is an async task.
  final preferences = await SharedPreferences.getInstance();

  ApplicationStartup(
    themeStorage: SharedPreferencesThemeStorage(preferences),
    tasks: const [
      // TODO: Add any background tasks
      //() => SinceWhenStartup.setup(SinceWhenStartup.inmemoryConfiguration),
    ],
  ).runner();
}
