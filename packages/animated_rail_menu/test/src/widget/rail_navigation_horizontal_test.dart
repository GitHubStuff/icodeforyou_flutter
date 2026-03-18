// test/src/widget/rail_navigation_horizontal_test.dart

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

Widget _build({
  int defaultIndex = 0,
  RailTransition transition = RailTransition.crossFade,
  MenuIconSpacing iconSpacing = MenuIconSpacing.expanded,
  int? limit,
}) =>
    MaterialApp(
      home: RailNavigationWidget(
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
  group('RailNavigationWidget — horizontal', () {
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

    testWidgets('More shows active color when overflow item is active',
        (tester) async {
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

    testWidgets('tapping overflow item in bottom sheet navigates',
        (tester) async {
      await tester.pumpWidget(_build(limit: 2));
      await _pump(tester);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      expect(find.text('Profile Page'), findsOneWidget);
    });

    testWidgets('active overflow item shown in bottom sheet', (tester) async {
      await tester.pumpWidget(_build(limit: 2, defaultIndex: 2));
      await _pump(tester);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('bottom sheet slideDirectional resolves transition',
        (tester) async {
      await tester.pumpWidget(
        _build(transition: RailTransition.slideDirectional, limit: 2),
      );
      await _pump(tester);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      expect(find.text('Profile Page'), findsOneWidget);
    });
  });
}
