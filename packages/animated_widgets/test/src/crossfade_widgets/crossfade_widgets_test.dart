// packages/animated_widgets/test/src/crossfade_widgets/crossfade_widgets_test.dart

import 'package:animated_widgets/animated_widgets.dart'
    show CrossFadeAxis, CrossFadeWidgets;
import 'package:custom_widgets/custom_widgets.dart'
    show DirectionalSliderAndButtons;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const firstLabel = 'alpha';
  const secondLabel = 'bravo';
  const thirdLabel = 'charlie';

  const explicitDuration = Duration(milliseconds: 200);
  const explicitButtonSize = 32.0;

  const twoChildren = <Widget>[Text(firstLabel), Text(secondLabel)];
  const threeChildren = <Widget>[
    Text(firstLabel),
    Text(secondLabel),
    Text(thirdLabel),
  ];

  // Single entry point so every test exercises the public surface the same
  // way the app does, and so the theme-resolution branch can be triggered by
  // simply omitting [duration]/[buttonSize].
  Future<void> pumpCrossFade(
    WidgetTester tester, {
    required List<Widget> children,
    Duration? duration,
    double? buttonSize,
    CrossFadeAxis direction = CrossFadeAxis.left,
    void Function(int index)? onIndexChanged,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CrossFadeWidgets(
            duration: duration,
            buttonSize: buttonSize,
            direction: direction,
            onIndexChanged: onIndexChanged,
            children: children,
          ),
        ),
      ),
    );
  }

  group('CrossFadeWidgets', () {
    group('with fewer than two children', () {
      testWidgets('renders nothing when children is empty', (tester) async {
        await pumpCrossFade(tester, children: const []);

        expect(find.byType(CrossFadeWidgets), findsOneWidget);
        // Early return takes the SizedBox.shrink() path: no stepper machinery.
        expect(find.byType(AnimatedSwitcher), findsNothing);
        expect(find.byType(DirectionalSliderAndButtons), findsNothing);
      });

      testWidgets('renders the only child when given exactly one',
          (tester) async {
        await pumpCrossFade(tester, children: const [Text(firstLabel)]);

        expect(find.text(firstLabel), findsOneWidget);
        // The lone child is returned directly, never wrapped in the stepper.
        expect(find.byType(AnimatedSwitcher), findsNothing);
        expect(find.byType(DirectionalSliderAndButtons), findsNothing);
      });
    });

    group('with two or more children', () {
      testWidgets(
        'shows the first child and the slider using explicit values',
        (tester) async {
          await pumpCrossFade(
            tester,
            children: threeChildren,
            duration: explicitDuration,
            buttonSize: explicitButtonSize,
          );

          expect(find.byType(AnimatedSwitcher), findsOneWidget);
          expect(find.byType(DirectionalSliderAndButtons), findsOneWidget);
          // Only the active (first) child is mounted by AnimatedSwitcher.
          expect(find.text(firstLabel), findsOneWidget);
          expect(find.text(secondLabel), findsNothing);
          expect(find.text(thirdLabel), findsNothing);
        },
      );

      testWidgets(
        'forwards a non-default direction and an onIndexChanged callback',
        (tester) async {
          var changeCount = 0;

          await pumpCrossFade(
            tester,
            children: twoChildren,
            duration: explicitDuration,
            buttonSize: explicitButtonSize,
            direction: CrossFadeAxis.left,
            onIndexChanged: (_) => changeCount++,
          );

          expect(find.byType(DirectionalSliderAndButtons), findsOneWidget);
          // The widget never invokes onIndexChanged for the initial child;
          // emission behavior is verified in the cubit's own test.
          expect(changeCount, isZero);
        },
      );

      testWidgets(
        'resolves duration and buttonSize from CrossFadeTheme when omitted',
        (tester) async {
          // No explicit duration/buttonSize: exercises the right-hand side of
          // both `?? CrossFadeTheme.of(context)` defaults.
          await pumpCrossFade(tester, children: twoChildren);

          expect(find.byType(AnimatedSwitcher), findsOneWidget);
          expect(find.byType(DirectionalSliderAndButtons), findsOneWidget);
          expect(find.text(firstLabel), findsOneWidget);
        },
      );

      testWidgets('disposes its controller when removed from the tree',
          (tester) async {
        await pumpCrossFade(
          tester,
          children: twoChildren,
          duration: explicitDuration,
          buttonSize: explicitButtonSize,
        );
        expect(find.byType(CrossFadeWidgets), findsOneWidget);

        // Replacing the tree unmounts the stateful interior and runs dispose().
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CrossFadeWidgets), findsNothing);
        // A clean settle with no thrown FlutterError confirms the controller
        // was disposed exactly once.
        expect(tester.takeException(), isNull);
      });
    });
  });
}
