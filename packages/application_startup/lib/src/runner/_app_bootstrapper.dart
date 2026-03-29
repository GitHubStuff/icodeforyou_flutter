// application_startup/lib/src/runner/_app_bootstrapper.dart
import 'package:application_startup/application_startup.dart'
    show ApplicationStartupRunner;
import 'package:flutter/material.dart';

/// Wraps Flutter's bootstrapping and app-launch calls behind an
/// injectable seam, enabling the [ApplicationStartupRunner] to be
/// tested without invoking the real binding or [runApp].
class AppBootstrapper {
  /// Creates an [AppBootstrapper].
  const AppBootstrapper();

  /// Ensures the Flutter binding is initialised before any platform
  /// services are accessed.
  void ensureInitialized() => WidgetsFlutterBinding.ensureInitialized();

  /// Mounts [app] as the root widget of the Flutter application.
  void run(Widget app) => runApp(app); // coverage:ignore-line
}
