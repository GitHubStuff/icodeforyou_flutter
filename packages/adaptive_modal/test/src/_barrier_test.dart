// test/src/_barrier_test.dart
// ignore_for_file: lines_longer_than_80_chars, comment_references

import 'package:adaptive_modal/src/_barrier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Pumps a [BarrierWidget] with the given [opacity] animation value and
/// optional [onDismiss] callback.
Future<void> pumpBarrier(
  WidgetTester tester, {
  Color color = Colors.black54,
  double opacityValue = 1.0,
  VoidCallback? onDismiss,
}) async {
  final controller = AnimationController(
    vsync: const TestVSync(),
    value: opacityValue,
  );

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: BarrierWidget(
        color: color,
        opacity: controller,
        onDismiss: onDismiss ?? () {},
      ),
    ),
  );
}

void main() {
  // -------------------------------------------------------------------------
  // BarrierWidget — rendering
  // -------------------------------------------------------------------------

  group('BarrierWidget renders', () {
    testWidgets('finds BarrierWidget in tree', (tester) async {
      await pumpBarrier(tester);
      expect(find.byType(BarrierWidget), findsOneWidget);
    });

    testWidgets('contains a FadeTransition', (tester) async {
      await pumpBarrier(tester);
      expect(find.byType(FadeTransition), findsOneWidget);
    });

    testWidgets('contains a ColoredBox', (tester) async {
      await pumpBarrier(tester);
      expect(find.byType(ColoredBox), findsOneWidget);
    });

    testWidgets('contains a SizedBox.expand', (tester) async {
      await pumpBarrier(tester);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('contains a GestureDetector', (tester) async {
      await pumpBarrier(tester);
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('ColoredBox has the correct color', (tester) async {
      await pumpBarrier(tester, color: Colors.red);
      final box = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(box.color, Colors.red);
    });

    testWidgets('ColoredBox has default black54 color', (tester) async {
      await pumpBarrier(tester);
      final box = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(box.color, Colors.black54);
    });
  });

  // -------------------------------------------------------------------------
  // BarrierWidget — opacity animation
  // -------------------------------------------------------------------------

  group('BarrierWidget opacity', () {
    testWidgets('FadeTransition opacity is 1.0 when controller at 1.0', (tester) async {
      await pumpBarrier(tester);
      final fade = tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(fade.opacity.value, closeTo(1.0, 0.001));
    });

    testWidgets('FadeTransition opacity is 0.0 when controller at 0.0', (tester) async {
      await pumpBarrier(tester, opacityValue: 0);
      final fade = tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(fade.opacity.value, closeTo(0.0, 0.001));
    });

    testWidgets('FadeTransition opacity is 0.5 when controller at 0.5', (tester) async {
      await pumpBarrier(tester, opacityValue: 0.5);
      final fade = tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(fade.opacity.value, closeTo(0.5, 0.001));
    });
  });

  // -------------------------------------------------------------------------
  // BarrierWidget — tap dismiss
  // -------------------------------------------------------------------------

  group('BarrierWidget onDismiss', () {
    testWidgets('calls onDismiss when tapped', (tester) async {
      var dismissed = false;
      await pumpBarrier(tester, onDismiss: () => dismissed = true);

      await tester.tap(find.byType(GestureDetector));
      expect(dismissed, isTrue);
    });

    testWidgets('calls onDismiss exactly once per tap', (tester) async {
      var count = 0;
      await pumpBarrier(tester, onDismiss: () => count++);

      await tester.tap(find.byType(GestureDetector));
      expect(count, 1);
    });

    testWidgets('calls onDismiss on each separate tap', (tester) async {
      var count = 0;
      await pumpBarrier(tester, onDismiss: () => count++);

      await tester.tap(find.byType(GestureDetector));
      await tester.tap(find.byType(GestureDetector));
      expect(count, 2);
    });

    testWidgets('does not throw when onDismiss is a no-op', (tester) async {
      await pumpBarrier(tester, onDismiss: () {});
      await tester.tap(find.byType(GestureDetector));
      // No exception thrown — test passes by reaching this line.
    });
  });

  // -------------------------------------------------------------------------
  // BarrierWidget — GestureDetector hit test behavior
  // -------------------------------------------------------------------------

  group('BarrierWidget hit testing', () {
    testWidgets('GestureDetector has opaque hit test behavior', (tester) async {
      await pumpBarrier(tester);
      final detector = tester.widget<GestureDetector>(find.byType(GestureDetector));
      expect(detector.behavior, HitTestBehavior.opaque);
    });
  });

  // -------------------------------------------------------------------------
  // BarrierWidget — different colors
  // -------------------------------------------------------------------------

  group('BarrierWidget color variants', () {
    testWidgets('uses blue barrier color', (tester) async {
      await pumpBarrier(tester, color: Colors.blue);
      final box = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(box.color, Colors.blue);
    });

    testWidgets('uses transparent barrier color', (tester) async {
      await pumpBarrier(tester, color: Colors.transparent);
      final box = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(box.color, Colors.transparent);
    });

    testWidgets('uses custom rgba color', (tester) async {
      const custom = Color(0x40FF0000);
      await pumpBarrier(tester, color: custom);
      final box = tester.widget<ColoredBox>(find.byType(ColoredBox));
      expect(box.color, custom);
    });
  });
}
