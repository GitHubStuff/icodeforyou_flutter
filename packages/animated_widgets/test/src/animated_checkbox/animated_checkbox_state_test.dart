// test/src/animated_checkbox/animated_checkbox_state_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const double _checkboxWidth = 48;
const Color _background = Colors.transparent;
const Color _strokeColor = Colors.black;
const Duration _shortDuration = Duration(milliseconds: 100);
const Duration _longDuration = Duration(milliseconds: 400);
const Offset _validStart = Offset(0.1, 0.5);
const Offset _validMid = Offset(0.4, 0.8);
const Offset _validFinish = Offset(0.9, 0.2);

void main() {
  Widget buildSubject({
    bool draw = true,
    Duration duration = _shortDuration,
    Curve curve = Curves.linear,
    Offset startOffset = _validStart,
    Offset midOffset = _validMid,
    Offset finishOffset = _validFinish,
    ValueChanged<bool>? onAnimationComplete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AnimatedCheckbox(
          width: _checkboxWidth,
          background: _background,
          strokeColor: _strokeColor,
          draw: draw,
          duration: duration,
          curve: curve,
          startOffset: startOffset,
          midOffset: midOffset,
          finishOffset: finishOffset,
          onAnimationComplete: onAnimationComplete ?? (_) {},
        ),
      ),
    );
  }

  group('AnimatedCheckbox', () {
    testWidgets('renders a CustomPaint while drawing', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(CustomPaint), findsWidgets);

      await tester.pumpAndSettle();
    });

    testWidgets('completes with draw == true', (tester) async {
      final completedWith = <bool>[];

      await tester.pumpWidget(
        buildSubject(onAnimationComplete: completedWith.add),
      );
      await tester.pumpAndSettle();

      expect(completedWith, <bool>[true]);
    });

    testWidgets(
      'generates dissolve particles and completes with draw == false',
      (tester) async {
        final completedWith = <bool>[];

        await tester.pumpWidget(
          buildSubject(draw: false, onAnimationComplete: completedWith.add),
        );
        await tester.pumpAndSettle();

        expect(completedWith, <bool>[false]);
      },
    );

    testWidgets('reinitializes the animation when draw changes', (
      tester,
    ) async {
      final completedWith = <bool>[];

      await tester.pumpWidget(
        buildSubject(onAnimationComplete: completedWith.add),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        buildSubject(draw: false, onAnimationComplete: completedWith.add),
      );
      await tester.pumpAndSettle();

      expect(completedWith, <bool>[true, false]);
    });

    testWidgets('reinitializes the animation when curve changes', (
      tester,
    ) async {
      final completedWith = <bool>[];

      await tester.pumpWidget(
        buildSubject(onAnimationComplete: completedWith.add),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        buildSubject(
          curve: Curves.easeIn,
          onAnimationComplete: completedWith.add,
        ),
      );
      await tester.pumpAndSettle();

      expect(completedWith, <bool>[true, true]);
    });

    testWidgets('updates the duration when idle and only the duration changes', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.pumpWidget(buildSubject(duration: _longDuration));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('ignores a duration change while still animating', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      await tester.pumpWidget(buildSubject(duration: _longDuration));

      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
    });

    testWidgets('disposes the controller when removed from the tree', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());

      expect(tester.takeException(), isNull);
    });

    group('offset validation', () {
      testWidgets('asserts when dx exceeds 1.0', (tester) async {
        await tester.pumpWidget(
          buildSubject(startOffset: const Offset(1.5, 0.5)),
        );

        expect(tester.takeException(), isA<AssertionError>());
      });

      testWidgets('asserts when dx is below 0.0', (tester) async {
        await tester.pumpWidget(
          buildSubject(startOffset: const Offset(-0.5, 0.5)),
        );

        expect(tester.takeException(), isA<AssertionError>());
      });

      testWidgets('asserts when dy exceeds 1.0', (tester) async {
        await tester.pumpWidget(
          buildSubject(startOffset: const Offset(0.5, 1.5)),
        );

        expect(tester.takeException(), isA<AssertionError>());
      });

      testWidgets('asserts when dy is below 0.0', (tester) async {
        await tester.pumpWidget(
          buildSubject(startOffset: const Offset(0.5, -0.5)),
        );

        expect(tester.takeException(), isA<AssertionError>());
      });
    });
  });
}
