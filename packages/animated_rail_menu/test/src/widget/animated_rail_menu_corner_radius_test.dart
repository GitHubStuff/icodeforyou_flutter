// animated_rail_menu/test/src/widget/animated_rail_menu_corner_radius_test.dart
//
// Regression test for corner radius clipping on devices with large display
// corners (iPhone 17 Pro and comparable). The _ElevatorRail applies a minimum
// top padding of _kElevatorTopMinimum (32dp) via SafeArea.minimum to ensure
// the top-most icon is never clipped by the screen corner.

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

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

/// Simulates iPhone 17 Pro landscape — top safe area is 0, corner clips ~32dp.
void _setIPhone17Landscape(WidgetTester tester) {
  tester.view.physicalSize = const Size(844, 390);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(
    top: 0,
    bottom: 21,
    left: 47,
    right: 47,
  );
}

/// Simulates iPhone 17 Pro portrait — top safe area handles the notch.
void _setIPhone17Portrait(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(
    top: 59,
    bottom: 34,
    left: 0,
    right: 0,
  );
}

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
  });

  group('_ElevatorRail — corner radius minimum top padding', () {
    testWidgets(
      'first entry top offset >= 32dp in landscape with zero top safe area',
      (tester) async {
        _setIPhone17Landscape(tester);
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

        // The first entry label 'Home' must be at least 32dp from the top.
        final homeFinder = find.text('Home');
        expect(homeFinder, findsOneWidget);
        final offset = tester.getTopLeft(homeFinder);
        expect(offset.dy, greaterThanOrEqualTo(32.0));
      },
    );

    testWidgets(
      'no rendering exception in landscape with zero top safe area',
      (tester) async {
        _setIPhone17Landscape(tester);
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
      'portrait — top safe area inset takes precedence over minimum',
      (tester) async {
        _setIPhone17Portrait(tester);
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

        // Portrait top safe area is 59dp — larger than minimum 32dp.
        // First entry must be at least 59dp from the top.
        final homeFinder = find.text('Home');
        expect(homeFinder, findsOneWidget);
        final offset = tester.getTopLeft(homeFinder);
        expect(offset.dy, greaterThanOrEqualTo(59.0));
      },
    );

    testWidgets(
      'adaptive landscape — vertical rail applies minimum top padding',
      (tester) async {
        _setIPhone17Landscape(tester);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetPadding();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: AnimatedRailMenu(
              direction: RailDirection.adaptive,
              entries: _entries,
              transitionDuration: Duration.zero,
            ),
          ),
        );
        await _pump(tester);

        final homeFinder = find.text('Home');
        expect(homeFinder, findsOneWidget);
        final offset = tester.getTopLeft(homeFinder);
        expect(offset.dy, greaterThanOrEqualTo(32.0));
        expect(tester.takeException(), isNull);
      },
    );
  });
}
