// slider_stepper/test/src/step_button_test.dart

// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_stepper/src/step_button.dart' show StepButton;
import 'package:widget_themes/widget_themes.dart';

void main() {
  const themeButtonSize = 60.0;

  Widget wrap(
    Widget child, {
    bool withTheme = false,
  }) => MaterialApp(
    theme: withTheme
        ? ThemeData().copyWith(
            extensions: const [
              CrossFadeTheme(buttonSize: themeButtonSize),
            ],
          )
        : null,
    home: Scaffold(body: Center(child: child)),
  );

  SizedBox iconBox(WidgetTester tester) => tester.widget<SizedBox>(
    find
        .descendant(
          of: find.byType(StepButton),
          matching: find.byType(SizedBox),
        )
        .first,
  );

  group('StepButton — enabled tap', () {
    testWidgets('a single tap fires onPressed exactly once', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        wrap(
          StepButton(
            icon: Icons.add,
            onPressed: () => count++,
            tooltip: 'Increase',
          ),
        ),
      );

      await tester.tap(find.byType(StepButton));
      await tester.pump();

      expect(count, 1);
      // Let the initial-delay timer expire so no timers leak into teardown.
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('press-and-hold fires once immediately then auto-repeats', (
      tester,
    ) async {
      var count = 0;
      await tester.pumpWidget(
        wrap(
          StepButton(
            icon: Icons.add,
            onPressed: () => count++,
            initialDelay: const Duration(milliseconds: 100),
            repeatInterval: const Duration(milliseconds: 20),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(StepButton)),
      );

      // onTapDown -> _startRepeat -> immediate _fire.
      await tester.pump();
      expect(count, 1);

      // Cross the initial delay so the periodic timer arms and ticks.
      await tester.pump(const Duration(milliseconds: 110)); // arms periodic
      await tester.pump(const Duration(milliseconds: 20)); // 1st tick
      await tester.pump(const Duration(milliseconds: 20)); // 2nd tick
      expect(count, greaterThan(1));

      // Release -> onTapUp -> _stopRepeat cancels both timers.
      await gesture.up();
      await tester.pump();
      final afterRelease = count;

      // No further ticks after release.
      await tester.pump(const Duration(milliseconds: 100));
      expect(count, afterRelease);
    });

    testWidgets('tap cancel stops the repeat (onTapCancel path)', (
      tester,
    ) async {
      var count = 0;
      await tester.pumpWidget(
        wrap(
          StepButton(
            icon: Icons.add,
            onPressed: () => count++,
            initialDelay: const Duration(milliseconds: 100),
            repeatInterval: const Duration(milliseconds: 20),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(StepButton)),
      );
      await tester.pump();
      expect(count, 1); // immediate fire on down

      // Move far enough to cancel the tap before the initial delay elapses.
      await gesture.moveBy(const Offset(400, 400));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // Cancelled before the periodic timer ever armed: still just the one.
      await tester.pump(const Duration(milliseconds: 200));
      expect(count, 1);
    });
  });

  group('StepButton — disabled', () {
    testWidgets('null onPressed disables gestures and dims colours', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const StepButton(
            icon: Icons.remove,
            onPressed: null,
            tooltip: 'Decrease',
          ),
        ),
      );

      // _isEnabled false -> InkWell callbacks are null.
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTapDown, isNull);
      expect(inkWell.onTapUp, isNull);
      expect(inkWell.onTapCancel, isNull);

      // Tapping a disabled button does nothing (no throw, no fire).
      await tester.tap(find.byType(StepButton), warnIfMissed: false);
      await tester.pump();

      // Dimmed material colour (alpha 0.4 branch).
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(StepButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color!.a, closeTo(0.4, 0.001));
    });
  });

  group('StepButton — sizing and colours', () {
    testWidgets('explicit buttonSize sets the box and icon size '
        '(left arm of ??)', (tester) async {
      await tester.pumpWidget(
        wrap(
          StepButton(
            icon: Icons.add,
            onPressed: () {},
            buttonSize: 80,
          ),
          withTheme: true, // present but explicit wins
        ),
      );

      expect(iconBox(tester).width, 80);
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, closeTo(80 * 0.55, 0.001));
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('null buttonSize: box is unconstrained, icon size resolves '
        'from theme (right arm of ??)', (tester) async {
      await tester.pumpWidget(
        wrap(
          StepButton(
            icon: Icons.add,
            onPressed: () {},
          ),
          withTheme: true,
        ),
      );

      // Box width is null (no explicit size).
      expect(iconBox(tester).width, isNull);
      // Icon size resolves from CrossFadeTheme.buttonSize * 0.55.
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, closeTo(themeButtonSize * 0.55, 0.001));
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('custom color and iconColor override theme defaults', (
      tester,
    ) async {
      const bg = Color(0xFF112233);
      const fg = Color(0xFF445566);
      await tester.pumpWidget(
        wrap(
          StepButton(
            icon: Icons.add,
            onPressed: () {},
            color: bg,
            iconColor: fg,
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(StepButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, bg); // enabled -> full-opacity custom bg
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, fg);
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('null color/iconColor fall back to the colour scheme', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          StepButton(
            icon: Icons.add,
            onPressed: () {},
          ),
        ),
      );

      final scheme = ThemeData().colorScheme;
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(StepButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, scheme.primaryContainer);
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, scheme.onPrimaryContainer);
      await tester.pump(const Duration(milliseconds: 400));
    });
  });

  group('StepButton — tooltip', () {
    testWidgets('no tooltip -> no Tooltip widget (returns child directly)', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          StepButton(
            icon: Icons.add,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(Tooltip), findsNothing);
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('tooltip provided -> wraps in a Tooltip', (tester) async {
      await tester.pumpWidget(
        wrap(
          StepButton(
            icon: Icons.add,
            onPressed: () {},
            tooltip: 'Increase',
          ),
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Increase');
      await tester.pump(const Duration(milliseconds: 400));
    });
  });

  group('StepButton — disposal', () {
    testWidgets('disposing mid-hold cancels timers without throwing', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          StepButton(
            icon: Icons.add,
            onPressed: () {},
            initialDelay: const Duration(milliseconds: 100),
            repeatInterval: const Duration(milliseconds: 20),
          ),
        ),
      );

      // Begin a hold so a timer is pending, then unmount before release.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(StepButton)),
      );
      await tester.pump(const Duration(milliseconds: 110)); // periodic armed

      await tester.pumpWidget(wrap(const SizedBox()));
      await tester.pump();

      // Clean up the dangling gesture; dispose already cancelled the timers.
      await gesture.up();
      expect(find.byType(StepButton), findsNothing);
    });
  });
}
