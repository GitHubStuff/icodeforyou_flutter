// packages/slider_directional/test/src/directional_test.dart
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_directional/slider_directional.dart';

void main() {
  group('Directional', () {
    /// Wraps the slider in the minimal MaterialApp scaffold tests need so the
    /// underlying [Slider] gets a Theme and Directionality.
    Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

    /// Finds the underlying Material [Slider] in the rendered tree.
    Finder findSlider() => find.byType(Slider);

    /// Pulls the current [Slider] widget out of the tree so the test can
    /// invoke its onChanged directly — sidesteps the gesture-simulation
    /// complexity introduced by [RotatedBox] and RTL [Directionality].
    Slider sliderWidget(WidgetTester tester) =>
        tester.widget<Slider>(findSlider());

    group('build / orientation', () {
      testWidgets('renders a bare Slider for SliderDirection.left',
          (tester) async {
        final controller = DirectionalController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 1,
            ),
          ),
        );

        expect(findSlider(), findsOneWidget);
        // No RotatedBox, no explicit RTL wrapper above the slider.
        expect(find.byType(RotatedBox), findsNothing);
      });

      testWidgets('wraps the slider in RTL Directionality for right',
          (tester) async {
        final controller = DirectionalController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.right,
              min: 0,
              max: 10,
              step: 1,
            ),
          ),
        );

        expect(findSlider(), findsOneWidget);
        // The slider's enclosing Directionality should report RTL.
        final ctx = tester.element(findSlider());
        expect(Directionality.of(ctx), TextDirection.rtl);
      });

      testWidgets('wraps the slider in RotatedBox(quarterTurns: 3) for bottom',
          (tester) async {
        final controller = DirectionalController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.bottom,
              min: 0,
              max: 10,
              step: 1,
            ),
          ),
        );

        final rotated = tester.widget<RotatedBox>(find.byType(RotatedBox));
        expect(rotated.quarterTurns, 3);
      });

      testWidgets('wraps the slider in RotatedBox(quarterTurns: 1) for top',
          (tester) async {
        final controller = DirectionalController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.top,
              min: 0,
              max: 10,
              step: 1,
            ),
          ),
        );

        final rotated = tester.widget<RotatedBox>(find.byType(RotatedBox));
        expect(rotated.quarterTurns, 1);
      });
    });

    group('grid wiring', () {
      testWidgets('passes min, max, and divisions through to Slider',
          (tester) async {
        final controller = DirectionalController(initial: 5);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 1,
            ),
          ),
        );

        final slider = sliderWidget(tester);
        expect(slider.min, 0);
        expect(slider.max, 10);
        expect(slider.divisions, 10);
        expect(slider.value, 5);
      });

      testWidgets('plumbs the explicit label through to Slider',
          (tester) async {
        final controller = DirectionalController(initial: 4);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 1,
              label: 'custom',
            ),
          ),
        );

        expect(sliderWidget(tester).label, 'custom');
      });

      testWidgets('defaults label to value formatted to the grid decimals',
          (tester) async {
        final controller = DirectionalController(initial: 0.4);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.left,
              min: 0,
              max: 1,
              step: 0.1,
            ),
          ),
        );

        // step = 0.1 → 1 decimal place.
        expect(sliderWidget(tester).label, '0.4');
      });

      testWidgets('plumbs the active/inactive/thumb colors through',
          (tester) async {
        final controller = DirectionalController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 1,
              activeColor: const Color(0xFF112233),
              inactiveColor: const Color(0xFF445566),
              thumbColor: const Color(0xFF778899),
            ),
          ),
        );

        final slider = sliderWidget(tester);
        expect(slider.activeColor, const Color(0xFF112233));
        expect(slider.inactiveColor, const Color(0xFF445566));
        expect(slider.thumbColor, const Color(0xFF778899));
      });
    });

    group('onChanged / interaction', () {
      testWidgets(
          'snaps the raw slider value, updates the controller, '
          'and fires onChanged with the snapped value', (tester) async {
        final controller = DirectionalController();
        addTearDown(controller.dispose);

        final emitted = <double>[];

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 1,
              onChanged: emitted.add,
            ),
          ),
        );

        // 3.7 should snap to 4.0.
        sliderWidget(tester).onChanged!(3.7);
        await tester.pump();

        expect(controller.value, 4.0);
        expect(emitted, [4.0]);
      });

      testWidgets('handles a null onChanged callback', (tester) async {
        final controller = DirectionalController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 1,
            ),
          ),
        );

        // Must not throw with a null onChanged.
        sliderWidget(tester).onChanged!(2.4);
        await tester.pump();
        expect(controller.value, 2.0);
      });

      testWidgets('does not fire haptics when crossing within the same step',
          (tester) async {
        final controller = DirectionalController();
        addTearDown(controller.dispose);

        final hapticCalls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding
            .instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') hapticCalls.add(call);
          return null;
        });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding
              .instance.defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, null);
        });

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 1,
              enableHapticFeedback: true,
            ),
          ),
        );

        // 0.2 snaps back to 0 — same index as the initial 0. No haptic.
        sliderWidget(tester).onChanged!(0.2);
        await tester.pump();
        expect(hapticCalls, isEmpty);
      });

      testWidgets(
          'fires haptic feedback when crossing into a new step bucket '
          'while enableHapticFeedback is true', (tester) async {
        final controller = DirectionalController();
        addTearDown(controller.dispose);

        final hapticCalls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding
            .instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') hapticCalls.add(call);
          return null;
        });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding
              .instance.defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, null);
        });

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 1,
              enableHapticFeedback: true,
              hapticIntensity: HapticIntensity.light,
            ),
          ),
        );

        // Cross from index 0 to index 4.
        sliderWidget(tester).onChanged!(3.7);
        await tester.pump();
        expect(hapticCalls, isNotEmpty);
      });

      testWidgets(
          'does not fire haptic feedback when crossing a step bucket '
          'while enableHapticFeedback is false', (tester) async {
        final controller = DirectionalController();
        addTearDown(controller.dispose);

        final hapticCalls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding
            .instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') hapticCalls.add(call);
          return null;
        });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding
              .instance.defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, null);
        });

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 1,
            ),
          ),
        );

        // Cross a bucket boundary — but haptics are off.
        sliderWidget(tester).onChanged!(3.7);
        await tester.pump();
        expect(hapticCalls, isEmpty);
      });
    });

    group('didUpdateWidget', () {
      testWidgets(
          're-baselines the step index when the controller reference changes',
          (tester) async {
        final a = DirectionalController();
        final b = DirectionalController(initial: 5);
        addTearDown(a.dispose);
        addTearDown(b.dispose);

        final hapticCalls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding
            .instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') hapticCalls.add(call);
          return null;
        });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding
              .instance.defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, null);
        });

        await tester.pumpWidget(
          host(
            Directional(
              controller: a,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 1,
              enableHapticFeedback: true,
            ),
          ),
        );

        // Swap to controller b (value 5). The state should re-baseline its
        // step index to 5, so a snap to 5 does not fire a haptic.
        await tester.pumpWidget(
          host(
            Directional(
              controller: b,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 1,
              enableHapticFeedback: true,
            ),
          ),
        );

        sliderWidget(tester).onChanged!(5);
        await tester.pump();
        expect(hapticCalls, isEmpty);
      });

      testWidgets('re-baselines the step index when the grid changes',
          (tester) async {
        final controller = DirectionalController();
        addTearDown(controller.dispose);

        final hapticCalls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding
            .instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') hapticCalls.add(call);
          return null;
        });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding
              .instance.defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, null);
        });

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 1,
              enableHapticFeedback: true,
            ),
          ),
        );

        // Change the grid (step). didUpdateWidget should re-baseline.
        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 2,
              enableHapticFeedback: true,
            ),
          ),
        );

        // Snapping 0 stays at index 0 on the new grid — no haptic.
        sliderWidget(tester).onChanged!(0);
        await tester.pump();
        expect(hapticCalls, isEmpty);
      });

      testWidgets(
          'does not re-baseline when neither controller nor grid changes',
          (tester) async {
        final controller = DirectionalController();
        addTearDown(controller.dispose);

        Widget build(String label) => host(
              Directional(
                controller: controller,
                direction: SliderDirection.left,
                min: 0,
                max: 10,
                step: 1,
                label: label,
              ),
            );

        await tester.pumpWidget(build('a'));
        await tester.pumpWidget(build('b'));

        // Slider still wired up and reflects the second label.
        expect(sliderWidget(tester).label, 'b');
      });
    });

    group('controller-driven rebuild', () {
      testWidgets(
          'programmatic writes to the controller update the Slider value '
          'without rebuilding the parent', (tester) async {
        final controller = DirectionalController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          host(
            Directional(
              controller: controller,
              direction: SliderDirection.left,
              min: 0,
              max: 10,
              step: 1,
            ),
          ),
        );

        expect(sliderWidget(tester).value, 0.0);

        controller.value = 7;
        await tester.pump();

        expect(sliderWidget(tester).value, 7.0);
      });
    });
  });
}
