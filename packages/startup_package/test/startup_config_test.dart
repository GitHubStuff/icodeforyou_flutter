// test/startup_config_test.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startup_package/src/startup_config.dart';
import 'package:startup_package/src/startup_splash_screen.dart';

class _FakeSplashScreen extends StartupSplashScreen {
  const _FakeSplashScreen();

  @override
  State<_FakeSplashScreen> createState() => _FakeSplashScreenState();
}

class _FakeSplashScreenState extends State<_FakeSplashScreen> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  group('StartupConfig', () {
    const splash = _FakeSplashScreen();
    const landing = SizedBox.shrink();
    final tasks = <Future<void> Function()>[() async {}];

    test('holds splashScreen, landingPage, and tasks', () {
      final config = StartupConfig(
        splashScreen: splash,
        landingPage: landing,
        tasks: tasks,
      );

      expect(config.splashScreen, equals(splash));
      expect(config.landingPage, equals(landing));
      expect(config.tasks, equals(tasks));
    });

    test('accepts an empty task list', () {
      const config = StartupConfig(
        splashScreen: splash,
        landingPage: landing,
        tasks: [],
      );

      expect(config.tasks, isEmpty);
    });

    test('accepts multiple tasks', () {
      final multipleTasks = <Future<void> Function()>[
        () async {},
        () async {},
        () async {},
      ];

      final config = StartupConfig(
        splashScreen: splash,
        landingPage: landing,
        tasks: multipleTasks,
      );

      expect(config.tasks.length, equals(3));
    });

    test('tasks are callable', () async {
      var called = false;

      final config = StartupConfig(
        splashScreen: splash,
        landingPage: landing,
        tasks: [() async { called = true; }],
      );

      await config.tasks.first();
      expect(called, isTrue);
    });
  });
}
