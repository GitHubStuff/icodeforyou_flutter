// packages/animated_widgets/test/src/splash_widget/src/splash_screen_test.dart
import 'dart:async';

import 'package:animated_widgets/src/splash_widget/src/splash_config.dart';
import 'package:animated_widgets/src/splash_widget/src/splash_cubit.dart';
import 'package:animated_widgets/src/splash_widget/src/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const _config = SplashConfig(
  splashDuration: Duration(milliseconds: 100),
  timeoutDuration: Duration(milliseconds: 200),
  crossfadeDuration: Duration(milliseconds: 50),
  timeoutText: 'Config Time Out',
  backgroundTaskFailedText: 'Config Task Failed',
);

const _splashKey = Key('splash');
const _landingKey = Key('landing');
const _intermediateKey = Key('intermediate');
const _timeoutKey = Key('timeout');
const _failedKey = Key('failed');

Future<void> _pumpScreen(
  WidgetTester tester, {
  required List<Future<void>> tasks,
  Widget? intermediateWidget,
  Widget? timeoutWidget,
  Widget Function(BuildContext, Object, StackTrace)?
      backgroundTaskFailedWidgetBuilder,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<SplashCubit>(
        create: (_) => SplashCubit(splashConfig: _config),
        child: SplashScreen(
          splashWidget: const SizedBox(key: _splashKey),
          landingPage: const SizedBox(key: _landingKey),
          tasks: tasks,
          intermediateWidget: intermediateWidget,
          timeoutWidget: timeoutWidget,
          backgroundTaskFailedWidgetBuilder: backgroundTaskFailedWidgetBuilder,
        ),
      ),
    ),
  );
}

/// The [Stack] produced by [SplashScreen]'s centered layout builder.
Finder _switcherStack() => find.descendant(
      of: find.byType(AnimatedSwitcher),
      matching: find.byType(Stack),
    );

/// Whether the switcher still holds an outgoing child alongside the current
/// one.
bool _isTransitioning(WidgetTester tester) =>
    tester.widget<Stack>(_switcherStack()).children.length != 1;

/// Drives one [AnimatedSwitcher] transition to completion.
///
/// The first pump carries an explicit zero duration: a bare `pump()` only
/// runs a frame if one is already scheduled and flushes microtasks *after*
/// that check, so a state change that arrives via a completed future would
/// not be built. The zero-duration elapse flushes first, so the rebuild for
/// the new state happens here.
///
/// Time then advances in half-crossfade steps, at least once, until the
/// switcher has dropped its outgoing child. The step cap bounds the fake
/// time spent here to 150 ms, which keeps a transition out of the
/// indeterminate phase (armed at 100 ms, timing out at 300 ms) clear of the
/// cubit's timeout.
///
/// Used instead of [WidgetTester.pumpAndSettle] because an indeterminate
/// progress indicator never settles and the cubit's timeout would fire while
/// waiting for it.
Future<void> _pumpCrossfade(WidgetTester tester) async {
  const maxSteps = 6;
  final step = _config.crossfadeDuration ~/ 2;

  await tester.pump(Duration.zero);
  var steps = 0;
  do {
    await tester.pump(step);
    steps++;
  } while (steps < maxSteps && _isTransitioning(tester));
}

/// Unmounts the tree so the provider closes the cubit before the test's
/// pending-timer check runs.
Future<void> _tearDownScreen(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox());

