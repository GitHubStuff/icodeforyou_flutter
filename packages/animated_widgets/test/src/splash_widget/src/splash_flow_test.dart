// animated_widgets/test/src/splash_widget/src/splash_flow_test.dart
import 'dart:async';

import 'package:animated_widgets/src/splash_widget/src/splash_cubit.dart'
    show SplashCubit;
import 'package:animated_widgets/src/splash_widget/src/splash_screen.dart'
    show SplashScreen;
import 'package:animated_widgets/src/splash_widget/src/splash_state.dart'
    show
        BackgroundTaskFailed,
        IndeterminateShowing,
        LandingShowing,
        SplashShowing,
        TimedOut;
import 'package:custom_widgets/custom_widgets.dart' show UninheritedText;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const _splashKey = Key('splash');
const _landingKey = Key('landing');
const _intermediateKey = Key('intermediate');
const _timeoutKey = Key('timeout');
const _failKey = Key('fail-custom');

Widget _subject({
  required SplashCubit cubit,
  required List<Future<void>> tasks,
  Widget? intermediateWidget,
  Widget? timeoutWidget,
  Widget Function(BuildContext, Object, StackTrace)? failBuilder,
}) {
  return MaterialApp(
    home: BlocProvider<SplashCubit>.value(
      value: cubit,
      child: SplashScreen(
        splashWidget: const Text('SPLASH', key: _splashKey),
        landingPage: const Text('LANDING', key: _landingKey),
        tasks: tasks,
        intermediateWidget: intermediateWidget,
        timeoutWidget: timeoutWidget,
        backgroundTaskFailedWidgetBuilder: failBuilder,
      ),
    ),
  );
}

void main() {
  group('SplashFlow', () {
    testWidgets('shows the splash widget first, centered', (tester) async {
      final cubit = SplashCubit();

      await tester.pumpWidget(
        _subject(cubit: cubit, tasks: [Completer<void>().future]),
      );

      expect(cubit.state, isA<SplashShowing>());
      expect(find.byKey(_splashKey), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byKey(_splashKey),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );

      // Close in-body: cancels the live splash timer before the framework's
      // pending-timer check (which runs before addTearDown callbacks).
      await cubit.close();
    });

    testWidgets('shows the default progress indicator while indeterminate', (
      tester,
    ) async {
      final cubit = SplashCubit();

      await tester.pumpWidget(
        _subject(cubit: cubit, tasks: [Completer<void>().future]),
      );
      await tester.pump(cubit.config.splashDuration);
      await tester.pump();

      expect(cubit.state, isA<IndeterminateShowing>());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await cubit.close(); // cancels the live timeout timer
    });

    testWidgets('shows a provided intermediate widget while indeterminate', (
      tester,
    ) async {
      final cubit = SplashCubit();

      await tester.pumpWidget(
        _subject(
          cubit: cubit,
          tasks: [Completer<void>().future],
          intermediateWidget: const Text('LOADING', key: _intermediateKey),
        ),
      );
      await tester.pump(cubit.config.splashDuration);
      await tester.pump();

      expect(cubit.state, isA<IndeterminateShowing>());
      expect(find.byKey(_intermediateKey), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await cubit.close();
    });

    testWidgets('shows the landing page when tasks complete', (tester) async {
      final cubit = SplashCubit();

      await tester.pumpWidget(
        _subject(cubit: cubit, tasks: [Future<void>.value()]),
      );
      await tester.pump(); // flush the completed-task microtask
      await tester.pump(
        cubit.config.splashDuration,
      ); // splash elapses -> landing
      await tester.pumpAndSettle(); // terminal: safe to settle the crossfade

      expect(cubit.state, isA<LandingShowing>());
      expect(find.byKey(_landingKey), findsOneWidget);

      await cubit.close();
    });

    testWidgets('shows the default timeout widget on timeout', (tester) async {
      final cubit = SplashCubit();

      await tester.pumpWidget(
        _subject(cubit: cubit, tasks: [Completer<void>().future]),
      );
      await tester.pump(cubit.config.splashDuration); // -> indeterminate
      await tester.pump(cubit.config.timeoutDuration); // -> timed out
      await tester.pumpAndSettle();

      expect(cubit.state, isA<TimedOut>());
      expect(find.byType(UninheritedText), findsOneWidget);

      await cubit.close();
    });

    testWidgets('shows a provided timeout widget on timeout', (tester) async {
      final cubit = SplashCubit();

      await tester.pumpWidget(
        _subject(
          cubit: cubit,
          tasks: [Completer<void>().future],
          timeoutWidget: const Text('TIMED OUT', key: _timeoutKey),
        ),
      );
      await tester.pump(cubit.config.splashDuration);
      await tester.pump(cubit.config.timeoutDuration);
      await tester.pumpAndSettle();

      expect(cubit.state, isA<TimedOut>());
      expect(find.byKey(_timeoutKey), findsOneWidget);
      expect(find.byType(UninheritedText), findsNothing);

      await cubit.close();
    });

    testWidgets('uses the failure builder with the error and stack trace', (
      tester,
    ) async {
      final cubit = SplashCubit();
      final task = Completer<void>();
      final error = Exception('boom');

      Object? receivedError;
      StackTrace? receivedStack;

      await tester.pumpWidget(
        _subject(
          cubit: cubit,
          tasks: [task.future],
          failBuilder: (context, e, s) {
            receivedError = e;
            receivedStack = s;
            return const Text('CUSTOM FAIL', key: _failKey);
          },
        ),
      );
      task.completeError(error);
      await tester.pump(); // -> background task failed
      await tester.pumpAndSettle();

      expect(cubit.state, isA<BackgroundTaskFailed>());
      expect(find.byKey(_failKey), findsOneWidget);
      expect(receivedError, same(error));
      expect(receivedStack, isNotNull);

      await cubit.close();
    });

    testWidgets('falls back to the default failure widget without a builder', (
      tester,
    ) async {
      final cubit = SplashCubit();
      final task = Completer<void>();

      await tester.pumpWidget(_subject(cubit: cubit, tasks: [task.future]));
      task.completeError(Exception('boom'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(cubit.state, isA<BackgroundTaskFailed>());
      expect(find.byType(UninheritedText), findsOneWidget);

      await cubit.close();
    });
  });
}
