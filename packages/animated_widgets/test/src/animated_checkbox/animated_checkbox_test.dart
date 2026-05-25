// test/animated_checkbox_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedCheckbox', () {
    late bool animationCompleted;
    late bool lastDrawState;

    void onComplete(bool drawState) {
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
              onAnimationComplete: onComplete,
            ),
          ),
        );
        expect(find.byType(AnimatedCheckbox), findsOneWidget);
      });

      testWidgets('creates with custom values', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              width: 150,
              background: Colors.red,
              strokeColor: Colors.blue,
              draw: false,
              duration: const Duration(milliseconds: 500),
              startOffset: const Offset(0.1, 0.6),
              midOffset: const Offset(0.5, 0.9),
              finishOffset: const Offset(0.9, 0.1),
              curve: Curves.linear,
              onAnimationComplete: onComplete,
            ),
          ),
        );
        expect(find.byType(AnimatedCheckbox), findsOneWidget);
      });

      test('throws assertion for width less than 5.0', () {
        expect(
          () => AnimatedCheckbox(
            width: 4,
            draw: true,
            onAnimationComplete: (_) {},
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('accepts minimum width of 5.0', () {
        expect(
          () => AnimatedCheckbox(
            width: 5,
            draw: true,
            onAnimationComplete: (_) {},
          ),
          returnsNormally,
        );
      });

      testWidgets('throws for invalid startOffset.dx > 1.0', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              startOffset: const Offset(1.5, 0.5),
              onAnimationComplete: (_) {},
            ),
          ),
        );
        expect(tester.takeException(), isA<AssertionError>());
      });

      testWidgets('throws for invalid startOffset.dx < 0.0', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              startOffset: const Offset(-0.1, 0.5),
              onAnimationComplete: (_) {},
            ),
          ),
        );
        expect(tester.takeException(), isA<AssertionError>());
      });

      testWidgets('throws for invalid startOffset.dy > 1.0', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              startOffset: const Offset(0.5, 1.1),
              onAnimationComplete: (_) {},
            ),
          ),
        );
        expect(tester.takeException(), isA<AssertionError>());
      });

      testWidgets('throws for invalid midOffset.dx > 1.0', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              midOffset: const Offset(1.1, 0.5),
              onAnimationComplete: (_) {},
            ),
          ),
        );
        expect(tester.takeException(), isA<AssertionError>());
      });

      testWidgets('throws for invalid finishOffset.dy < 0.0', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              finishOffset: const Offset(0.5, -0.1),
              onAnimationComplete: (_) {},
            ),
          ),
        );
        expect(tester.takeException(), isA<AssertionError>());
      });

      testWidgets('accepts valid offset boundaries', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              startOffset: Offset.zero,
              midOffset: const Offset(1, 1),
              finishOffset: const Offset(0.5, 0.5),
              onAnimationComplete: onComplete,
            ),
          ),
        );
        expect(find.byType(AnimatedCheckbox), findsOneWidget);
      });
    });

    group('Widget Structure', () {
      testWidgets('applies background color', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              background: Colors.yellow,
              draw: true,
              onAnimationComplete: onComplete,
            ),
          ),
        );
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.color, Colors.yellow);
      });

      testWidgets('uses transparent background by default', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              onAnimationComplete: onComplete,
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
              onAnimationComplete: onComplete,
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
              onAnimationComplete: onComplete,
            ),
          ),
        );
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
              onAnimationComplete: onComplete,
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
              onAnimationComplete: onComplete,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(animationCompleted, true);
      });

      testWidgets('callback called once per animation cycle', (tester) async {
        var callCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: (_) => callCount++,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(callCount, 1);
      });
    });

    group('Widget Updates', () {
      testWidgets('triggers new animation when draw state changes',
          (tester) async {
        var firstDone = false;
        var secondDone = false;

        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: (_) => firstDone = true,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(firstDone, true);

        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: false,
              duration: const Duration(milliseconds: 100),
              onAnimationComplete: (_) => secondDone = true,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(secondDone, true);
      });

      testWidgets('widget can be disposed during animation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedCheckbox(
              draw: true,
              duration: const Duration(milliseconds: 200),
              onAnimationComplete: onComplete,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        expect(find.byType(AnimatedCheckbox), findsNothing);
        await tester.pumpAndSettle();
      });
    });
  });
}
