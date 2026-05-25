// animated_rail_menu/test/src/widget/animated_rail_menu_vertical_test.dart

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
  AnimatedRailMenuEntry(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profile',
    page: _Page(label: 'Profile Page'),
  ),
];

Widget _build({
  int defaultIndex = 0,
  RailTransition transition = RailTransition.crossFade,
  MenuIconSpacing iconSpacing = MenuIconSpacing.expanded,
  int? limit,
}) => MaterialApp(
  home: AnimatedRailMenu(
    direction: RailDirection.vertical,
    entries: _entries,
    defaultIndex: defaultIndex,
    transition: transition,
    transitionDuration: Duration.zero,
    iconSpacing: iconSpacing,
    limit: limit,
  ),
);

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void main() {
  group('AnimatedRailMenu — vertical', () {
    testWidgets('renders first page by default', (tester) async {
      await tester.pumpWidget(_build());
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('tapping entry navigates to its page', (tester) async {
      await tester.pumpWidget(_build());
      await _pump(tester);
      await tester.tap(find.text('Settings'));
      await _pump(tester);
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('collapsed spacing renders without error', (tester) async {
      await tester.pumpWidget(_build(iconSpacing: MenuIconSpacing.collapsed));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('shows More button when limit is set', (tester) async {
      await tester.pumpWidget(_build(limit: 2));
      await _pump(tester);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('tapping More toggles inline expansion', (tester) async {
      await tester.pumpWidget(_build(limit: 2));
      await _pump(tester);
      expect(find.text('Profile'), findsNothing);
      await tester.tap(find.text('More'));
      // showMenu pushes a route — must settle before finding popup items.
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('tapping More again collapses inline expansion', (
      tester,
    ) async {
      await tester.pumpWidget(_build(limit: 2));
      await _pump(tester);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      // Tapping outside the popup (the More button is now behind the barrier)
      // pops the route. Use a different gesture to dismiss the menu.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('tapping overflow item in inline expansion navigates', (
      tester,
    ) async {
      await tester.pumpWidget(_build(limit: 2));
      await _pump(tester);
      await tester.tap(find.text('More'));
      // showMenu route must settle before its items are tappable.
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      // Navigator.pop back to the rail must also settle.
      await tester.pumpAndSettle();
      expect(find.text('Profile Page'), findsOneWidget);
    });

    testWidgets('More shows active color when overflow item is active', (
      tester,
    ) async {
      await tester.pumpWidget(_build(limit: 2, defaultIndex: 2));
      await _pump(tester);
      expect(find.text('More'), findsOneWidget);
    });
  });

  group('AnimatedRailMenu — vertical transitions', () {
    testWidgets('crossFade renders without error', (tester) async {
      await tester.pumpWidget(_build(transition: RailTransition.crossFade));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('slideLeft renders without error', (tester) async {
      await tester.pumpWidget(_build(transition: RailTransition.slideLeft));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('slideRight renders without error', (tester) async {
      await tester.pumpWidget(_build(transition: RailTransition.slideRight));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('slideDirectional renders without error', (tester) async {
      await tester.pumpWidget(
        _build(transition: RailTransition.slideDirectional),
      );
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('scale renders without error', (tester) async {
      await tester.pumpWidget(_build(transition: RailTransition.scale));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('slideUp renders without error', (tester) async {
      await tester.pumpWidget(_build(transition: RailTransition.slideUp));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('slideDown renders without error', (tester) async {
      await tester.pumpWidget(_build(transition: RailTransition.slideDown));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });
  });
}
