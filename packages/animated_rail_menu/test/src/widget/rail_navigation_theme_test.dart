// test/src/widget/rail_navigation_theme_test.dart

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
];

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

Widget _build({ThemeData? theme, RailIcon icon = RailIcon.phone}) => MaterialApp(
      theme: theme,
      home: RailNavigationWidget(
        direction: RailDirection.horizontal,
        entries: _entries,
        icon: icon,
        transitionDuration: Duration.zero,
      ),
    );

void main() {
  group('RailNavigationWidget — theme', () {
    testWidgets('uses registered RailMenuTheme extension', (tester) async {
      await tester.pumpWidget(
        _build(
          theme: ThemeData.light().copyWith(
            extensions: [RailMenuTheme.light()],
          ),
        ),
      );
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('falls back to dark theme on dark brightness', (tester) async {
      await tester.pumpWidget(_build(theme: ThemeData.dark()));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('falls back to light theme on light brightness',
        (tester) async {
      await tester.pumpWidget(_build(theme: ThemeData.light()));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });
  });

  group('RailNavigationWidget — RailIcon sizes', () {
    testWidgets('smallPhone renders without error', (tester) async {
      await tester.pumpWidget(_build(icon: RailIcon.smallPhone));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('phone renders without error', (tester) async {
      await tester.pumpWidget(_build(icon: RailIcon.phone));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('smallTablet renders without error', (tester) async {
      await tester.pumpWidget(_build(icon: RailIcon.smallTablet));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('tablet renders without error', (tester) async {
      await tester.pumpWidget(_build(icon: RailIcon.tablet));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('largeTablet renders without error', (tester) async {
      await tester.pumpWidget(_build(icon: RailIcon.largeTablet));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('desktop renders without error', (tester) async {
      await tester.pumpWidget(_build(icon: RailIcon.desktop));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('web renders without error', (tester) async {
      await tester.pumpWidget(_build(icon: RailIcon.web));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });
  });
}
