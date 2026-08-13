// programs/since_when_dev/lib/main.dart
import 'package:dependency_resolver/dependency_resolver.dart'
    show InMemoryDependencyResolver;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:since_when_dev/app/since_when_startup.dart';
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

  // Service Resolver (aka GetIt or equiv)
  final resolver = InMemoryDependencyResolver();
  // The Drift database
  const configuration = SinceWhenStartup.inMemoryConfiguration;

  ApplicationStartup(
    themeStorage: SharedPreferencesThemeStorage(preferences),
    tasks: [
      // Registers the Drift database and DAOs, then triggers the lazy
      // load so the database is alive and ready. Setup and warm are one
      // task because warm resolves what setup registers; splash tasks
      // run concurrently and must stay independent of each other.
      () async {
        await SinceWhenStartup.setup(resolver, configuration);
        await SinceWhenStartup.warm(resolver);
      },
    ],
  ).runner();
}
