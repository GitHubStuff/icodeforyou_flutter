// animated_widgets/test/src/stepper_crossfade/stepper_crossfade_test.dart

// ignore_for_file: always_use_package_imports

import 'package:animated_widgets/src/stepper_crossfade/stepper_crossfade.dart';
import 'package:animated_widgets/src/stepper_crossfade/stepper_crossfade_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_directional/slider_directional.dart'
    show SliderDirection;
import 'package:slider_stepper/slider_stepper.dart';
import 'package:widget_themes/widget_themes.dart';

void main() {
  // Distinct, non-default theme values so the "resolve from theme" arms are
  // provably hit (defaults are 1250ms / 48).
  const themeDuration = Duration(milliseconds: 321);
  const themeButtonSize = 60.0;

  Widget wrap(
    Widget child, {
    bool withTheme = false,
  }) => MaterialApp(
    theme: withTheme
        ? (ThemeData().copyWith(
            extensions: const [
              CrossFadeTheme(
                crossFadeDuration: themeDuration,
                buttonSize: themeButtonSize,
              ),
            ],
          ))
        : null,
    home: Scaffold(body: child),
  );

  group('StepperCrossfade — fewer than two children', () {
    testWidgets('empty children renders SizedBox.shrink (no slider)', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const StepperCrossfade(children: [])));

      expect(find.byType(SliderStepper), findsNothing);
      // The build returns a const SizedBox.shrink() as the sole child of the
      // (stateless) StepperCrossfade element subtree — zero-sized, no cubit.
      final box = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(StepperCrossfade),
          matching: find.byType(SizedBox),
        ),
      );
      expect(box.width, 0);
      expect(box.height, 0);
      // The rendered extent is genuinely zero in both axes.
      expect(tester.getSize(find.byType(StepperCrossfade)), Size.zero);
    });

    testWidgets('single child renders that child directly (no slider)', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const StepperCrossfade(
            children: [Text('only')],
          ),
        ),
      );

      expect(find.text('only'), findsOneWidget);
      expect(find.byType(SliderStepper), findsNothing);
    });
  });

  group('StepperCrossfade — two or more children', () {
    testWidgets('builds the full stepper: provides cubit, shows first child '
        'and a SliderStepper', (tester) async {
      await tester.pumpWidget(
        wrap(
          const StepperCrossfade(
            children: [Text('a'), Text('b'), Text('c')],
          ),
        ),
      );

      expect(find.text('a'), findsOneWidget);
      expect(find.byType(SliderStepper), findsOneWidget);
      expect(find.byType(AnimatedSwitcher), findsOneWidget);

      // Cubit is provided to the subtree and bounded by child count.
      final BuildContext ctx = tester.element(find.byType(SliderStepper));
      final cubit = ctx.read<StepperCrossFadeCubit>();
      expect(cubit.min, 0);
      expect(cubit.max, 2); // length - 1
      expect(cubit.step, 1);
    });

    testWidgets('explicit duration is forwarded to the AnimatedSwitcher '
        '(left arm of duration ??)', (tester) async {
      const explicit = Duration(milliseconds: 77);
      await tester.pumpWidget(
        wrap(
          const StepperCrossfade(
            duration: explicit,
            children: [Text('a'), Text('b')],
          ),
          withTheme: true, // theme present but explicit must win
        ),
      );

      final switcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );
      expect(switcher.duration, explicit);
    });

    testWidgets('null duration resolves from CrossFadeTheme '
        '(right arm of duration ??)', (tester) async {
      await tester.pumpWidget(
        wrap(
          const StepperCrossfade(
            children: [Text('a'), Text('b')],
          ),
          withTheme: true,
        ),
      );

      final switcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );
      expect(switcher.duration, themeDuration);
    });

    testWidgets('explicit buttonSize is forwarded to SliderStepper '
        '(left arm of buttonSize ??)', (tester) async {
      await tester.pumpWidget(
        wrap(
          const StepperCrossfade(
            buttonSize: 99,
            children: [Text('a'), Text('b')],
          ),
          withTheme: true,
        ),
      );

      final stepper = tester.widget<SliderStepper>(find.byType(SliderStepper));
      expect(stepper.buttonSize, 99);
    });

    testWidgets('null buttonSize passes through (resolved downstream from '
        'theme) — right arm of buttonSize ??', (tester) async {
      await tester.pumpWidget(
        wrap(
          const StepperCrossfade(
            children: [Text('a'), Text('b')],
          ),
          withTheme: true,
        ),
      );

      // StepperCrossfade forwards buttonSize down to _StepperCrossFadeBody,
      // which resolves it: buttonSize ?? CrossFadeTheme.of(context).buttonSize.
      // With a null buttonSize and a registered theme, SliderStepper receives
      // the theme value — exercising the right arm of that ??.
      final stepper = tester.widget<SliderStepper>(find.byType(SliderStepper));
      expect(stepper.buttonSize, themeButtonSize);
    });

    testWidgets('custom direction is forwarded to SliderStepper', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const StepperCrossfade(
            direction: SliderDirection.right,
            children: [Text('a'), Text('b')],
          ),
        ),
      );

      final stepper = tester.widget<SliderStepper>(find.byType(SliderStepper));
      expect(stepper.direction, SliderDirection.right);
    });

    testWidgets('changing the controller value swaps the displayed child and '
        'fires onIndexChanged', (tester) async {
      final changes = <int>[];
      await tester.pumpWidget(
        wrap(
          StepperCrossfade(
            duration: const Duration(milliseconds: 10),
            onIndexChanged: changes.add,
            children: const [Text('a'), Text('b'), Text('c')],
          ),
        ),
      );

      expect(find.text('a'), findsOneWidget);

      // Drive the controller the cubit listens to via the live SliderStepper.
      final stepper = tester.widget<SliderStepper>(find.byType(SliderStepper));
      stepper.controller.value = 2;
      await tester.pump(); // cubit emits, BlocBuilder rebuilds
      await tester.pumpAndSettle(); // AnimatedSwitcher settles

      expect(find.text('c'), findsOneWidget);
      expect(changes, contains(2));
    });

    testWidgets('disposes its controller when removed from the tree', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const StepperCrossfade(
            children: [Text('a'), Text('b')],
          ),
        ),
      );
      expect(find.byType(SliderStepper), findsOneWidget);

      // Replace with an unrelated tree -> _StepperCrossFadeState.dispose runs.
      await tester.pumpWidget(wrap(const SizedBox()));
      await tester.pumpAndSettle();

      expect(find.byType(SliderStepper), findsNothing);
    });
  });
}
