// test/src/runner/application_runner_test.dart

import 'package:application_setup/src/app/splash_screen.dart';
import 'package:application_setup/src/app/startup_task.dart';
import 'package:application_setup/src/runner/_app_bootstrapper.dart';
import 'package:application_setup/src/runner/application_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart'
    show InMemorySharedPreferencesAsync;
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _MockAppBootstrapper extends Mock implements AppBootstrapper {}

class _MockStartupTask extends Mock implements StartupTask {}

class _StubSplash extends SplashScreenAbstract {
  const _StubSplash({required super.onComplete});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const SizedBox.shrink());
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('ApplicationRunner', () {
    late _MockAppBootstrapper bootstrapper;

    setUp(() {
      bootstrapper = _MockAppBootstrapper();
      when(() => bootstrapper.ensureInitialized()).thenReturn(null);
      when(() => bootstrapper.run(any())).thenReturn(null);
    });

    test('run calls ensureInitialized and run on bootstrapper', () async {
      final runner = ApplicationRunner(
        splashBuilder: (onDone) => _StubSplash(onComplete: onDone),
        app: const SizedBox.shrink(),
        bootstrapper: bootstrapper,
      );
      await runner.run();
      verify(() => bootstrapper.ensureInitialized()).called(1);
      verify(() => bootstrapper.run(any())).called(1);
    });

    test('run calls onReady with ThemeCubit', () async {
      var onReadyCalled = false;
      final runner = ApplicationRunner(
        splashBuilder: (onDone) => _StubSplash(onComplete: onDone),
        app: const SizedBox.shrink(),
        bootstrapper: bootstrapper,
        onReady: (_) => onReadyCalled = true,
      );
      await runner.run();
      expect(onReadyCalled, isTrue);
    });

    test('accepts tasks list', () async {
      final task = _MockStartupTask();
      when(() => task.id).thenReturn('t');
      final runner = ApplicationRunner(
        splashBuilder: (onDone) => _StubSplash(onComplete: onDone),
        app: const SizedBox.shrink(),
        tasks: [task],
        bootstrapper: bootstrapper,
      );
      await runner.run();
      verify(() => bootstrapper.run(any())).called(1);
    });

    test('uses default themes when not provided', () async {
      final runner = ApplicationRunner(
        splashBuilder: (onDone) => _StubSplash(onComplete: onDone),
        app: const SizedBox.shrink(),
        bootstrapper: bootstrapper,
      );
      await runner.run();
      verify(() => bootstrapper.run(any())).called(1);
    });

    test('uses provided themes when given', () async {
      final runner = ApplicationRunner(
        splashBuilder: (onDone) => _StubSplash(onComplete: onDone),
        app: const SizedBox.shrink(),
        lightTheme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        bootstrapper: bootstrapper,
      );
      await runner.run();
      verify(() => bootstrapper.run(any())).called(1);
    });

    test('uses provided transitionsBuilder when given', () async {
      final runner = ApplicationRunner(
        splashBuilder: (onDone) => _StubSplash(onComplete: onDone),
        app: const SizedBox.shrink(),
        bootstrapper: bootstrapper,
        transitionsBuilder: (context, animation, secondary, child) => child,
      );
      await runner.run();
      verify(() => bootstrapper.run(any())).called(1);
    });
  });
}
