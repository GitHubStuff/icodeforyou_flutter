// packages/rail_navigation/test/src/widgets/rail_shell_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_navigation/src/widgets/rail_shell.dart';
import 'package:rail_navigation/src/widgets/rail_widget.dart';

const List<Widget> _screens = [
  ColoredBox(color: Colors.red, child: Center(child: Text('S0'))),
  ColoredBox(color: Colors.green, child: Center(child: Text('S1'))),
];

Widget _shell({
  int currentIndex = 0,
  RailPlacement placement = RailPlacement.bottom,
  RailTransition transition = RailTransition.fadeThrough,
  Duration transitionDuration = const Duration(milliseconds: 750),
  MainAxisAlignment? railAlignment,
  double railSpacing = 8,
  Color? railBackgroundColor,
  double railExtent = 80,
}) {
  return MaterialApp(
    home: RailShell(
      currentIndex: currentIndex,
      placement: placement,
      transition: transition,
      transitionDuration: transitionDuration,
      railAlignment: railAlignment,
      railSpacing: railSpacing,
      railBackgroundColor: railBackgroundColor,
      railExtent: railExtent,
      railChildren: const [SizedBox(width: 48, height: 48)],
      screens: _screens,
    ),
  );
}

void main() {
  group('RailShell', () {
    test('asserts when currentIndex does not index into screens', () {
      expect(
        () => RailShell(
          currentIndex: 2,
          railChildren: const [],
          screens: _screens,
        ),
        throwsAssertionError,
      );
      expect(
        () => RailShell(
          currentIndex: -1,
          railChildren: const [],
          screens: _screens,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('shows the screen at currentIndex', (tester) async {
      await tester.pumpWidget(_shell());

      expect(find.text('S0'), findsOneWidget);
      expect(find.text('S1', skipOffstage: false), findsOneWidget);
      expect(find.text('S1'), findsNothing);
    });

    testWidgets('bottom placement mounts the rail as a bottom bar', (
      tester,
    ) async {
      await tester.pumpWidget(_shell());

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isA<RailWidget>());

      final railRect = tester.getRect(find.byType(RailWidget));
      final screenRect = tester.getRect(find.text('S0'));
      expect(railRect.top, greaterThan(screenRect.bottom));
    });

    testWidgets('left placement mounts the rail beside the content', (
      tester,
    ) async {
      await tester.pumpWidget(_shell(placement: RailPlacement.left));

      expect(find.byType(Scaffold), findsNothing);
      final railRect = tester.getRect(find.byType(RailWidget));
      final screenRect = tester.getRect(find.text('S0'));
      expect(railRect.right, lessThanOrEqualTo(screenRect.left));
    });

    testWidgets('right placement mounts the rail beside the content', (
      tester,
    ) async {
      await tester.pumpWidget(_shell(placement: RailPlacement.right));

      expect(find.byType(Scaffold), findsNothing);
      final railRect = tester.getRect(find.byType(RailWidget));
      final screenRect = tester.getRect(find.text('S0'));
      expect(railRect.left, greaterThanOrEqualTo(screenRect.right));
    });

    testWidgets('left placement strips the left inset from the content', (
      tester,
    ) async {
      tester.view.padding = const FakeViewPadding(left: 90);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_shell(placement: RailPlacement.left));

      final contentContext = tester.element(find.text('S0'));
      expect(MediaQuery.paddingOf(contentContext).left, 0);
    });

    testWidgets('right placement strips the right inset from the content', (
      tester,
    ) async {
      tester.view.padding = const FakeViewPadding(right: 90);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_shell(placement: RailPlacement.right));

      final contentContext = tester.element(find.text('S0'));
      expect(MediaQuery.paddingOf(contentContext).right, 0);
    });

    testWidgets('forwards rail parameters to RailWidget', (tester) async {
      await tester.pumpWidget(
        _shell(
          railAlignment: MainAxisAlignment.center,
          railSpacing: 16,
          railBackgroundColor: Colors.amber,
          railExtent: 64,
        ),
      );

      final rail = tester.widget<RailWidget>(find.byType(RailWidget));
      expect(rail.alignment, MainAxisAlignment.center);
      expect(rail.spacing, 16);
      expect(rail.backgroundColor, Colors.amber);
      expect(rail.extent, 64);
      expect(rail.placement, RailPlacement.bottom);
    });

    testWidgets('switches screens when rebuilt with a new currentIndex', (
      tester,
    ) async {
      await tester.pumpWidget(_shell());
      expect(find.text('S0'), findsOneWidget);

      await tester.pumpWidget(_shell(currentIndex: 1));
      await tester.pumpAndSettle();

      expect(find.text('S1'), findsOneWidget);
      expect(find.text('S0'), findsNothing);
      expect(find.text('S0', skipOffstage: false), findsOneWidget);
    });
  });
}
