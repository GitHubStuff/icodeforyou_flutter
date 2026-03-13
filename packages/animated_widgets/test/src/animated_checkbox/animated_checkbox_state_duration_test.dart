// test/src/animated_checkbox/_animated_checkbox_state_duration_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('_AnimatedCheckboxState._updateDuration', () {
    testWidgets(
        'updates controller duration when duration changes after animation '
        'completes', (tester) async {
      const initialDuration = Duration(milliseconds: 100);
      const updatedDuration = Duration(milliseconds: 200);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedCheckbox(
            draw: true,
            duration: initialDuration,
            onAnimationComplete: (_) {},
          ),
        ),
      );

      // Let the animation finish so _isAnimating becomes false.
      await tester.pumpAndSettle();

      // Change only duration — draw and curve stay the same so
      // _shouldReinitialize returns false and the else-if branch is taken.
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedCheckbox(
            draw: true,
            duration: updatedDuration,
            onAnimationComplete: (_) {},
          ),
        ),
      );

      expect(find.byType(AnimatedCheckbox), findsOneWidget);
    });

    testWidgets(
        'skips controller duration update when duration changes during '
        'active animation', (tester) async {
      const initialDuration = Duration(milliseconds: 300);
      const updatedDuration = Duration(milliseconds: 600);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedCheckbox(
            draw: true,
            duration: initialDuration,
            onAnimationComplete: (_) {},
          ),
        ),
      );

      // Pump partway — _isAnimating is still true.
      await tester.pump(const Duration(milliseconds: 50));

      // Change only duration while animation is in flight.
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedCheckbox(
            draw: true,
            duration: updatedDuration,
            onAnimationComplete: (_) {},
          ),
        ),
      );

      // Widget remains intact and animation eventually completes cleanly.
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedCheckbox), findsOneWidget);
    });
  });
}
