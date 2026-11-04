// packages/launch_splash_screen/test/src/launch_splash_screen_test.dart

import 'dart:async' show Completer, TimeoutException;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launch_splash_screen/launch_splash_screen.dart'
    show LaunchCompletedCallback, LaunchSplashScreen, LaunchTask;

const splash = Duration(milliseconds: 750);
const timeout = Duration(milliseconds: 2000);
const tick = Duration(milliseconds: 1);

const childKey = Key('child');
const spinnerKey = Key('spinner');
const homeKey = Key('home');

/// A recognisable trace to fail tasks with; it must reach `onFailure` as-is.
final trace = StackTrace.fromString('#0 task (package:test/task.dart:1:1)');

/// What `onFailure` received.
typedef Failure = ({Object error, StackTrace stackTrace});

/// Records every callback the splash makes.
class CallbackLog {
  final List<BuildContext> completed = [];
  final List<Failure> failures = [];

  void onCompleted(BuildContext context) => completed.add(context);

  void onFailure(BuildContext context, Object error, StackTrace stackTrace) =>
      failures.add((error: error, stackTrace: stackTrace));
}

Future<CallbackLog> pumpSplash(
  WidgetTester tester, {
  List<LaunchTask> tasks = const [],
  Duration splashDuration = splash,
  Duration timeoutDuration = timeout,
  LaunchCompletedCallback? onCompleted,
}) async {
  final log = CallbackLog();
  await tester.pumpWidget(
    MaterialApp(
      home: LaunchSplashScreen(
        splashDuration: splashDuration,
        timeoutDuration: timeoutDuration,
        backgroundTasks: tasks,
        spinner: const SizedBox(key: spinnerKey),
        onCompleted: onCompleted ?? log.onCompleted,
        onFailure: log.onFailure,
        child: const SizedBox(key: childKey),
      ),
    ),
  );
  return log;
}

/// Disposes the splash so any live timers are cancelled before the test
/// framework checks for pending timers.
Future<void> tearDownSplash(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox());

void main() {
  group('construction', () {
    testWidgets('defaults splashDuration to 750ms', (tester) async {
      final completer = Completer<void>();
      final log = await pumpSplash(tester, tasks: [() => completer.future]);

      await tester.pump(const Duration(milliseconds: 749));
      expect(find.byKey(spinnerKey), findsNothing);

      await tester.pump(tick);
      expect(find.byKey(spinnerKey), findsOneWidget);
      expect(log.completed, isEmpty);

      await tearDownSplash(tester);
    });
  });

  group('while Showing', () {
    testWidgets('shows the child and no spinner', (tester) async {
      await pumpSplash(tester, tasks: [() => Completer<void>().future]);

      expect(find.byKey(childKey), findsOneWidget);
      expect(find.byKey(spinnerKey), findsNothing);

      await tearDownSplash(tester);
    });

    testWidgets('keeps the child even after tasks finish early', (
      tester,
    ) async {
      final log = await pumpSplash(tester);

      await tester.pump(splash - tick);
      expect(find.byKey(childKey), findsOneWidget);
      expect(find.byKey(spinnerKey), findsNothing);
      expect(log.completed, isEmpty);
      expect(log.failures, isEmpty);
    });
  });

  group('completion', () {
    testWidgets('calls onCompleted once when splashDuration elapses', (
      tester,
    ) async {
      final log = await pumpSplash(tester);

      await tester.pump(splash);
      expect(log.completed, hasLength(1));
      expect(log.failures, isEmpty);

      await tester.pump(timeout);
      expect(log.completed, hasLength(1));
    });

    testWidgets('shows the spinner over the child while tasks outlast '
        'splashDuration, then calls onCompleted', (tester) async {
      final completer = Completer<void>();
      final log = await pumpSplash(tester, tasks: [() => completer.future]);

      await tester.pump(splash);
      expect(find.byKey(childKey), findsOneWidget);
      expect(find.byKey(spinnerKey), findsOneWidget);
      expect(log.completed, isEmpty);

      completer.complete();
      await tester.pump();
      expect(log.completed, hasLength(1));
      expect(log.failures, isEmpty);
    });

    testWidgets('passes a context that can replace the splash', (
      tester,
    ) async {
      await pumpSplash(
        tester,
        onCompleted: (context) => Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const SizedBox(key: homeKey),
          ),
        ),
      );

      await tester.pump(splash);
      await tester.pumpAndSettle();

      expect(find.byKey(homeKey), findsOneWidget);
      expect(find.byKey(childKey), findsNothing);
      expect(find.byType(LaunchSplashScreen), findsNothing);
    });
  });

  group('failure', () {
    testWidgets('calls onFailure with a TimeoutException and a trace on '
        'timeout', (tester) async {
      final log = await pumpSplash(
        tester,
        tasks: [() => Completer<void>().future],
      );

      await tester.pump(timeout);

      expect(log.completed, isEmpty);
      expect(log.failures, hasLength(1));
      expect(
        log.failures.single.error,
        isA<TimeoutException>().having((e) => e.duration, 'duration', timeout),
      );
      expect(log.failures.single.stackTrace.toString(), isNotEmpty);
    });

    testWidgets('calls onFailure with the task error and its trace when a '
        'task throws', (tester) async {
      final error = StateError('boom');
      final completer = Completer<void>();
      final log = await pumpSplash(tester, tasks: [() => completer.future]);

      await tester.pump(tick);
      completer.completeError(error, trace);
      await tester.pump();

      expect(log.completed, isEmpty);
      expect(log.failures, [(error: error, stackTrace: trace)]);
    });

    testWidgets('calls onFailure only once', (tester) async {
      final completer = Completer<void>();
      final log = await pumpSplash(tester, tasks: [() => completer.future]);

      await tester.pump(timeout);
      completer.completeError(StateError('late'), trace);
      await tester.pump();

      expect(log.failures, hasLength(1));
    });
  });
}
