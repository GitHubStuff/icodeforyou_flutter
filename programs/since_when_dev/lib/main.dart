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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide the bar with time/battery so the splash screen is on a black page
  await StatusBarChameleon.setStatusBarHidden(hidden: true);

  // Preferenes are created here because it is an async task.
  final preferences = await SharedPreferences.getInstance();

  ApplicationStartup(
    themeStorage: SharedPreferencesThemeStorage(preferences),
  ).runner();
}
