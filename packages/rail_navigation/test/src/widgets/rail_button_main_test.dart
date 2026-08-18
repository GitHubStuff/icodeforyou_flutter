// packages/rail_navigation/test/src/widgets/rail_button_main_test.dart

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_navigation/src/widgets/rail_button.dart';
import 'package:rail_navigation/src/widgets/rail_button_main.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('MainRailButton', () {
    testWidgets('displays the home icon with the default caption', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(MainRailButton(onPressed: () {})));

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.text('Main'), findsOneWidget);
    });

    testWidgets('displays a custom caption when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MainRailButton(
            onPressed: () {},
            caption: const Text('Start'),
          ),
        ),
      );

      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Main'), findsNothing);
    });

    testWidgets('renders icon-only when caption is explicitly null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MainRailButton(
            onPressed: () {},
            caption: null,
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('invokes onPressed when tapped', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _wrap(MainRailButton(onPressed: () => pressed++)),
      );

      await tester.tap(find.byType(MainRailButton));
      expect(pressed, 1);
    });

    testWidgets('forwards all behavioral parameters to RailButton', (
      tester,
    ) async {
      void onPressed() {}
      await tester.pumpWidget(
        _wrap(
          MainRailButton(
            onPressed: onPressed,
            size: const Size(64, 64),
            isSelected: true,
            tint: Colors.amber,
            hapticIntensity: HapticIntensity.none,
          ),
        ),
      );

      final inner = tester.widget<RailButton>(find.byType(RailButton));
      expect(inner.onPressed, same(onPressed));
      expect(inner.size, const Size(64, 64));
      expect(inner.isSelected, isTrue);
      expect(inner.tint, Colors.amber);
      expect(inner.hapticIntensity, HapticIntensity.none);
    });
  });
}
