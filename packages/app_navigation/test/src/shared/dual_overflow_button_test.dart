// packages/app_navigation/test/src/shared/dual_overflow_button_test.dart
import 'package:app_navigation/src/shared/dual_more_button.dart';
import 'package:app_navigation/src/shared/dual_overflow_button.dart';
import 'package:app_navigation/src/shared/dual_popover_tile.dart';
import 'package:extensions/enum/src/haptic_intensity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject<T>({
    required List<Widget> popoverChildren,
    required ValueChanged<T> onSelected,
    VoidCallback? onCanceled,
    int initialScrollIndex = 0,
    Widget? caption = const Text('More'),
    Size size = const Size(48, 48),
    bool isSelected = false,
    Color? tint,
    HapticIntensity hapticIntensity = HapticIntensity.light,
    HapticIntensity scrollHaptic = HapticIntensity.light,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: DualOverflowButton<T>(
            popoverChildren: popoverChildren,
            onSelected: onSelected,
            onCanceled: onCanceled,
            initialScrollIndex: initialScrollIndex,
            caption: caption,
            size: size,
            isSelected: isSelected,
            tint: tint,
            hapticIntensity: hapticIntensity,
            scrollHaptic: scrollHaptic,
          ),
        ),
      ),
    );
  }

  group('DualOverflowButton', () {
    testWidgets('renders DualMoreButton with forwarded parameters', (
      tester,
    ) async {
      const customCaption = Text('Overflow');
      const customSize = Size(64, 64);
      const customTint = Colors.teal;
      const customHaptic = HapticIntensity.medium;

      await tester.pumpWidget(
        buildSubject<String>(
          popoverChildren: const [],
          onSelected: (_) {},
          caption: customCaption,
          size: customSize,
          isSelected: true,
          tint: customTint,
          hapticIntensity: customHaptic,
        ),
      );

      final dualMoreButtonFinder = find.byType(DualMoreButton);
      expect(dualMoreButtonFinder, findsOneWidget);

      final dualMoreButton = tester.widget<DualMoreButton>(
        dualMoreButtonFinder,
      );
      expect(dualMoreButton.caption, equals(customCaption));
      expect(dualMoreButton.size, equals(customSize));
      expect(dualMoreButton.isSelected, isTrue);
      expect(dualMoreButton.tint, equals(customTint));
      expect(dualMoreButton.hapticIntensity, equals(customHaptic));
    });

    testWidgets(
      'opens popover on tap and invokes onSelected when an option is chosen',
      (tester) async {
        String? selectedValue;

        await tester.pumpWidget(
          buildSubject<String>(
            popoverChildren: const [
              DualPopoverTile<String>(
                value: 'settings',
                label: Text('Settings'),
                icon: Icon(Icons.settings),
              ),
              DualPopoverTile<String>(
                value: 'help',
                label: Text('Help'),
                icon: Icon(Icons.help),
              ),
            ],
            onSelected: (value) => selectedValue = value,
          ),
        );

        await tester.tap(find.byType(DualOverflowButton<String>));
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Help'), findsOneWidget);

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        expect(selectedValue, equals('settings'));
      },
    );

    testWidgets(
      'invokes onCanceled when popover is dismissed without selection',
      (tester) async {
        var canceled = false;

        await tester.pumpWidget(
          buildSubject<String>(
            popoverChildren: const [
              DualPopoverTile<String>(
                value: 'settings',
                label: Text('Settings'),
                icon: Icon(Icons.settings),
              ),
            ],
            onSelected: (_) {},
            onCanceled: () => canceled = true,
          ),
        );

        await tester.tap(find.byType(DualOverflowButton<String>));
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);

        // Tap the barrier outside the popover to dismiss
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(canceled, isTrue);
      },
    );

    testWidgets(
      'handles cancellation without error when onCanceled is null',
      (tester) async {
        await tester.pumpWidget(
          buildSubject<String>(
            popoverChildren: const [
              DualPopoverTile<String>(
                value: 'settings',
                label: Text('Settings'),
                icon: Icon(Icons.settings),
              ),
            ],
            onSelected: (_) {},
            onCanceled: null,
          ),
        );

        await tester.tap(find.byType(DualOverflowButton<String>));
        await tester.pumpAndSettle();

        // Tap the barrier to dismiss
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsNothing);
      },
    );

    testWidgets(
      'does not trigger callbacks if widget is unmounted before popover resolves',
      (tester) async {
        var selectedCalled = false;
        var canceledCalled = false;

        await tester.pumpWidget(
          buildSubject<String>(
            popoverChildren: const [
              DualPopoverTile<String>(
                value: 'settings',
                label: Text('Settings'),
                icon: Icon(Icons.settings),
              ),
            ],
            onSelected: (_) => selectedCalled = true,
            onCanceled: () => canceledCalled = true,
          ),
        );

        await tester.tap(find.byType(DualOverflowButton<String>));
        await tester.pumpAndSettle();

        // Unmount the subject widget before interacting with the open popover
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        );

        // Dismiss the lingering dialog/popover
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        navigator.pop('settings');
        await tester.pumpAndSettle();

        expect(selectedCalled, isFalse);
        expect(canceledCalled, isFalse);
      },
    );
  });
}
