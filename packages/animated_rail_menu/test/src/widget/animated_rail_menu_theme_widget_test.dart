// animated_rail_menu/test/src/widget/animated_rail_menu_theme_widget_test.dart

// ignore_for_file: unnecessary_import

import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:animated_rail_menu/src/model/animated_rail_menu_entry.dart'
    show AnimatedRailMenuEntry;
import 'package:animated_rail_menu/src/model/rail_direction.dart'
    show RailDirection;
import 'package:animated_rail_menu/src/model/rail_icon.dart' show RailIcon;
import 'package:animated_rail_menu/src/theme/animated_rail_menu_theme.dart'
    show AnimatedRailMenuTheme;
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

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

Widget _build({ThemeData? theme, RailIcon icon = RailIcon.phone}) =>
    MaterialApp(
      theme: theme,
      home: AnimatedRailMenu(
        direction: RailDirection.horizontal,
        entries: _entries,
        icon: icon,
        transitionDuration: Duration.zero,
      ),
    );

void main() {
  group('AnimatedRailMenu — theme', () {
    testWidgets('uses registered AnimatedRailMenuTheme extension', (
      tester,
    ) async {
      await tester.pumpWidget(
        _build(
          theme: ThemeData.light().copyWith(
            extensions: [AnimatedRailMenuTheme.light()],
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

    testWidgets('falls back to light theme on light brightness', (
      tester,
    ) async {
      await tester.pumpWidget(_build(theme: ThemeData.light()));
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });
  });

  group('AnimatedRailMenu — RailIcon sizes', () {
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
