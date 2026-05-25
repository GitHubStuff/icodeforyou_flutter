// animated_rail_menu/test/src/widget/animated_rail_menu_safe_area_test.dart
//
// Regression test for the landscape overflow bug:
// LayoutBuilder sees full screen dimensions, but SafeArea inside _ElevatorRail
// consumes top/bottom insets. Without subtracting MediaQuery.paddingOf the
// calculator over-counts visibleItems and the Column overflows.
//
// The fix subtracts safePadding.top + safePadding.bottom from
// constraints.maxHeight before passing to _OverflowCalculator.

import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Page extends StatelessWidget {
  const _Page({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Center(child: Text(label));
}

// Seven entries — enough that SafeArea padding causes visible count to exceed
// available height when padding is not accounted for.
const _entries = <AnimatedRailMenuEntry>[
  AnimatedRailMenuEntry(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Home',
    page: _Page(label: 'Home Page'),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    label: 'Settings',
    page: _Page(label: 'Settings Page'),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profile',
    page: _Page(label: 'Profile Page'),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.notifications_outlined,
    activeIcon: Icons.notifications,
    label: 'Alerts',
    page: _Page(label: 'Alerts Page'),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.search_outlined,
    activeIcon: Icons.search,
    label: 'Search',
    page: _Page(label: 'Search Page'),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.bookmark_outline,
    activeIcon: Icons.bookmark,
    label: 'Saved',
    page: _Page(label: 'Saved Page'),
  ),
  AnimatedRailMenuEntry(
    icon: Icons.help_outline,
    activeIcon: Icons.help,
    label: 'Help',
    page: _Page(label: 'Help Page'),
  ),
];

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void main() {
  group('AnimatedRailMenu — SafeArea overflow regression', () {
    // Simulates iPhone landscape dimensions with non-zero safe area padding,
    // reproducing the exact condition that triggered the 10px overflow.
    testWidgets(
      'no overflow with safe area padding in landscape — vertical rail',
      (tester) async {
        // iPhone landscape: 844 × 390 logical pixels.
        // Safe area: top=0, bottom=34 (home indicator), left=44, right=44.
        tester.view.physicalSize = const Size(844, 390);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(
          top: 0,
          bottom: 34,
          left: 44,
          right: 44,
        );
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetPadding();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: AnimatedRailMenu(
              direction: RailDirection.vertical,
              entries: _entries,
              transitionDuration: Duration.zero,
            ),
          ),
        );
        await _pump(tester);

        // No RenderFlex overflow exception thrown.
        expect(tester.takeException(), isNull);
        // More button must appear — items that don't fit were pushed to overflow.
        expect(find.text('More'), findsOneWidget);
      },
    );

    testWidgets(
      'no overflow with zero safe area padding — vertical rail',
      (tester) async {
        // Standard portrait with no safe area insets — all items fit, no More.
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = FakeViewPadding.zero;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetPadding();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: AnimatedRailMenu(
              direction: RailDirection.vertical,
              entries: _entries,
              transitionDuration: Duration.zero,
            ),
          ),
        );
        await _pump(tester);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'no overflow with safe area padding in landscape — horizontal rail',
      (tester) async {
        tester.view.physicalSize = const Size(844, 390);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(
          top: 0,
          bottom: 34,
          left: 44,
          right: 44,
        );
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetPadding();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: AnimatedRailMenu(
              direction: RailDirection.horizontal,
              entries: _entries,
              transitionDuration: Duration.zero,
            ),
          ),
        );
        await _pump(tester);

        expect(tester.takeException(), isNull);
      },
    );
  });
}
