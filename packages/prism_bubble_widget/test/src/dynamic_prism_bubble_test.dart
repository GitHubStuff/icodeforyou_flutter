// packages/prism_bubble_widget/test/src/dynamic_prism_bubble_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_bubble_widget/src/bubble_fluid_dynamic_enum.dart';
import 'package:prism_bubble_widget/src/dynamic_prism_bubble.dart';
import 'package:prism_bubble_widget/src/prism_bubble_widget.dart';

void main() {
  Widget buildFrame(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  group('DynamicPrismBubble', () {
    testWidgets(
      'renders with default parameters and forwards attributes correctly',
      (tester) async {
        const childWidget = Text('Dynamic Child');

        await tester.pumpWidget(
          buildFrame(
            const DynamicPrismBubble(
              width: 180,
              height: 180,
              child: childWidget,
            ),
          ),
        );

        final prismFinder = find.byType(PrismBubbleWidget);
        expect(prismFinder, findsOneWidget);

        final prism = tester.widget<PrismBubbleWidget>(prismFinder);
        expect(prism.width, 180);
        expect(prism.height, 180);
        expect(prism.child, equals(childWidget));
        expect(prism.tintColor, Colors.white);
        expect(prism.arcOpacity, 0.3);
      },
    );

    testWidgets(
      'animates dynamic properties over time with custom baseSpeed and preset',
      (tester) async {
        await tester.pumpWidget(
          buildFrame(
            const DynamicPrismBubble(
              width: 200,
              height: 200,
              dynamicPreset: BubbleFluidDynamicEnum.restless,
              tintColor: Colors.amber,
              arcOpacity: 0.6,
              baseSpeed: 2.0,
            ),
          ),
        );

        final initialPrism = tester.widget<PrismBubbleWidget>(
          find.byType(PrismBubbleWidget),
        );
        final initialDiffusion = initialPrism.diffusion;
        final initialPhase = initialPrism.phaseAngle;

        expect(initialPrism.tintColor, Colors.amber);
        expect(initialPrism.arcOpacity, 0.6);

        // Advance 10 seconds in the 120s loop cycle
        await tester.pump(const Duration(seconds: 10));

        final updatedPrism = tester.widget<PrismBubbleWidget>(
          find.byType(PrismBubbleWidget),
        );

        expect(
          updatedPrism.diffusion != initialDiffusion ||
              updatedPrism.phaseAngle != initialPhase,
          isTrue,
        );
      },
    );

    testWidgets(
      'disposes animation controller cleanly without leaks or exceptions',
      (tester) async {
        await tester.pumpWidget(
          buildFrame(
            const DynamicPrismBubble(
              width: 100,
              height: 100,
            ),
          ),
        );

        expect(find.byType(DynamicPrismBubble), findsOneWidget);

        // Replace tree to trigger dispose on state
        await tester.pumpWidget(
          buildFrame(const SizedBox.shrink()),
        );

        expect(find.byType(DynamicPrismBubble), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
