// lib/main.dart

import 'package:flutter/material.dart';
import 'package:settings_widget/settings_widget.dart' show SettingsContent;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;
import 'package:template_app/framework/application_startup.dart'
    show ApplicationStartup;
import 'package:template_app/gen/assets.gen.dart';
import 'package:template_app/screens/error_screen.dart' show ErrorScreen;
import 'package:template_app/screens/rail/rails.dart' show RailContent, Rails;
import 'package:theme_framework/theme_framework.dart'
    show ThemeModeEntry, ThemeStore;
import 'package:widget_animation_framework/widget_animation_framework.dart'
    show AnimationCombinerOnWidget, PlayOnMount;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide the bar with time/battery so the splash screen is on a black page
  await StatusBarChameleon.setStatusBarHidden(hidden: true);

  final preferences = await SharedPreferences.getInstance();
  final themeStore = ThemeStore(preferences);

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
        child: Center(
          child: SizedBox.square(
            dimension: 340,
            child: ClipOval(child: Assets.iconer.image(fit: BoxFit.cover)),
          ),
        ),
      ),
    ),
    //home: ErrorScreen(), //Rails(),
    home: const Rails(
      selection: .main,
      placement: .bottom,
      transition: .fadeThrough,
      haptics: .light,
      contents: [
        RailContent(
          identifier: .main,
          widget: ErrorScreen(errorBody: Text('Main')),
        ),
        RailContent(
          identifier: .settings,
          // SettingsContent brings no Scaffold, so it needs the top inset
          // itself; RailShell only guards the rail's own edge.
          widget: SafeArea(
            child: SettingsContent(
              title: Text('Settings'),
              entries: [ThemeModeEntry()],
            ),
          ),
        ),
      ],
    ),
    error: const ErrorScreen(errorBody: Text('My own message')),
    duration: const Duration(seconds: 3),
    tasks: [], //initializeDatabase, loadConfiguration],
  ).run();
}
