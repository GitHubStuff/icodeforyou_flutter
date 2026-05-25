// animated_rail_menu/test/src/widget/animated_rail_menu_animated_test.dart

import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Page extends StatelessWidget {
  const _Page({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Center(child: Text(label));
}

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
];

const _animDuration = Duration(milliseconds: 50);

Widget _build(RailTransition transition) => MaterialApp(
  home: AnimatedRailMenu(
    direction: RailDirection.horizontal,
    entries: _entries,
    transition: transition,
    transitionDuration: _animDuration,
  ),
);

Future<void> _tapAndAdvance(WidgetTester tester, String label) async {
  await tester.pump();
  await tester.pump();
  await tester.tap(find.text(label));
  await tester.pump();
  await tester.pump(_animDuration);
  await tester.pump(_animDuration);
}

void main() {
  group('_BodySwitcher — animated branch', () {
    testWidgets('crossFade transition executes', (tester) async {
      await tester.pumpWidget(_build(RailTransition.crossFade));
      await _tapAndAdvance(tester, 'Settings');
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('slideLeft transition executes', (tester) async {
      await tester.pumpWidget(_build(RailTransition.slideLeft));
      await _tapAndAdvance(tester, 'Settings');
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('slideRight transition executes', (tester) async {
      await tester.pumpWidget(_build(RailTransition.slideRight));
      await _tapAndAdvance(tester, 'Settings');
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('slideUp transition executes', (tester) async {
      await tester.pumpWidget(_build(RailTransition.slideUp));
      await _tapAndAdvance(tester, 'Settings');
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('slideDown transition executes', (tester) async {
      await tester.pumpWidget(_build(RailTransition.slideDown));
      await _tapAndAdvance(tester, 'Settings');
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('scale transition executes', (tester) async {
      await tester.pumpWidget(_build(RailTransition.scale));
      await _tapAndAdvance(tester, 'Settings');
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('slideDirectional transition executes', (tester) async {
      await tester.pumpWidget(_build(RailTransition.slideDirectional));
      await _tapAndAdvance(tester, 'Settings');
      expect(find.text('Settings Page'), findsOneWidget);
    });
  });
}
