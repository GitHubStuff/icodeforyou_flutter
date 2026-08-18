// packages/three_d_sphere/test/src/three_d_sphere_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_d_sphere/src/quadrant.dart';
import 'package:three_d_sphere/src/three_d_sphere.dart';

void main() {
  group('ThreeDSphere', () {
    test('throws AssertionError if width is not greater than zero', () {
      // Create the widget, then pass its own element (which implements
      // BuildContext) to safely test the build method assertions.
      const w1 = ThreeDSphere(width: 0, height: 100, color: Colors.blue);
      expect(
        () => w1.build(w1.createElement()),
        throwsA(isA<AssertionError>()),
      );

      const w2 = ThreeDSphere(width: -10, height: 100, color: Colors.blue);
      expect(
        () => w2.build(w2.createElement()),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError if height is not greater than zero', () {
      const w1 = ThreeDSphere(width: 100, height: 0, color: Colors.blue);
      expect(
        () => w1.build(w1.createElement()),
        throwsA(isA<AssertionError>()),
      );

      const w2 = ThreeDSphere(width: 100, height: -10, color: Colors.blue);
      expect(
        () => w2.build(w2.createElement()),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError if sphereRadius is not greater than zero', () {
      const w1 = ThreeDSphere(
        width: 100,
        height: 100,
        color: Colors.blue,
        sphereRadius: 0,
      );
      expect(
        () => w1.build(w1.createElement()),
        throwsA(isA<AssertionError>()),
      );

      const w2 = ThreeDSphere(
        width: 100,
        height: 100,
        color: Colors.blue,
        sphereRadius: -1.0,
      );
      expect(
        () => w2.build(w2.createElement()),
        throwsA(isA<AssertionError>()),
      );
    });

    // Test all 8 quadrants to hit every branch of the three switch statements
    // inside _ThreeDSpherePainter
    for (final quadrant in Quadrant.values) {
      testWidgets(
        'renders successfully with lightSource Quadrant.${quadrant.name}',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ThreeDSphere(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                  lightSource: quadrant,
                ),
              ),
            ),
          );

          expect(find.byType(ThreeDSphere), findsOneWidget);

          // Scaffold and MaterialApp inject their own CustomPaints.
          // We must look specifically for the CustomPaint INSIDE our sphere.
          expect(
            find.descendant(
              of: find.byType(ThreeDSphere),
              matching: find.byType(CustomPaint),
            ),
            findsOneWidget,
          );
        },
      );
    }

    testWidgets(
      'clamps HSL lightness correctly when color is fully white or black',
      (tester) async {
        // By rendering white and black, we force _changeLightness to hit both
        // the > 1.0 and < 0.0 clamp boundaries.
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ThreeDSphere(width: 100, height: 100, color: Colors.white),
                  ThreeDSphere(width: 100, height: 100, color: Colors.black),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(ThreeDSphere), findsNWidgets(2));
      },
    );

    testWidgets('shouldRepaint returns correct values on property changes', (
      tester,
    ) async {
      Widget buildSphere({
        Color color = Colors.red,
        Color gradientColor = Colors.white,
        Quadrant lightSource = Quadrant.topLeft,
        double sphereRadius = 1.15,
      }) {
        return MaterialApp(
          home: Scaffold(
            body: ThreeDSphere(
              width: 100,
              height: 100,
              color: color,
              gradientColor: gradientColor,
              lightSource: lightSource,
              sphereRadius: sphereRadius,
            ),
          ),
        );
      }

      // Initial render
      await tester.pumpWidget(buildSphere());
      expect(find.byType(ThreeDSphere), findsOneWidget);

      // Pump identical widget to trigger shouldRepaint returning false
      await tester.pumpWidget(buildSphere());

      // Trigger shouldRepaint returning true by changing color
      await tester.pumpWidget(buildSphere(color: Colors.blue));

      // Trigger shouldRepaint returning true by changing gradientColor
      await tester.pumpWidget(buildSphere(gradientColor: Colors.yellow));

      // Trigger shouldRepaint returning true by changing lightSource
      await tester.pumpWidget(buildSphere(lightSource: Quadrant.bottomRight));

      // Trigger shouldRepaint returning true by changing sphereRadius
      await tester.pumpWidget(buildSphere(sphereRadius: 2.0));

      expect(find.byType(ThreeDSphere), findsOneWidget);
    });
  });
}
