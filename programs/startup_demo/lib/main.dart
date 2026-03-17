// lib/main.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:application_setup/application_setup.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:startup_demo/src/_startup_tasks.dart';
import 'package:startup_demo/src/navigation/app_router.dart';
import 'package:theme_manager/theme_manager.dart';

void main() => ApplicationRunner(
  splashBuilder: (onSplashDone) => GrowAndFadeWidgetView(
    duration: const Duration(milliseconds: 1200),
    onComplete: onSplashDone,
    child: const FlutterLogo(size: 120),
  ),
  app: Router.withConfig(config: appRouter),
  tasks: StartupTasks.all,
  onReady: (themeCubit) =>
      GetIt.instance.registerSingleton<ThemeCubitBase>(themeCubit),
).run();
