// packages/sliders/test/src/slider_button_test.dart
import 'package:extensions/extensions.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodCall, SystemChannels;
import 'package:flutter_test/flutter_test.dart';
import 'package:sliders/sliders.dart';

void main() {
  group('SliderButton', () {
    group('rendering', () {
      testWidgets('shows the given icon', (tester) async {
        await pumpButton(
          tester,
          SliderButton(
            icon: const Icon(Icons.add_circle_outline),
            hint: 'Increase',
            onTap: () {},
          ),
        );

        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      });

      testWidgets('uses hint as the tooltip message', (tester) async {
        await pumpButton(
          tester,
          SliderButton(
            icon: const Icon(Icons.add_circle_outline),
            hint: 'Increase',
            onTap: () {},
          ),
        );

        final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
        expect(tooltip.message, 'Increase');
      });

      testWidgets('exposes hint through the button semantics', (tester) async {
        // Must be disposed before the test body returns: flutter_test
        // checks for live handles before any addTearDown callback runs.
        final semantics = tester.ensureSemantics();

        await pumpButton(
          tester,
          SliderButton(
            icon: const Icon(Icons.add_circle_outline),
            hint: 'Increase',
            onTap: () {},
          ),
        );

        expect(
          tester.getSemantics(find.byType(IconButton)),
          matchesSemantics(
            tooltip: 'Increase',
            isButton: true,
            isEnabled: true,
            hasEnabledState: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
          ),
        );

        semantics.dispose();
      });

      testWidgets('defaults haptic to light', (tester) async {
        await pumpButton(
          tester,
          const SliderButton(
            icon: Icon(Icons.add_circle_outline),
            hint: 'Increase',
          ),
        );

        final button = tester.widget<SliderButton>(find.byType(SliderButton));
        expect(button.haptic, HapticIntensity.light);
      });
    });

    group('enabled', () {
      testWidgets('calls onTap when tapped', (tester) async {
        var taps = 0;
        await pumpButton(
          tester,
          SliderButton(
            icon: const Icon(Icons.add_circle_outline),
            hint: 'Increase',
            onTap: () => taps++,
          ),
        );

        await tester.tap(find.byType(SliderButton));
        await tester.pump();

        expect(taps, 1);
      });

      testWidgets('fires the haptic before onTap', (tester) async {
        final events = <String>[];
        recordHaptics(tester, into: events);
        await pumpButton(
          tester,
          SliderButton(
            icon: const Icon(Icons.add_circle_outline),
            hint: 'Increase',
            haptic: .heavy,
            onTap: () => events.add('onTap'),
          ),
        );

        await tester.tap(find.byType(SliderButton));
        await tester.pump();

        expect(events, ['HapticFeedbackType.heavyImpact', 'onTap']);
      });

      testWidgets('fires no haptic for HapticIntensity.none', (tester) async {
        final events = <String>[];
        recordHaptics(tester, into: events);
        await pumpButton(
          tester,
          SliderButton(
            icon: const Icon(Icons.add_circle_outline),
            hint: 'Increase',
            haptic: .none,
            onTap: () => events.add('onTap'),
          ),
        );

        await tester.tap(find.byType(SliderButton));
        await tester.pump();

        expect(events, ['onTap']);
      });
    });

    group('disabled', () {
      testWidgets('null onTap disables the IconButton', (tester) async {
        await pumpButton(
          tester,
          const SliderButton(
            icon: Icon(Icons.add_circle_outline),
            hint: 'Increase',
          ),
        );

        final button = tester.widget<IconButton>(find.byType(IconButton));
        expect(button.onPressed, isNull);
      });

      testWidgets('tapping fires no haptic', (tester) async {
        final events = <String>[];
        recordHaptics(tester, into: events);
        await pumpButton(
          tester,
          const SliderButton(
            icon: Icon(Icons.add_circle_outline),
            hint: 'Increase',
          ),
        );

        await tester.tap(find.byType(SliderButton));
        await tester.pump();

        expect(events, isEmpty);
      });
    });
  });
}

/// Pumps [child] inside the Material scaffolding the widget needs.
Future<void> pumpButton(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

/// Intercepts the platform channel so haptic calls land in [into] (as
/// their `HapticFeedbackType` argument) instead of going nowhere.
void recordHaptics(WidgetTester tester, {required List<String> into}) {
  final messenger = tester.binding.defaultBinaryMessenger;

  Future<Object?> handler(MethodCall call) async {
    if (call.method == 'HapticFeedback.vibrate') {
      into.add(call.arguments as String);
    }
    return null;
  }

  messenger.setMockMethodCallHandler(SystemChannels.platform, handler);
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
}
