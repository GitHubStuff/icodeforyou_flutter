// programs/since_when_dev/lib/main.dart

import 'dart:async';

import 'package:flutter/widgets.dart'
    show WidgetsFlutterBinding, debugPrint, runApp;
import 'package:since_when_dev/main_app/configure_dependencies.dart'
    show configureDependencies, getIt;
import 'package:since_when_dev/main_app/material_app_router.dart'
    show MaterialAppRouter;
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  unawaited(hideStatusBarAtLaunch());
  runApp(const MaterialAppRouter());
}

/// Startup task: make the Dart-tracked status bar state agree with the
/// native launch setup, which already hides the bar before the first frame.
Future<void> hideStatusBarAtLaunch() async {
  debugPrint('Hide abstract');
  await getIt<StatusBarVisibilityAbstract>().setStatusBarVisibility(
    isHidden: true,
  );
}
