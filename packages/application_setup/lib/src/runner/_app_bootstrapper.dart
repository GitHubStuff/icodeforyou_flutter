// lib/src/runner/_app_bootstrapper.dart

import 'package:flutter/material.dart';

class AppBootstrapper {
  const AppBootstrapper();

  void ensureInitialized() => WidgetsFlutterBinding.ensureInitialized();

  void run(Widget app) => runApp(app); // coverage:ignore-line
}
