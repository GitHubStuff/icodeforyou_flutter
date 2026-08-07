import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;
import 'package:template_app/framework/application_startup.dart'
    show ApplicationStartup;
import 'package:theme_framework/theme_framework.dart'
    show SharedPreferencesThemeStorage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide the bar with time/battery so the splash screen is on a black page
  await StatusBarChameleon.setStatusBarHidden(hidden: true);

  // Preferenes are created here because it is an async task.
  final preferences = await SharedPreferences.getInstance();

  ApplicationStartup(
    themeStorage: SharedPreferencesThemeStorage(preferences),
    showDebugBanner: false,
  ).runner();
}
