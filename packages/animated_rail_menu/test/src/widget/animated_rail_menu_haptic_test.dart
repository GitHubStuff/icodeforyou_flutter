// animated_rail_menu/test/src/widget/animated_rail_menu_haptic_test.dart

import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

Widget _buildWith(HapticIntensity haptic) => MaterialApp(
  home: AnimatedRailMenu(
    direction: RailDirection.horizontal,
    entries: _entries,
    haptic: haptic,
    transitionDuration: Duration.zero,
  ),
);

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => null,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('HapticIntensity.none does not throw', (tester) async {
    await tester.pumpWidget(_buildWith(HapticIntensity.none));
    await _pump(tester);
    await tester.tap(find.text('Settings'));
    await _pump(tester);
    expect(find.text('Settings Page'), findsOneWidget);
  });

  testWidgets('HapticIntensity.light does not throw', (tester) async {
    await tester.pumpWidget(_buildWith(HapticIntensity.light));
    await _pump(tester);
    await tester.tap(find.text('Settings'));
    await _pump(tester);
    expect(find.text('Settings Page'), findsOneWidget);
  });

  testWidgets('HapticIntensity.medium does not throw', (tester) async {
    await tester.pumpWidget(_buildWith(HapticIntensity.medium));
    await _pump(tester);
    await tester.tap(find.text('Settings'));
    await _pump(tester);
    expect(find.text('Settings Page'), findsOneWidget);
  });

  testWidgets('HapticIntensity.heavy does not throw', (tester) async {
    await tester.pumpWidget(_buildWith(HapticIntensity.heavy));
    await _pump(tester);
    await tester.tap(find.text('Settings'));
    await _pump(tester);
    expect(find.text('Settings Page'), findsOneWidget);
  });
}
