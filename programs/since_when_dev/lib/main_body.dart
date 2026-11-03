// programs/since_when_dev/lib/main_body.dart

import 'package:flutter/material.dart';
import 'package:launch_splash_screen/launch_splash_screen.dart'
    show LaunchSplashScreen;
import 'package:status_bar_visibility_abstract/status_bar_visibility_abstract.dart'
    show StatusBarVisibilityAbstract;

import 'home/home_screen.dart' show HomeScreen;
import 'injection/injection.dart' show getIt;

/// Startup task: make the Dart-tracked status bar state agree with the
/// native launch setup, which already hides the bar before the first frame.
Future<void> hideStatusBarAtLaunch() async {
  await getIt<StatusBarVisibilityAbstract>().setStatusBarVisibility(
    isHidden: true,
  );
}

/// Root of the development app.
class MainBody extends StatelessWidget {
  /// Creates the app.
  const MainBody({super.key});

  /// Route of the launch splash.
  static const String splashRoute = '/';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Since When (dev)',
      theme: ThemeData.dark(),
      initialRoute: splashRoute,
      routes: {
        splashRoute: (_) => const _LaunchSplash(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },
    );
  }
}

/// The app's launch splash: black to match the native launch screen, with
/// the startup tasks wired in.
class _LaunchSplash extends StatelessWidget {
  const _LaunchSplash();

  static const Duration _timeout = Duration(seconds: 3);

  @override
  Widget build(BuildContext context) {
    return LaunchSplashScreen(
      timeoutDuration: _timeout,
      backgroundTasks: const [hideStatusBarAtLaunch],
      spinner: const CircularProgressIndicator(),
      onCompleted: _goHome,
      onFailure: _failFast,
      child: const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Text('Since When', style: TextStyle(fontSize: 32)),
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  /// POC policy: a launch failure is fatal and should be loud.
  void _failFast(BuildContext context, Object error) {
    throw StateError('Launch failed: $error');
  }
}
