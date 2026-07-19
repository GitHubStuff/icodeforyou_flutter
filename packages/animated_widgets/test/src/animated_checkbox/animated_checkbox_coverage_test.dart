// animated_widgets/test/src/animated_checkbox/animated_checkbox_coverage_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(AnimatedCheckbox checkbox) =>
      MaterialApp(home: Scaffold(body: Center(child: checkbox)));

  group('AnimatedCheckbox', () {
    testWidgets('draws in and reports completion with draw == true', (
      tester,
    ) async {
      bool? completedWith;

      await tester.pumpWidget(
        host(
          AnimatedCheckbox(
            draw: true,
            onAnimationComplete: (draw) => completedWith = draw,
          ),
        ),
      );

      expect(find.byType(AnimatedCheckbox), findsOneWidget);

      await tester.pumpAndSettle();

      expect(completedWith, isTrue);
    });

    testWidgets('dissolves out and reports completion with draw == false', (
      tester,
    ) async {
      bool? completedWith;

      await tester.pumpWidget(
        host(
          AnimatedCheckbox(
            draw: true,
            onAnimationComplete: (draw) => completedWith = draw,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Toggle draw -> didUpdateWidget reinitialises and runs the dissolve.
      await tester.pumpWidget(
        host(
          AnimatedCheckbox(
            draw: false,
            onAnimationComplete: (draw) => completedWith = draw,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(completedWith, isFalse);
    });
  });
}
