// packages/app_navigation/test/src/shared/dual_more_button_test.dart
import 'package:app_navigation/src/shared/dual_more_button.dart';
import 'package:app_navigation/src/shared/dual_nav_button.dart';
import 'package:extensions/enum/src/haptic_intensity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    required VoidCallback onPressed,
    Widget? caption = const Text('More'),
    Size size = const Size(48, 48),
    bool isSelected = false,
    Color? tint,
    HapticIntensity hapticIntensity = HapticIntensity.light,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DualMoreButton(
          onPressed: onPressed,
          caption: caption,
          size: size,
          isSelected: isSelected,
          tint: tint,
          hapticIntensity: hapticIntensity,
        ),
      ),
    );
  }

  group('DualMoreButton', () {
    testWidgets(
      'renders with default parameters and forwards them to DualNavButton',
      (
        tester,
      ) async {
        var pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DualMoreButton(
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        final dualNavButtonFinder = find.byType(DualNavButton);
        expect(dualNavButtonFinder, findsOneWidget);

        final dualNavButton = tester.widget<DualNavButton>(dualNavButtonFinder);

        expect(
          dualNavButton.icon,
          isA<Icon>().having((i) => i.icon, 'icon', Icons.more_horiz),
        );
        expect(
          dualNavButton.caption,
          isA<Text>().having((t) => t.data, 'data', 'More'),
        );
        expect(dualNavButton.size, equals(const Size(48, 48)));
        expect(dualNavButton.isSelected, isFalse);
        expect(dualNavButton.tint, isNull);
        expect(dualNavButton.hapticIntensity, equals(HapticIntensity.light));

        dualNavButton.onPressed();
        expect(pressed, isTrue);
      },
    );

    testWidgets('forwards custom parameters to DualNavButton', (tester) async {
      var pressed = false;
      const customCaption = Text('Custom More');
      const customSize = Size(64, 64);
      const customTint = Colors.red;
      const customHaptic = HapticIntensity.medium;

      await tester.pumpWidget(
        buildSubject(
          onPressed: () => pressed = true,
          caption: customCaption,
          size: customSize,
          isSelected: true,
          tint: customTint,
          hapticIntensity: customHaptic,
        ),
      );

      final dualNavButton = tester.widget<DualNavButton>(
        find.byType(DualNavButton),
      );

      expect(dualNavButton.caption, equals(customCaption));
      expect(dualNavButton.size, equals(customSize));
      expect(dualNavButton.isSelected, isTrue);
      expect(dualNavButton.tint, equals(customTint));
      expect(dualNavButton.hapticIntensity, equals(customHaptic));

      dualNavButton.onPressed();
      expect(pressed, isTrue);
    });

    testWidgets('allows caption to be explicitly null', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          onPressed: () {},
          caption: null,
        ),
      );

      final dualNavButton = tester.widget<DualNavButton>(
        find.byType(DualNavButton),
      );
      expect(dualNavButton.caption, isNull);
    });
  });
}
