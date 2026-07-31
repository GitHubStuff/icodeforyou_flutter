// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;
import 'package:template_app/gen/assets.gen.dart';
import 'package:template_app/screens/error_screen.dart' show ErrorScreen;
import 'package:template_app/screens/home_screen.dart' show HomeScreen;
import 'package:theme_framework/theme_framework.dart' show ThemeStore;
import 'package:widget_animation_framework/widget_animation_framework.dart'
    show PlayOnMount, AnimationCombinerOnWidget;

import 'framework/application_startup.dart' show ApplicationStartup;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide the bar with time/battery so the splash screen is on a black page
  await StatusBarChameleon.setStatusBarHidden(hidden: true);

  final preferences = await SharedPreferences.getInstance();
  final themeStore = ThemeStore(preferences);

  final splashIcon = Assets.iconer.image();

  ApplicationStartup(
    themeStore: themeStore,
    splash: PlayOnMount(
      duration: const Duration(milliseconds: 2500),
      curve: Curves.easeInOut,
      onCompleted: null,
      builder: (context, animation) => AnimationCombinerOnWidget(
        animation: animation,
        opacity: Tween<double>(begin: 0, end: 1),
        scale: Tween<double>(begin: 0, end: 1.1),
        turns: Tween<double>(begin: 1, end: 2),
        child: splashIcon,
      ),
    ),
    home: const HomeScreen(),
    error: const ErrorScreen(),
    duration: const Duration(seconds: 3),
    tasks: [], //initializeDatabase, loadConfiguration],
  ).run();
}