void main() {
  group('SplashScreen', () {
    testWidgets('shows the splash widget, then lands once tasks finish',
        (tester) async {
      final task = Completer<void>();
      await _pumpScreen(tester, tasks: [task.future]);

      expect(find.byKey(_splashKey), findsOneWidget);
      expect(find.byKey(_landingKey), findsNothing);

      task.complete();
      await tester.pump(_config.splashDuration);
      await _pumpCrossfade(tester);

      expect(find.byKey(_landingKey), findsOneWidget);
      expect(find.byKey(_splashKey), findsNothing);
    });

    testWidgets('shows the default progress indicator while tasks are pending',
        (tester) async {
      final task = Completer<void>();
      await _pumpScreen(tester, tasks: [task.future]);

      await tester.pump(_config.splashDuration);
      await _pumpCrossfade(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(_splashKey), findsNothing);

      task.complete();
      await _pumpCrossfade(tester);

      expect(find.byKey(_landingKey), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows a custom intermediate widget while tasks are pending',
        (tester) async {
      final task = Completer<void>();
      await _pumpScreen(
        tester,
        tasks: [task.future],
        intermediateWidget: const SizedBox(key: _intermediateKey),
      );

      await tester.pump(_config.splashDuration);
      await _pumpCrossfade(tester);

      expect(find.byKey(_intermediateKey), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byKey(_splashKey), findsNothing);

      task.complete();
      await _pumpCrossfade(tester);

      expect(find.byKey(_landingKey), findsOneWidget);
      expect(find.byKey(_intermediateKey), findsNothing);
    });

    testWidgets('shows the configured timeout text after the timeout',
        (tester) async {
      final task = Completer<void>();
      await _pumpScreen(tester, tasks: [task.future]);

      await tester.pump(_config.splashDuration);
      await tester.pump(_config.timeoutDuration);
      await _pumpCrossfade(tester);

      expect(find.text(_config.timeoutText), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await _tearDownScreen(tester);
    });

    testWidgets('shows a custom timeout widget after the timeout',
        (tester) async {
      final task = Completer<void>();
      await _pumpScreen(
        tester,
        tasks: [task.future],
        timeoutWidget: const SizedBox(key: _timeoutKey),
      );

      await tester.pump(_config.splashDuration);
      await tester.pump(_config.timeoutDuration);
      await _pumpCrossfade(tester);

      expect(find.byKey(_timeoutKey), findsOneWidget);
      expect(find.text(_config.timeoutText), findsNothing);

      await _tearDownScreen(tester);
    });

    testWidgets('shows the configured failure text when a task fails',
        (tester) async {
      final task = Completer<void>();
      await _pumpScreen(tester, tasks: [task.future]);

      task.completeError(Exception('boom'));
      await _pumpCrossfade(tester);

      expect(find.text(_config.backgroundTaskFailedText), findsOneWidget);
      expect(find.byKey(_splashKey), findsNothing);
    });

    testWidgets('passes the error and stack trace to the failure builder',
        (tester) async {
      final task = Completer<void>();
      final thrown = Exception('boom');
      final trace = StackTrace.current;
      Object? receivedError;
      StackTrace? receivedTrace;

      await _pumpScreen(
        tester,
        tasks: [task.future],
        backgroundTaskFailedWidgetBuilder: (context, error, stackTrace) {
          receivedError = error;
          receivedTrace = stackTrace;
          return const SizedBox(key: _failedKey);
        },
      );

      task.completeError(thrown, trace);
      await _pumpCrossfade(tester);

      expect(find.byKey(_failedKey), findsOneWidget);
      expect(find.text(_config.backgroundTaskFailedText), findsNothing);
      expect(receivedError, same(thrown));
      expect(receivedTrace, same(trace));
    });

    testWidgets('crossfades with both children stacked and centered',
        (tester) async {
      final task = Completer<void>();
      await _pumpScreen(tester, tasks: [task.future]);

      task.complete();
      await tester.pump(_config.splashDuration);
      // Start the transition ticker, then advance partway through it.
      await tester.pump(Duration.zero);
      await tester.pump(_config.crossfadeDuration ~/ 2);

      expect(find.byKey(_splashKey), findsOneWidget);
      expect(find.byKey(_landingKey), findsOneWidget);

      final stack = tester.widget<Stack>(_switcherStack());
      expect(stack.alignment, Alignment.center);
      expect(stack.fit, StackFit.expand);
      expect(stack.children, hasLength(2));

      await _pumpCrossfade(tester);

      expect(find.byKey(_splashKey), findsNothing);
      expect(find.byKey(_landingKey), findsOneWidget);
    });

    testWidgets('renders non-landing phases full-screen and centered',
        (tester) async {
      final task = Completer<void>();
      await _pumpScreen(tester, tasks: [task.future]);

      final center = find.ancestor(
        of: find.byKey(_splashKey),
        matching: find.byType(Center),
      );
      expect(center, findsOneWidget);
      expect(
        find.ancestor(of: center, matching: find.byType(SizedBox)),
        findsWidgets,
      );
      expect(tester.getSize(find.byKey(_splashKey)), Size.zero);
      expect(
        tester.getCenter(find.byKey(_splashKey)),
        tester.getCenter(find.byType(SplashScreen)),
      );

      task.complete();
      await tester.pump(_config.splashDuration);
      await _pumpCrossfade(tester);

      expect(
        find.ancestor(
          of: find.byKey(_landingKey),
          matching: find.byType(Center),
        ),
        findsNothing,
      );
    });
  });
}