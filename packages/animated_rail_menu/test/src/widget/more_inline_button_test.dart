// test/src/widget/more_inline_button_test.dart

// _MoreInlineButton is only rendered by _ElevatorRail (RailDirection.vertical).
// Force vertical overflow by constraining height so only one item fits,
// pushing the remaining entries into the More flyout (showMenu popup).
// RailIcon.phone itemExtent = 56dp — height 100px fits exactly one item.

import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Page extends StatelessWidget {
  const _Page({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Center(child: Text(label));
}

const _entries = <RailMenuEntry>[
  RailMenuEntry(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Home',
    page: _Page(label: 'Home Page'),
  ),
  RailMenuEntry(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    label: 'Settings',
    page: _Page(label: 'Settings Page'),
  ),
  RailMenuEntry(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profile',
    page: _Page(label: 'Profile Page'),
  ),
];

Future<void> _pumpVerticalOverflow(
  WidgetTester tester, {
  RailTransition transition = RailTransition.crossFade,
}) async {
  tester.view.physicalSize = const Size(800, 100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      home: RailNavigationWidget(
        direction: RailDirection.vertical,
        entries: _entries,
        transition: transition,
        transitionDuration: Duration.zero,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  group('_MoreInlineButton — flyout onTap', () {
    testWidgets(
      'tapping flyout item calls Navigator.pop and cubit.setActive — crossFade',
      (tester) async {
        await _pumpVerticalOverflow(tester);

        expect(find.text('More'), findsOneWidget);
        await tester.tap(find.text('More'));
        await tester.pumpAndSettle();

        expect(find.byType(ListTile), findsWidgets);
        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'tapping flyout item calls resolveDirectional then cubit.setActive — slideDirectional',
      (tester) async {
        await _pumpVerticalOverflow(
          tester,
          transition: RailTransition.slideDirectional,
        );

        expect(find.text('More'), findsOneWidget);
        await tester.tap(find.text('More'));
        await tester.pumpAndSettle();

        expect(find.byType(ListTile), findsWidgets);
        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle();
      },
    );
  });
}
