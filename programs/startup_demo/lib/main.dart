// lib/main.dart

import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:application_startup/application_startup.dart';
import 'package:flutter/material.dart';
import 'package:startup_demo/src/_startup_tasks.dart' show StartupTasks;
import 'package:startup_demo/src/navigation/_nav_entries.dart';

void main() => ApplicationStartupRunner(
  splashConfig: _splashConfig,
  homeScreen: _homeyScreen,
  tasks: StartupTasks.all,
  darkTheme: ThemeData.dark().copyWith(
    extensions: [
      RailMenuTheme.dark(),
      ContextualRevealTheme.dark(),
    ],
  ),
  lightTheme: ThemeData.light().copyWith(
    extensions: [
      RailMenuTheme.light(),
      ContextualRevealTheme.light(),
    ],
  ),
).run();

const _splashConfig = SplashScreenConfiguration(
  splashWidget: _splashWidget,
  splashDuration: Duration(seconds: 2),
  transition: SplashTransitions.crossFade,
  transitionDuration: Duration(milliseconds: 400),
);

const _splashWidget = GrowAndFadeWidgetView(
  duration: Duration(milliseconds: 1900),
  child: FlutterLogo(size: 300),
);

const _homeyScreen = RailNavigationWidget(
  direction: RailDirection.adaptive,
  icon: RailIcon.phone,
  transition: RailTransition.slideDirectional,
  iconSpacing: MenuIconSpacing.collapsed,
  transitionDuration: Duration(milliseconds: 750),
  entries: navEntries,
);
