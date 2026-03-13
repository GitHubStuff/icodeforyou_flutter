// lib/main.dart

import 'package:application_setup/application_setup.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:startup_demo/src/landing_page.dart';
import 'package:theme_manager/theme_manager.dart';

void main() => ApplicationRunner(
      splashChild: const FlutterLogo(size: 120),
      landingChild: const LandingPage(),
      onReady: (themeCubit) =>
          GetIt.instance.registerSingleton<ThemeCubitBase>(themeCubit),
    ).run();
