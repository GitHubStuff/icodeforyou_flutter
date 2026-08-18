// packages/rail_navigation/test/src/widgets/rail_button_settings_test.dart

import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_navigation/src/widgets/rail_button.dart';
import 'package:rail_navigation/src/widgets/rail_button_settings.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('SettingsRailButton', () {
    testWidgets('displays the settings icon with the default caption', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(SettingsRailButton(onPressed: () {})));

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('displays a custom caption when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SettingsRailButton(
            onPressed: () {},
            caption: const Text('Options'),
          ),
        ),
      );

      expect(find.text('Options'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('renders icon-only when caption is explicitly null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SettingsRailButton(
            onPressed: () {},
            caption: null,
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('invokes onPressed when tapped', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _wrap(SettingsRailButton(onPressed: () => pressed++)),
      );

      await tester.tap(find.byType(SettingsRailButton));
      expect(pressed, 1);
    });

    testWidgets('forwards all behavioral parameters to RailButton', (
      tester,
    ) async {
      void onPressed() {}
      await tester.pumpWidget(
        _wrap(
          SettingsRailButton(
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
