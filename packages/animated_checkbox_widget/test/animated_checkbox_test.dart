// test/animated_checkbox_test.dart
import 'package:animated_checkbox_widget/animated_checkbox_widget.dart'
    show AnimatedCheckbox;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Updates to animation duration', () {
    testWidgets(
      'updates duration when animation is complete and only duration changes',
      (tester) async {
        bool animationCompleted = false;

        // Create widget with initial duration
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: (drawState) {
                animationCompleted = true;
              },
            ),
          ),
        );

        // Wait for animation to complete (so _isAnimating becomes false)
        await tester.pumpAndSettle();
        expect(animationCompleted, true);

        // Reset for next animation
        animationCompleted = false;

        // Update ONLY the duration (same draw state, same curve)
        // This should trigger _updateDuration() path instead of full reinitialization
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true, // Same draw state
              duration: const Duration(milliseconds: 200), // Different duration
              // curve defaults to same value (Curves.easeInOutQuart)
              onAnimationComplete: (drawState) {
                animationCompleted = true;
              },
            ),
          ),
        );

        // The widget should still work correctly
        expect(find.byType(AnimatedCheckbox), findsOneWidget);
      },
    );
  });
  
  group('AnimatedCheckbox', () {
    late bool animationCompleted;
    late bool lastDrawState;

    void onAnimationComplete(bool drawState) {
      animationCompleted = true;
      lastDrawState = drawState;
    }

    setUp(() {
      animationCompleted = false;
      lastDrawState = false;
    });

    group('Constructor and Validation', () {
      testWidgets('creates with default values', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        expect(find.byType(AnimatedCheckbox), findsOneWidget);
      });

      testWidgets('creates with custom values', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              width: 150.0,
              background: Colors.red,
              strokeColor: Colors.blue,
              draw: false,
              duration: const Duration(milliseconds: 500),
              startOffset: const Offset(0.1, 0.6),
              midOffset: const Offset(0.5, 0.9),
              finishOffset: const Offset(0.9, 0.1),
              curve: Curves.linear,
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        expect(find.byType(AnimatedCheckbox), findsOneWidget);
      });

      test('throws assertion error for width less than 5.0', () {
        expect(
          () => AnimatedCheckbox(
            width: 4.0,
            draw: true,
            onAnimationComplete: (_) {},
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('accepts minimum width of 5.0', () {
        expect(
          () => AnimatedCheckbox(
            width: 5.0,
            draw: true,
            onAnimationComplete: (_) {},
          ),
          returnsNormally,
        );
      });

      testWidgets('throws assertion error for invalid startOffset.dx > 1.0', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              startOffset: const Offset(1.5, 0.5),
              onAnimationComplete: (_) {},
            ),
          ),
        );

        final exception = tester.takeException();
        expect(exception, isA<AssertionError>());
      });

      testWidgets('throws assertion error for invalid startOffset.dx < 0.0', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              startOffset: const Offset(-0.1, 0.5),
              onAnimationComplete: (_) {},
            ),
          ),
        );

        final exception = tester.takeException();
        expect(exception, isA<AssertionError>());
      });

      testWidgets('throws assertion error for invalid startOffset.dy > 1.0', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              startOffset: const Offset(0.5, 1.1),
              onAnimationComplete: (_) {},
            ),
          ),
        );

        final exception = tester.takeException();
        expect(exception, isA<AssertionError>());
      });

      testWidgets('throws assertion error for invalid startOffset.dy < 0.0', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              startOffset: const Offset(0.5, -0.1),
              onAnimationComplete: (_) {},
            ),
          ),
        );

        final exception = tester.takeException();
        expect(exception, isA<AssertionError>());
      });

      testWidgets('throws assertion error for invalid midOffset.dx > 1.0', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              midOffset: const Offset(1.1, 0.5),
              onAnimationComplete: (_) {},
            ),
          ),
        );

        final exception = tester.takeException();
        expect(exception, isA<AssertionError>());
      });

      testWidgets('throws assertion error for invalid midOffset.dx < 0.0', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              midOffset: const Offset(-0.1, 0.5),
              onAnimationComplete: (_) {},
            ),
          ),
        );

        final exception = tester.takeException();
        expect(exception, isA<AssertionError>());
      });

      testWidgets('throws assertion error for invalid midOffset.dy > 1.0', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              midOffset: const Offset(0.5, 1.1),
              onAnimationComplete: (_) {},
            ),
          ),
        );

        final exception = tester.takeException();
        expect(exception, isA<AssertionError>());
      });

      testWidgets('throws assertion error for invalid midOffset.dy < 0.0', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              midOffset: const Offset(0.5, -0.1),
              onAnimationComplete: (_) {},
            ),
          ),
        );

        final exception = tester.takeException();
        expect(exception, isA<AssertionError>());
      });

      testWidgets('throws assertion error for invalid finishOffset.dx > 1.0', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              finishOffset: const Offset(1.1, 0.5),
              onAnimationComplete: (_) {},
            ),
          ),
        );

        final exception = tester.takeException();
        expect(exception, isA<AssertionError>());
      });

      testWidgets('throws assertion error for invalid finishOffset.dx < 0.0', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              finishOffset: const Offset(-0.1, 0.5),
              onAnimationComplete: (_) {},
            ),
          ),
        );

        final exception = tester.takeException();
        expect(exception, isA<AssertionError>());
      });

      testWidgets('throws assertion error for invalid finishOffset.dy > 1.0', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              finishOffset: const Offset(0.5, 1.1),
              onAnimationComplete: (_) {},
            ),
          ),
        );

        final exception = tester.takeException();
        expect(exception, isA<AssertionError>());
      });

      testWidgets('throws assertion error for invalid finishOffset.dy < 0.0', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              finishOffset: const Offset(0.5, -0.1),
              onAnimationComplete: (_) {},
            ),
          ),
        );

        final exception = tester.takeException();
        expect(exception, isA<AssertionError>());
      });

      testWidgets('accepts valid offset boundaries (0.0 and 1.0)', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              startOffset: const Offset(0.0, 0.0),
              midOffset: const Offset(1.0, 1.0),
              finishOffset: const Offset(0.5, 0.5),
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        expect(find.byType(AnimatedCheckbox), findsOneWidget);
      });
    });

    group('Widget Structure', () {
      testWidgets('widget exists and functions', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        expect(find.byType(AnimatedCheckbox), findsOneWidget);
      });

      testWidgets('applies background color to Container', (tester) async {
        const testColor = Colors.yellow;
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              background: testColor,
              draw: true,
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.color, testColor);
      });

      testWidgets('uses transparent background by default', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.color, Colors.transparent);
      });
    });

    group('Animation Behavior', () {
      testWidgets('completes draw animation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        expect(animationCompleted, false);
        await tester.pumpAndSettle();
        expect(animationCompleted, true);
        expect(lastDrawState, true);
      });

      testWidgets('completes dissolve animation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: false,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        expect(animationCompleted, false);
        await tester.pumpAndSettle();
        expect(animationCompleted, true);
        expect(lastDrawState, false);
      });

      testWidgets('respects custom duration', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              duration: const Duration(milliseconds: 300),
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        expect(animationCompleted, false);

        await tester.pumpAndSettle();
        expect(animationCompleted, true);
      });

      testWidgets('handles zero duration', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              duration: Duration.zero,
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(animationCompleted, true);
      });

      testWidgets('handles extremely short duration', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              duration: const Duration(milliseconds: 1),
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(animationCompleted, true);
      });
    });

    group('Widget Updates', () {
      testWidgets('triggers new animation when draw state changes', (
        tester,
      ) async {
        bool firstAnimationCompleted = false;
        bool secondAnimationCompleted = false;

        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: (drawState) {
                firstAnimationCompleted = true;
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(firstAnimationCompleted, true);

        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: false,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: (drawState) {
                secondAnimationCompleted = true;
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(secondAnimationCompleted, true);
      });

      testWidgets('triggers new animation when curve changes', (tester) async {
        int animationCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              curve: Curves.linear,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: (drawState) {
                animationCount++;
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(animationCount, 1);

        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              curve: Curves.bounceIn,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: (drawState) {
                animationCount++;
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(animationCount, 2);
      });

      testWidgets('handles property updates without issues', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              width: 100.0,
              strokeColor: Colors.red,
              background: Colors.blue,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 50));

        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              width: 120.0,
              strokeColor: Colors.green,
              background: Colors.yellow,
              duration: const Duration(milliseconds: 200),
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(animationCompleted, true);
      });
    });

    group('Callback Verification', () {
      testWidgets('callback receives correct draw state for draw animation', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(animationCompleted, true);
        expect(lastDrawState, true);
      });

      testWidgets(
        'callback receives correct draw state for dissolve animation',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: AnimatedCheckbox(
                draw: false,
                duration: const Duration(milliseconds: 100),
                onAnimationComplete: onAnimationComplete,
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(animationCompleted, true);
          expect(lastDrawState, false);
        },
      );

      testWidgets('callback called once per animation cycle', (tester) async {
        int callCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: (drawState) {
                callCount++;
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(callCount, 1);
      });
    });

    group('Edge Cases', () {
      testWidgets('widget can be disposed during animation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              duration: const Duration(milliseconds: 200),
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 50));

        await tester.pumpWidget(const MaterialApp(home: SizedBox()));

        expect(find.byType(AnimatedCheckbox), findsNothing);
        await tester.pumpAndSettle();
      });

      testWidgets('handles rapid widget updates', (tester) async {
        for (int i = 0; i < 3; i++) {
          await tester.pumpWidget(
            MaterialApp(
              home: AnimatedCheckbox(
                draw: i.isEven,
                width: 50.0 + (i * 10),
                duration: const Duration(milliseconds: 50),
                onAnimationComplete: onAnimationComplete,
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 10));
        }

        await tester.pumpAndSettle();
        expect(find.byType(AnimatedCheckbox), findsOneWidget);
      });

      testWidgets('accepts minimum width boundary', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              width: 5.0,
              draw: true,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(animationCompleted, true);
      });

      testWidgets('handles extreme offset positions', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              startOffset: const Offset(0.0, 0.0),
              midOffset: const Offset(1.0, 1.0),
              finishOffset: const Offset(0.0, 1.0),
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: onAnimationComplete,
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(animationCompleted, true);
      });
    });
  });
}
