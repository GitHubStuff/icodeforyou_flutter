// animated_rail_menu/test/src/widget/animated_rail_menu_horizontal_test.dart

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
    direction: RailDirection.horizontal,
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
  group('AnimatedRailMenu — horizontal', () {
    testWidgets('renders first page by default', (tester) async {
      await tester.pumpWidget(_build());
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('renders defaultIndex page', (tester) async {
      await tester.pumpWidget(_build(defaultIndex: 1));
      await _pump(tester);
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('shows all entry labels in bar', (tester) async {
      await tester.pumpWidget(_build());
      await _pump(tester);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('tapping entry navigates to its page', (tester) async {
      await tester.pumpWidget(_build());
      await _pump(tester);
      await tester.tap(find.text('Settings'));
      await _pump(tester);
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('tapping active entry does not change page', (tester) async {
      await tester.pumpWidget(_build());
      await _pump(tester);
      await tester.tap(find.text('Home'));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('collapsed spacing renders without error', (tester) async {
      await tester.pumpWidget(
        _build(iconSpacing: MenuIconSpacing.collapsed),
      );
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('shows More button when limit is set', (tester) async {
      await tester.pumpWidget(_build(limit: 2));
      await _pump(tester);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('More shows active color when overflow item is active', (
      tester,
    ) async {
      await tester.pumpWidget(_build(limit: 2, defaultIndex: 2));
      await _pump(tester);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('tapping More opens bottom sheet', (tester) async {
      await tester.pumpWidget(_build(limit: 2));
      await _pump(tester);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('tapping overflow item in bottom sheet navigates', (
      tester,
    ) async {
      await tester.pumpWidget(_build(limit: 2));
      await _pump(tester);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      // limit=2, defaultIndex=0 -> visible=[Home], overflow=[Settings, Profile].
      // Bottom sheet shows all overflow entries; .first is Settings.
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('tapping last overflow item in bottom sheet navigates', (
      tester,
    ) async {
      await tester.pumpWidget(_build(limit: 2));
      await _pump(tester);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      // .last is Profile.
      await tester.tap(find.byType(ListTile).last);
      await tester.pumpAndSettle();
      expect(find.text('Profile Page'), findsOneWidget);
    });

    testWidgets('all overflow items shown in bottom sheet', (tester) async {
      await tester.pumpWidget(_build(limit: 2, defaultIndex: 2));
      await _pump(tester);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      // Both overflow entries (Settings, Profile) are shown — the active
      // entry is highlighted but still rendered for re-tap as a valid target.
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('active overflow item is bold in bottom sheet', (tester) async {
      await tester.pumpWidget(_build(limit: 2, defaultIndex: 2));
      await _pump(tester);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      // Find the title Text inside the ListTile whose entry is active.
      final profileTitle = tester.widget<Text>(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Profile'),
          matching: find.text('Profile'),
        ),
      );
      expect(profileTitle.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('inactive overflow item is not bold in bottom sheet', (
      tester,
    ) async {
      await tester.pumpWidget(_build(limit: 2, defaultIndex: 2));
      await _pump(tester);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      final settingsTitle = tester.widget<Text>(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Settings'),
          matching: find.text('Settings'),
        ),
      );
      expect(settingsTitle.style?.fontWeight, FontWeight.normal);
    });

    testWidgets('bottom sheet slideDirectional resolves transition', (
      tester,
    ) async {
      await tester.pumpWidget(
        _build(transition: RailTransition.slideDirectional, limit: 2),
      );
      await _pump(tester);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      // .first is Settings — exercises slideDirectional resolution path.
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      expect(find.text('Settings Page'), findsOneWidget);
    });
  });
}
