// packages/sliders/test/slider_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SemanticsNode;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;
import 'package:sliders/sliders.dart' show SliderButton;
import 'package:sliders/src/constants.dart' show Constants;

const _hapticMethod = 'HapticFeedback.vibrate';

Widget _harness(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

/// Records every platform-channel call so haptic feedback can be asserted.
List<MethodCall> _recordPlatformCalls(WidgetTester tester) {
  final log = <MethodCall>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      log.add(call);
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return log;
}

/// Whether [node] or any of its descendants carries [tooltip].
///
/// A button's tooltip is published as the semantics `tooltip` attribute,
/// not as its `label`, and which node ends up holding it depends on how
/// [Tooltip] and [IconButton] fork or merge their nodes. Searching the
/// subtree keeps the test independent of that layout.
bool _subtreeHasTooltip(SemanticsNode node, String tooltip) {
  if (node.tooltip == tooltip) {
    return true;
  }
  var found = false;
  node.visitChildren((child) {
    found = _subtreeHasTooltip(child, tooltip);
    return !found;
  });
  return found;
}

void main() {
  group('SliderButton', () {
    group('rendering', () {
      testWidgets('shows the given icon', (tester) async {
        const icon = Icon(Icons.add_circle_outline);

        await tester.pumpWidget(
          _harness(SliderButton(icon: icon, hint: 'Increase', onTap: () {})),
        );

        expect(find.byWidget(icon), findsOneWidget);
      });

      testWidgets('uses Constants.iconSize for the icon', (tester) async {
        await tester.pumpWidget(
          _harness(
            SliderButton(
              icon: const Icon(Icons.add),
              hint: 'Increase',
              onTap: () {},
            ),
          ),
        );

        final button = tester.widget<IconButton>(find.byType(IconButton));
        expect(button.iconSize, Constants.iconSize);
      });

      testWidgets('uses hint as the tooltip', (tester) async {
        await tester.pumpWidget(
          _harness(
            SliderButton(
              icon: const Icon(Icons.add),
              hint: 'Increase',
              onTap: () {},
            ),
          ),
        );

        final button = tester.widget<IconButton>(find.byType(IconButton));
        expect(button.tooltip, 'Increase');
        expect(find.byTooltip('Increase'), findsOneWidget);
      });

      testWidgets('hint is exposed to semantics as the tooltip', (
        tester,
      ) async {
        // Dispose inside the test body: flutter_test verifies handles
        // before tearDown callbacks run, so addTearDown is too late.
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          _harness(
            SliderButton(
              icon: const Icon(Icons.add),
              hint: 'Increase',
              onTap: () {},
            ),
          ),
        );

        final root = tester.getSemantics(find.byType(MaterialApp));
        final hasIncrease = _subtreeHasTooltip(root, 'Increase');
        final hasDecrease = _subtreeHasTooltip(root, 'Decrease');
        handle.dispose();

        expect(hasIncrease, isTrue);
        expect(hasDecrease, isFalse);
      });

      testWidgets('haptic defaults to light', (tester) async {
        await tester.pumpWidget(
          _harness(
            const SliderButton(icon: Icon(Icons.add), hint: 'Increase'),
          ),
        );

        final button = tester.widget<SliderButton>(find.byType(SliderButton));
        expect(button.haptic, HapticIntensity.light);
      });
    });

    group('enabled state', () {
      testWidgets('a null onTap disables the IconButton', (tester) async {
        await tester.pumpWidget(
          _harness(
            const SliderButton(icon: Icon(Icons.add), hint: 'Increase'),
          ),
        );

        final button = tester.widget<IconButton>(find.byType(IconButton));
        expect(button.onPressed, isNull);
      });

      testWidgets('a non-null onTap enables the IconButton', (tester) async {
        await tester.pumpWidget(
          _harness(
            SliderButton(
              icon: const Icon(Icons.add),
              hint: 'Increase',
              onTap: () {},
            ),
          ),
        );

        final button = tester.widget<IconButton>(find.byType(IconButton));
        expect(button.onPressed, isNotNull);
      });
    });

    group('interaction', () {
      testWidgets('tapping calls onTap once', (tester) async {
        var taps = 0;

        await tester.pumpWidget(
          _harness(
            SliderButton(
              icon: const Icon(Icons.add),
              hint: 'Increase',
              onTap: () => taps++,
            ),
          ),
        );
        await tester.tap(find.byType(SliderButton));
        await tester.pump();

        expect(taps, 1);
      });

      testWidgets('tapping a disabled button does nothing', (tester) async {
        final log = _recordPlatformCalls(tester);

        await tester.pumpWidget(
          _harness(
            const SliderButton(icon: Icon(Icons.add), hint: 'Increase'),
          ),
        );
        await tester.tap(find.byType(SliderButton));
        await tester.pump();

        expect(
          log.where((call) => call.method == _hapticMethod),
          isEmpty,
        );
      });

      testWidgets('tapping fires the haptic before onTap', (tester) async {
        final log = _recordPlatformCalls(tester);
        var hapticCallsWhenTapped = -1;

        await tester.pumpWidget(
          _harness(
            SliderButton(
              icon: const Icon(Icons.add),
              hint: 'Increase',
              onTap: () => hapticCallsWhenTapped = log
                  .where((call) => call.method == _hapticMethod)
                  .length,
            ),
          ),
        );
        await tester.tap(find.byType(SliderButton));
        await tester.pump();

        expect(hapticCallsWhenTapped, 1);
      });

      testWidgets('HapticIntensity.none fires no haptic', (tester) async {
        final log = _recordPlatformCalls(tester);
        var taps = 0;

        await tester.pumpWidget(
          _harness(
            SliderButton(
              icon: const Icon(Icons.add),
              hint: 'Increase',
              haptic: .none,
              onTap: () => taps++,
            ),
          ),
        );
        await tester.tap(find.byType(SliderButton));
        await tester.pump();

        expect(taps, 1);
        expect(
          log.where((call) => call.method == _hapticMethod),
          isEmpty,
        );
      });
    });
  });
}
