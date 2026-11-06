// programs/since_when_dev/lib/main.dart

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:since_when_dev/main_app/configure_dependencies.dart'
    show configureDependencies, getIt;
import 'package:since_when_dev/main_app/material_app_router.dart'
    show MaterialAppRouter;
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  // Hide the status bar
  await getIt<StatusBarVisibilityAbstract>().initialize(
    isHidden: true,
  );
  runApp(const MaterialAppRouter());
}
