// programs/projector_demo/lib/main_app.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;
import 'package:theme_framework/theme_framework.dart' show ThemeApp, ThemeStore;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = ThemeStore(await SharedPreferences.getInstance());
  await StatusBarChameleon.setStatusBarHidden(hidden: true);
  runApp(ThemeApp(themeStore: store));
}
