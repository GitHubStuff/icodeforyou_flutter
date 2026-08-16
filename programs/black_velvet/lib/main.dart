// programs/black_velvet/lib/main.dart
import 'package:dependency_resolver/dependency_resolver.dart'
    show GetItDependencyResolver, InMemoryDependencyResolver;
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

  /// TODO: And any background tasks to run while the splash screen is displayed
  final List<Future<void> Function()> tasks = [];

  /// TODO: There are two available services providers (aka resolvers) that
  /// can be use to register services that become accessable using:
  ///   context.read<DependencyResolver>()
  ///
  /// Below the default is to use the InMemoryDependencyResolver, this is good
  /// for testing/development
  /// The 'get_it' package back GetItDependencyResolver() can be used for
  /// production.

  // Service Resolvers:
  //- Custom GetIt like resolver that uses Map<>, (for testing)
  final resolver = InMemoryDependencyResolver();
  //- This is true GetIt packed resolover, (for production)
  // change "_" to resolover and delete/comment the above 'resolver'
  final _ = GetItDependencyResolver();

  ApplicationStartup(
    themeStorage: SharedPreferencesThemeStorage(preferences),
    resolver: resolver,
    tasks: tasks,
  ).runner();
}
