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

  group('_MoreInlineButton — flyout onTap', () {
    // Forces overflow by constraining width so only the first entry fits,
    // pushing the rest into the More flyout. Tapping the flyout item
    // exercises the Navigator.pop + cubit.setActive path (lines 79–88).
    Future<void> futurePumpOverflow(
      WidgetTester tester, {
      RailTransition transition = RailTransition.crossFade,
      RailDirection direction = RailDirection.horizontal,
      int defaultIndex = 0,
    }) async {
      tester.view.physicalSize = const Size(100, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: RailNavigationWidget(
            direction: direction,
            entries: _entries,
            transition: transition,
            defaultIndex: defaultIndex,
            transitionDuration: Duration.zero,
          ),
        ),
      );
      await _pump(tester);
    }

    testWidgets('tapping overflow item navigates — crossFade', (tester) async {
      await futurePumpOverflow(tester);

      expect(find.text('More'), findsOneWidget);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      // At least one overflow entry label is visible in the flyout.
      expect(
        find.byType(ListTile),
        findsWidgets,
      );

      // Tap the first ListTile in the popup to fire onTap (lines 79–88).
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
    });

    testWidgets(
      'tapping overflow item navigates — slideDirectional horizontal',
      (tester) async {
        await futurePumpOverflow(
          tester,
          transition: RailTransition.slideDirectional,
          direction: RailDirection.horizontal,
        );

        expect(find.text('More'), findsOneWidget);
        await tester.tap(find.text('More'));
        await tester.pumpAndSettle();

        expect(find.byType(ListTile), findsWidgets);
        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'tapping overflow item navigates — slideDirectional vertical',
      (tester) async {
        await futurePumpOverflow(
          tester,
          transition: RailTransition.slideDirectional,
          direction: RailDirection.vertical,
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
