// lib/src/startup_config.dart

import 'package:flutter/widgets.dart';

import 'startup_splash_screen.dart';

class StartupConfig {
  const StartupConfig({
    required this.splashScreen,
    required this.landingPage,
    required this.tasks,
  });

  final StartupSplashScreen splashScreen;
  final Widget landingPage;
  final List<Future<void> Function()> tasks;
}
