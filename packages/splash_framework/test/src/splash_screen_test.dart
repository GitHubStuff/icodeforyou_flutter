// packages/splash_framework/test/src/splash_screen_test.dart

import 'dart:async';

import 'package:custom_widgets/custom_widgets.dart' show SolidScreenColor;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splash_framework/src/splash_screen.dart';

void main() {
  group('SplashScreen', () {
    testWidgets(
      'renders initial UI without CircularProgressIndicator during duration',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SplashScreen(
              duration: const Duration(milliseconds: 50),
              tasks: [
                () => Future<void>.delayed(const Duration(milliseconds: 100)),
              ],
              onComplete: () {},
              onError: (_, _) {},
              child: const Text('Child Content'),
            ),
          ),
        );

        // Verify the background and child render, but no loading spinner yet
        expect(find.text('Child Content'), findsOneWidget);
        expect(find.byType(SolidScreenColor), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Allow the remaining timers to complete so the test exits cleanly
        await tester.pumpAndSettle();
      },
    );

    testWidgets('displays CircularProgressIndicator when tasks exceed duration', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            duration: const Duration(milliseconds: 10),
            tasks: [
              () => Future<void>.delayed(const Duration(milliseconds: 100)),
            ],
            onComplete: () {},
            onError: (_, _) {},
            child: const SizedBox(),
          ),
        ),
      );

      // Advance past the minimum duration, but before the 100ms task completes
      await tester.pump(const Duration(milliseconds: 20));

      // The Cubit emits SplashWaiting, UI should now show the progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('calls onComplete when tasks finish successfully', (
      tester,
    ) async {
      var onCompleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            duration: const Duration(milliseconds: 10),
            tasks: [() => Future<void>.value()],
            onComplete: () => onCompleteCalled = true,
            onError: (_, __) => fail('onError should not be called'),
            child: const SizedBox(),
          ),
        ),
      );

      // Advance time enough to clear both the duration and the tasks
      await tester.pump(const Duration(milliseconds: 20));

      // Verify the listener caught SplashComplete and fired the callback
      expect(onCompleteCalled, isTrue);
    });

    testWidgets(
      'calls onError and surfaces rethrown exception when a task fails',
      (tester) async {
        Object? capturedError;
        StackTrace? capturedStack;
        Object? unhandledZoneError;

        // await the zone execution directly, removing the need for a Completer
        await runZonedGuarded(
          () async {
            await tester.pumpWidget(
              MaterialApp(
                home: SplashScreen(
                  duration: const Duration(milliseconds: 10),
                  tasks: [
                    () async {
                      await Future<void>.delayed(
                        const Duration(milliseconds: 20),
                      );
                      throw Exception('Test Crash');
                    },
                  ],
                  onComplete: () => fail('onComplete should not be called'),
                  onError: (error, stack) {
                    capturedError = error;
                    capturedStack = stack;
                  },
                  child: const SizedBox(),
                ),
              ),
            );

            // Advance time to trigger the exception
            await tester.pump(const Duration(milliseconds: 30));
          },
          (error, stack) {
            unhandledZoneError = error;
          },
        );

        // Verify the BlocConsumer listener successfully fired the onError callback
        expect(capturedError, isException);
        expect(capturedStack, isA<StackTrace>());

        // Verify the Cubit's debug-mode logic successfully rethrew the exception
        // into the unhandled Dart zone.
        expect(unhandledZoneError, isException);
      },
    );
  });
}
