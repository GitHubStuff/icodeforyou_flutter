// lib/main.dart

import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:application_setup/application_setup.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:startup_demo/src/_startup_tasks.dart';
import 'package:startup_demo/src/navigation/_nav_entries.dart';
import 'package:theme_manager/theme_manager.dart';

void main() => ApplicationRunner(
  splashBuilder: (onSplashDone) =>
      GrowAndFadeWidgetView(
            duration: const Duration(milliseconds: 1900),
            onComplete: onSplashDone,
            child: const FlutterLogo(size: 290),
          )
          as SplashScreenAbstract,
  app: const RailNavigationWidget(
    direction: RailDirection.adaptive,
    icon: RailIcon.phone,
    transition: RailTransition.slideDirectional,
    iconSpacing: MenuIconSpacing.collapsed,
    transitionDuration: Duration(milliseconds: 750),
    entries: navEntries,
  ),
  tasks: StartupTasks.all,
  darkTheme: ThemeData.dark().copyWith(
    extensions: [RailMenuTheme.dark(), ContextualRevealTheme.dark()],
  ),
  lightTheme: ThemeData.light().copyWith(
    extensions: [RailMenuTheme.light(), ContextualRevealTheme.light()],
  ),
  onReady: (themeCubit) =>
      GetIt.instance.registerSingleton<ThemeCubitBase>(themeCubit),
).run();
