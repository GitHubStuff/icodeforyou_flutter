// packages/custom_widgets/test/src/directional_slider/buttons/step_button_test.dart

import 'package:custom_widgets/src/directional_slider/buttons/step_button.dart'
    show StepButton;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deterministic initial delay before hold-to-repeat starts.
const Duration _kDelay = Duration(milliseconds: 100);

/// Deterministic cadence of hold-to-repeat ticks.
const Duration _kInterval = Duration(milliseconds: 50);

/// Fixed diameter so tests never depend on an ambient CrossFadeTheme.
const double _kButtonSize = 36;

/// Pumps [button] centred inside a Material scaffold.
Future<void> _pump(WidgetTester tester, StepButton button) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: button))),
  );
}

/// Builds an enabled [StepButton] that increments [onFire]'s counter.
StepButton _button({
  required VoidCallback? onPressed,
  Color? color,
  Color? iconColor,
  String? tooltip,
}) {
  return StepButton(
    icon: Icons.add,
    onPressed: onPressed,
    buttonSize: _kButtonSize,
    color: color,
    iconColor: iconColor,
    initialDelay: _kDelay,
    repeatInterval: _kInterval,
    tooltip: tooltip,
  );
}

void main() {
  group('StepButton', () {
    testWidgets('a single tap fires exactly once', (tester) async {
      var fires = 0;
      await _pump(tester, _button(onPressed: () => fires++));

      await tester.tap(find.byType(StepButton));
      await tester.pump(_kInterval * 5);

      expect(fires, 1);
    });

    testWidgets('press-and-hold auto-repeats until release', (tester) async {
      var fires = 0;
      await _pump(tester, _button(onPressed: () => fires++));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(StepButton)),
      );
      await tester.pump();
      expect(fires, 1);

      await tester.pump(_kDelay);
      await tester.pump(_kInterval * 3);
      expect(fires, 4);

      await gesture.up();
      await tester.pump(_kInterval * 5);
      expect(fires, 4);
    });

    testWidgets('a cancelled press stops the repeat timers', (tester) async {
      var fires = 0;
      await _pump(tester, _button(onPressed: () => fires++));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(StepButton)),
      );
      await tester.pump();
      await gesture.cancel();
      await tester.pump(_kDelay + _kInterval * 5);

      expect(fires, 1);
    });

    testWidgets('disposal while held cancels pending timers', (tester) async {
      var fires = 0;
      await _pump(tester, _button(onPressed: () => fires++));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(StepButton)),
      );
      await tester.pump(_kDelay + _kInterval);

      await tester.pumpWidget(const MaterialApp(home: Placeholder()));
      await gesture.up();
      await tester.pump(_kInterval * 5);

      expect(tester.takeException(), isNull);
    });

    testWidgets('null onPressed disables interaction and dims the button',
        (tester) async {
      await _pump(tester, _button(onPressed: null));

      await tester.tap(find.byType(StepButton));
      await tester.pump(_kDelay + _kInterval * 3);

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(StepButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color!.a, closeTo(0.4, 0.01));

      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(StepButton),
          matching: find.byType(Icon),
        ),
      );
      expect(icon.color!.a, closeTo(0.4, 0.01));
    });

    testWidgets('applies custom background and icon colors', (tester) async {
      await _pump(
        tester,
        _button(
          onPressed: () {},
          color: Colors.red,
          iconColor: Colors.yellow,
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(StepButton),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, Colors.red);
      expect(material.shape, const CircleBorder());

      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(StepButton),
          matching: find.byType(Icon),
        ),
      );
      expect(icon.color, Colors.yellow);
      expect(icon.size, _kButtonSize * 0.55);
    });

    testWidgets('omits the Tooltip when tooltip is null', (tester) async {
      await _pump(tester, _button(onPressed: () {}));

      expect(find.byType(Tooltip), findsNothing);
    });

    testWidgets('wraps in a Tooltip when tooltip is provided',
        (tester) async {
      await _pump(tester, _button(onPressed: () {}, tooltip: 'Increase'));

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Increase');
    });
  });
}
