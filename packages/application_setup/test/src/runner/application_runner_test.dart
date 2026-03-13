// test/src/runner/application_runner_test.dart

import 'package:application_setup/src/app/startup_task.dart';
import 'package:application_setup/src/runner/_app_bootstrapper.dart';
import 'package:application_setup/src/runner/application_runner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _MockBootstrapper extends Mock implements AppBootstrapper {}

class _FakeTask extends StartupTask {
  const _FakeTask();

  @override
  String get id => 'fake';

  @override
  Future<void> run() async {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(const SizedBox());
  });

  group('ApplicationRunner', () {
    late _MockBootstrapper bootstrapper;

    setUp(() {
      bootstrapper = _MockBootstrapper();
      when(() => bootstrapper.ensureInitialized()).thenReturn(null);
      when(() => bootstrapper.run(any())).thenReturn(null);
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    test('default values are set correctly', () {
      final runner = ApplicationRunner(
        splashChild: const SizedBox(),
        landingChild: const SizedBox(),
      );
      expect(runner.tasks, isEmpty);
      expect(runner.splashDuration, const Duration(seconds: 3));
      expect(runner.transitionDuration, const Duration(milliseconds: 600));
      expect(runner.lightTheme, isNull);
      expect(runner.darkTheme, isNull);
      expect(runner.transitionsBuilder, isNull);
    });

    test('accepts custom tasks and durations', () {
      final runner = ApplicationRunner(
        splashChild: const SizedBox(),
        landingChild: const SizedBox(),
        tasks: const [_FakeTask()],
        splashDuration: const Duration(seconds: 5),
        transitionDuration: const Duration(milliseconds: 300),
      );
      expect(runner.tasks.length, 1);
      expect(runner.splashDuration, const Duration(seconds: 5));
      expect(runner.transitionDuration, const Duration(milliseconds: 300));
    });

    test('accepts custom ThemeData', () {
      final light = ThemeData.light();
      final dark = ThemeData.dark();
      final runner = ApplicationRunner(
        splashChild: const SizedBox(),
        landingChild: const SizedBox(),
        lightTheme: light,
        darkTheme: dark,
      );
      expect(runner.lightTheme, light);
      expect(runner.darkTheme, dark);
    });

    test('accepts custom transitionsBuilder', () {
      Widget builder(
        BuildContext c,
        Animation<double> a,
        Animation<double> b,
        Widget w,
      ) => w;

      final runner = ApplicationRunner(
        splashChild: const SizedBox(),
        landingChild: const SizedBox(),
        transitionsBuilder: builder,
      );
      expect(runner.transitionsBuilder, builder);
    });

    test('run calls ensureInitialized and runApp', () async {
      final runner = ApplicationRunner(
        splashChild: const SizedBox(),
        landingChild: const SizedBox(),
        bootstrapper: bootstrapper,
      );
      await runner.run();
      verify(() => bootstrapper.ensureInitialized()).called(1);
      verify(() => bootstrapper.run(any())).called(1);
    });

    test('run uses default light and dark themes when not provided', () async {
      final runner = ApplicationRunner(
        splashChild: const SizedBox(),
        landingChild: const SizedBox(),
        bootstrapper: bootstrapper,
      );
      await runner.run();
      verify(() => bootstrapper.run(any())).called(1);
    });

    test('run uses custom themes when provided', () async {
      final runner = ApplicationRunner(
        splashChild: const SizedBox(),
        landingChild: const SizedBox(),
        lightTheme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        bootstrapper: bootstrapper,
      );
      await runner.run();
      verify(() => bootstrapper.run(any())).called(1);
    });

    test('run uses custom transitionsBuilder when provided', () async {
      Widget builder(
        BuildContext c,
        Animation<double> a,
        Animation<double> b,
        Widget w,
      ) => w;

      final runner = ApplicationRunner(
        splashChild: const SizedBox(),
        landingChild: const SizedBox(),
        transitionsBuilder: builder,
        bootstrapper: bootstrapper,
      );
      await runner.run();
      verify(() => bootstrapper.run(any())).called(1);
    });

    test('run uses _defaultCrossFade when no transitionsBuilder provided',
        () async {
      final runner = ApplicationRunner(
        splashChild: const SizedBox(),
        landingChild: const SizedBox(),
        bootstrapper: bootstrapper,
      );
      await runner.run();
      verify(() => bootstrapper.run(any())).called(1);
    });
    testWidgets('defaultCrossFade returns FadeTransition', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final animation = AnimationController(
                vsync: tester,
                duration: Duration.zero,
              )..value = 1;
              final result = ApplicationRunner.defaultCrossFade(
                context,
                animation,
                animation,
                const SizedBox(),
              );
              expect(result, isA<FadeTransition>());
              animation.dispose();
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
