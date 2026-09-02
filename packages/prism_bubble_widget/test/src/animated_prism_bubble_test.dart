// packages/prism_bubble_widget/test/src/animated_prism_bubble_test.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_bubble_widget/prism_bubble_widget.dart'
    show AnimatedPrismBubble, BubbleAnimationEnum, PrismBubbleWidget;

void main() {
  Widget buildFrame(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets(
    'renders with combined mode and updates both controllers on tick',
    (tester) async {
      const childWidget = Text('Bubble Content');

      await tester.pumpWidget(
        buildFrame(
          const AnimatedPrismBubble(
            width: 150,
            height: 150,
            mode: BubbleAnimationEnum.combined,
            tintColor: Colors.blue,
            arcOpacity: 0.5,
            minDiffusion: 0.2,
            maxDiffusion: 0.8,
            breathingDuration: Duration(milliseconds: 1000),
            rotationDuration: Duration(milliseconds: 2000),
            child: childWidget,
          ),
        ),
      );

      final prismFinder = find.byType(PrismBubbleWidget);
      expect(prismFinder, findsOneWidget);

      var prism = tester.widget<PrismBubbleWidget>(prismFinder);
      expect(prism.child, equals(childWidget));
      expect(prism.width, 150);
      expect(prism.height, 150);
      expect(prism.tintColor, Colors.blue);
      expect(prism.arcOpacity, 0.5);
      expect(prism.diffusion, closeTo(0.2, 0.001));
      expect(prism.phaseAngle, closeTo(0.0, 0.001));

      // Advance by 500ms (50% breathing cycle, 25% rotation cycle)
      await tester.pump(const Duration(milliseconds: 500));

      prism = tester.widget<PrismBubbleWidget>(find.byType(PrismBubbleWidget));
      expect(prism.diffusion, closeTo(0.5, 0.05));
      expect(prism.phaseAngle, closeTo(0.5 * math.pi, 0.05));
    },
  );

  testWidgets(
    'renders with breathing-only mode and leaves rotation controller null',
    (tester) async {
      await tester.pumpWidget(
        buildFrame(
          const AnimatedPrismBubble(
            width: 100,
            height: 100,
            mode: BubbleAnimationEnum.breathing,
            minDiffusion: 0.0,
            maxDiffusion: 1.0,
            breathingDuration: Duration(milliseconds: 1000),
          ),
        ),
      );

      // Advance time to verify breathing changes but phase angle stays 0
      await tester.pump(const Duration(milliseconds: 500));

      final prism = tester.widget<PrismBubbleWidget>(
        find.byType(PrismBubbleWidget),
      );
      expect(prism.diffusion, closeTo(0.5, 0.05));
      expect(prism.phaseAngle, 0.0);
    },
  );

  testWidgets(
    'renders with liquidRotation-only mode and leaves breathing null',
    (tester) async {
      await tester.pumpWidget(
        buildFrame(
          const AnimatedPrismBubble(
            width: 100,
            height: 100,
            mode: BubbleAnimationEnum.liquidRotation,
            minDiffusion: 0.1,
            maxDiffusion: 0.9,
            rotationDuration: Duration(milliseconds: 1000),
          ),
        ),
      );

      // Advance time to verify phase changes but diffusion stays at min
      await tester.pump(const Duration(milliseconds: 500));

      final prism = tester.widget<PrismBubbleWidget>(
        find.byType(PrismBubbleWidget),
      );
      expect(prism.diffusion, 0.1);
      expect(prism.phaseAngle, closeTo(math.pi, 0.05));
    },
  );

  testWidgets(
    'disposes animation controllers cleanly without leaks or exceptions',
    (tester) async {
      await tester.pumpWidget(
        buildFrame(
          const AnimatedPrismBubble(
            width: 100,
            height: 100,
            mode: BubbleAnimationEnum.combined,
          ),
        ),
      );

      expect(find.byType(AnimatedPrismBubble), findsOneWidget);

      // Replace tree to trigger dispose on state
      await tester.pumpWidget(
        buildFrame(const SizedBox.shrink()),
      );

      expect(find.byType(AnimatedPrismBubble), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
