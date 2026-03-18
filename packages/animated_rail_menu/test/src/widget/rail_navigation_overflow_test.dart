// test/src/widget/rail_navigation_overflow_test.dart

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

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void main() {
  group('RailNavigationWidget — pixel overflow', () {
    testWidgets('shows More when items exceed available width', (tester) async {
      tester.view.physicalSize = const Size(100, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: RailNavigationWidget(
            direction: RailDirection.horizontal,
            entries: _entries,
            transitionDuration: Duration.zero,
          ),
        ),
      );
      await _pump(tester);
      expect(find.text('More'), findsOneWidget);
    });
  });

  group('RailNavigationWidget — slideDirectional horizontal', () {
    testWidgets('forward tap navigates correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RailNavigationWidget(
            direction: RailDirection.horizontal,
            entries: _entries,
            transition: RailTransition.slideDirectional,
            transitionDuration: Duration.zero,
          ),
        ),
      );
      await _pump(tester);
      await tester.tap(find.text('Settings'));
      await _pump(tester);
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('backward tap navigates correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RailNavigationWidget(
            direction: RailDirection.horizontal,
            entries: _entries,
            defaultIndex: 1,
            transition: RailTransition.slideDirectional,
            transitionDuration: Duration.zero,
          ),
        ),
      );
      await _pump(tester);
      await tester.tap(find.text('Home'));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });
  });

  group('RailNavigationWidget — slideDirectional vertical', () {
    testWidgets('forward tap navigates correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RailNavigationWidget(
            direction: RailDirection.vertical,
            entries: _entries,
            transition: RailTransition.slideDirectional,
            transitionDuration: Duration.zero,
          ),
        ),
      );
      await _pump(tester);
      await tester.tap(find.text('Settings'));
      await _pump(tester);
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('backward tap navigates correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RailNavigationWidget(
            direction: RailDirection.vertical,
            entries: _entries,
            defaultIndex: 1,
            transition: RailTransition.slideDirectional,
            transitionDuration: Duration.zero,
          ),
        ),
      );
      await _pump(tester);
      await tester.tap(find.text('Home'));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });
  });
}
