// packages/counter_ring/test/src/range_progress_ring_test.dart

import 'package:counter_ring/counter_ring.dart' show RangeProgressRing;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RangeProgressRing', () {
    // Non-const construction so the constructor and its assert record LCOV
    // hits; `const` invocations are folded at compile time and record none.
    RangeProgressRing build({
      required double startValue,
      required double finishValue,
      required double currentValue,
      double size = 120,
      double strokeWidth = 8,
      Color? color,
      Color? backgroundColor,
      Widget? child,
    }) {
      return RangeProgressRing(
        startValue: startValue,
        finishValue: finishValue,
        currentValue: currentValue,
        size: size,
        strokeWidth: strokeWidth,
        color: color,
        backgroundColor: backgroundColor,
        child: child,
      );
    }

    group('constructor', () {
      test('throws AssertionError when startValue equals finishValue', () {
        expect(
          () => build(startValue: 5, finishValue: 5, currentValue: 5),
          throwsAssertionError,
        );
      });

      test('applies default size and strokeWidth', () {
        final ring = build(startValue: 0, finishValue: 10, currentValue: 0);

        expect(ring.size, 120);
        expect(ring.strokeWidth, 8);
        expect(ring.color, isNull);
        expect(ring.backgroundColor, isNull);
        expect(ring.child, isNull);
      });

      test('stores all supplied arguments', () {
        const child = SizedBox.shrink();
        final ring = build(
          startValue: 1,
          finishValue: 2,
          currentValue: 1.5,
          size: 200,
          strokeWidth: 16,
          color: Colors.red,
          backgroundColor: Colors.blue,
          child: child,
        );

        expect(ring.startValue, 1);
        expect(ring.finishValue, 2);
        expect(ring.currentValue, 1.5);
        expect(ring.size, 200);
        expect(ring.strokeWidth, 16);
        expect(ring.color, Colors.red);
        expect(ring.backgroundColor, Colors.blue);
        expect(ring.child, same(child));
      });
    });

    group('isCountingDown', () {
      test('is false when startValue < finishValue', () {
        final ring = build(startValue: 0, finishValue: 10, currentValue: 0);

        expect(ring.isCountingDown, isFalse);
      });

      test('is true when startValue > finishValue', () {
        final ring = build(startValue: 10, finishValue: 0, currentValue: 10);

        expect(ring.isCountingDown, isTrue);
      });

      test('is true for a negative-to-more-negative range', () {
        final ring = build(startValue: -1, finishValue: -5, currentValue: -1);

        expect(ring.isCountingDown, isTrue);
      });
    });

    group('progress', () {
      group('counting up', () {
        test('is 0.0 at startValue', () {
          final ring = build(startValue: 0, finishValue: 10, currentValue: 0);

          expect(ring.progress, 0);
        });

        test('is 0.5 at the midpoint', () {
          final ring = build(startValue: 0, finishValue: 10, currentValue: 5);

          expect(ring.progress, closeTo(0.5, 1e-9));
        });

        test('is 1.0 at finishValue', () {
          final ring = build(startValue: 0, finishValue: 10, currentValue: 10);

          expect(ring.progress, 1);
        });

        test('clamps to 1.0 beyond finishValue', () {
          final ring = build(startValue: 0, finishValue: 10, currentValue: 15);

          expect(ring.progress, 1);
        });

        test('clamps to 0.0 before startValue', () {
          final ring = build(startValue: 0, finishValue: 10, currentValue: -5);

          expect(ring.progress, 0);
        });

        test('handles a range that does not start at zero', () {
          final ring = build(startValue: 20, finishValue: 60, currentValue: 30);

          expect(ring.progress, closeTo(0.25, 1e-9));
        });

        test('handles a range spanning negative and positive values', () {
          final ring = build(startValue: -10, finishValue: 10, currentValue: 0);

          expect(ring.progress, closeTo(0.5, 1e-9));
        });
      });

      group('counting down', () {
        test('is 0.0 at startValue', () {
          final ring = build(startValue: 10, finishValue: 0, currentValue: 10);

          expect(ring.progress, 0);
        });

        test('is 0.5 at the midpoint', () {
          final ring = build(startValue: 10, finishValue: 0, currentValue: 5);

          expect(ring.progress, closeTo(0.5, 1e-9));
        });

        test('is 1.0 at finishValue', () {
          final ring = build(startValue: 10, finishValue: 0, currentValue: 0);

          expect(ring.progress, 1);
        });

        test('clamps to 1.0 beyond finishValue', () {
          final ring = build(startValue: 10, finishValue: 0, currentValue: -5);

          expect(ring.progress, 1);
        });

        test('clamps to 0.0 before startValue', () {
          final ring = build(startValue: 10, finishValue: 0, currentValue: 15);

          expect(ring.progress, 0);
        });

        test('handles a range that does not finish at zero', () {
          final ring = build(startValue: 60, finishValue: 20, currentValue: 30);

          expect(ring.progress, closeTo(0.75, 1e-9));
        });
      });
    });

    group('arcFraction', () {
      test('equals progress when counting up', () {
        final ring = build(startValue: 0, finishValue: 10, currentValue: 3);

        expect(ring.arcFraction, closeTo(0.3, 1e-9));
        expect(ring.arcFraction, ring.progress);
      });

      test('equals 1 - progress when counting down', () {
        final ring = build(startValue: 10, finishValue: 0, currentValue: 3);

        expect(ring.arcFraction, closeTo(0.3, 1e-9));
        expect(ring.arcFraction, closeTo(1 - ring.progress, 1e-9));
      });

      test('is 0.0 at the start of a count-up', () {
        final ring = build(startValue: 0, finishValue: 10, currentValue: 0);

        expect(ring.arcFraction, 0);
      });

      test('is 1.0 at the start of a countdown', () {
        final ring = build(startValue: 10, finishValue: 0, currentValue: 10);

        expect(ring.arcFraction, 1);
      });

      test('is 1.0 at the end of a count-up', () {
        final ring = build(startValue: 0, finishValue: 10, currentValue: 10);

        expect(ring.arcFraction, 1);
      });

      test('is 0.0 at the end of a countdown', () {
        final ring = build(startValue: 10, finishValue: 0, currentValue: 0);

        expect(ring.arcFraction, 0);
      });
    });

    group('build', () {
      Future<void> pump(WidgetTester tester, Widget ring) {
        return tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: Center(child: ring)),
          ),
        );
      }

      testWidgets('renders a square of the requested size', (tester) async {
        await pump(
          tester,
          build(
            startValue: 0,
            finishValue: 10,
            currentValue: 5,
            size: 150,
          ),
        );

        expect(
          tester.getSize(find.byType(RangeProgressRing)),
          const Size.square(150),
        );
      });

      testWidgets('forwards value, stroke and colours to the indicator', (
        tester,
      ) async {
        await pump(
          tester,
          build(
            startValue: 0,
            finishValue: 10,
            currentValue: 2.5,
            strokeWidth: 14,
            color: Colors.green,
            backgroundColor: Colors.grey,
          ),
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

        expect(indicator.value, closeTo(0.25, 1e-9));
        expect(indicator.strokeWidth, 14);
        expect(indicator.color, Colors.green);
        expect(indicator.backgroundColor, Colors.grey);
        expect(indicator.strokeCap, StrokeCap.round);
      });

      testWidgets('draws the remaining fraction when counting down', (
        tester,
      ) async {
        // 2.5 remaining of a 10 → 0 countdown: progress is 0.75, so the
        // painted arc is the remaining quarter.
        await pump(
          tester,
          build(startValue: 10, finishValue: 0, currentValue: 2.5),
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

        expect(indicator.value, closeTo(0.25, 1e-9));
      });

      testWidgets('passes null colours through so theme defaults apply', (
        tester,
      ) async {
        await pump(
          tester,
          build(startValue: 0, finishValue: 10, currentValue: 5),
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

        expect(indicator.color, isNull);
        expect(indicator.backgroundColor, isNull);
      });

      testWidgets('renders child centred when provided', (tester) async {
        const key = Key('ring-child');
        await pump(
          tester,
          build(
            startValue: 0,
            finishValue: 10,
            currentValue: 5,
            size: 200,
            child: const SizedBox.square(dimension: 20, key: key),
          ),
        );

        expect(find.byKey(key), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(RangeProgressRing),
            matching: find.byType(Center),
          ),
          findsOneWidget,
        );
        expect(
          tester.getCenter(find.byKey(key)),
          tester.getCenter(find.byType(RangeProgressRing)),
        );
      });

      testWidgets('omits the Center when child is null', (tester) async {
        await pump(
          tester,
          build(startValue: 0, finishValue: 10, currentValue: 5),
        );

        expect(
          find.descendant(
            of: find.byType(RangeProgressRing),
            matching: find.byType(Center),
          ),
          findsNothing,
        );

        final stack = tester.widget<Stack>(
          find.descendant(
            of: find.byType(RangeProgressRing),
            matching: find.byType(Stack),
          ),
        );
        expect(stack.children, hasLength(1));
        expect(stack.fit, StackFit.expand);
      });
    });
  });
}
