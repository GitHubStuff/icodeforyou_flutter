import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;
import 'package:template_app/framework/application_startup.dart'
    show ApplicationStartup;
import 'package:template_app/gen/assets.gen.dart';
import 'package:template_app/screens/error_screen.dart' show ErrorScreen;
import 'package:template_app/screens/rail/rail_destination_enum.dart'
    show RailDestinationEnum;
import 'package:template_app/screens/rail/rails.dart' show Rails;
import 'package:theme_framework/theme_framework.dart'
    show SharedPreferencesThemeStorage;
import 'package:widget_animation_framework/widget_animation_framework.dart'
    show AnimationCombinerOnWidget, PlayOnMount;

const _splashDuration = Duration(milliseconds: 2500);
const _startupDuration = Duration(milliseconds: 3200);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide the bar with time/battery so the splash screen is on a black page
  await StatusBarChameleon.setStatusBarHidden(hidden: true);

  final preferences = await SharedPreferences.getInstance();
  final Widget rails = Rails(
    selection: .main,
    placement: .bottom,
    transition: .fadeThrough,
    haptics: .light,
    contents: RailDestinationEnum.railContents(),
  );

  ApplicationStartup(
    themeStorage: SharedPreferencesThemeStorage(preferences),
    splash: PlayOnMount(
      duration: _splashDuration,
      curve: Curves.easeInOut,
      builder: (context, animation) => AnimationCombinerOnWidget(
        animation: animation,
        opacity: Tween<double>(begin: 0, end: 1),
        scale: Tween<double>(begin: 0, end: 1.1),
        turns: Tween<double>(begin: 1, end: 2),
        child: Center(
          child: SizedBox.square(
            dimension: 240,
            child: ClipOval(child: Assets.iconer.image(fit: BoxFit.cover)),
          ),
        ),
      ),
    ),
    home: rails,
    error: const ErrorScreen(errorBody: Text('My own message')),
    duration: _startupDuration,
    // Test for spinner is a delay longer than splash-life
    tasks: [],
  ).run();
}
