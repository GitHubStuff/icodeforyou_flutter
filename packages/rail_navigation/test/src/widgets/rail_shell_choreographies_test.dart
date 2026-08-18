// packages/rail_navigation/test/src/widgets/rail_shell_choreographies_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_navigation/src/widgets/rail_shell.dart';
import 'package:rail_navigation/src/widgets/rail_widget.dart';

const Duration _kDuration = Duration(milliseconds: 400);

const List<Widget> _screens = [
  Center(child: Text('S0')),
  Center(child: Text('S1')),
  Center(child: Text('S2')),
];

Widget _shell({
  required int currentIndex,
  required RailTransition transition,
  RailPlacement placement = RailPlacement.bottom,
}) {
  return MaterialApp(
    home: RailShell(
      currentIndex: currentIndex,
      placement: placement,
      transition: transition,
      transitionDuration: _kDuration,
      railChildren: const [SizedBox(width: 48, height: 48)],
      screens: _screens,
    ),
  );
}

/// Pumps the shell at index 0, switches to [toIndex], and pumps
/// [fraction] of the transition duration so both layers are live.
Future<void> _switchTo(
  WidgetTester tester, {
  required RailTransition transition,
  RailPlacement placement = RailPlacement.bottom,
  int fromIndex = 0,
  int toIndex = 1,
  double fraction = 0.5,
}) async {
  await tester.pumpWidget(
    _shell(
      currentIndex: fromIndex,
      transition: transition,
      placement: placement,
    ),
  );
  await tester.pumpWidget(
    _shell(
      currentIndex: toIndex,
      transition: transition,
      placement: placement,
    ),
  );
  await tester.pump(_kDuration * fraction);
}

void main() {
  group('RailTransition.none', () {
    testWidgets('switches instantly with no transition frames', (
      tester,
    ) async {
      await _switchTo(tester, transition: RailTransition.none);

      expect(find.text('S1'), findsOneWidget);
      expect(find.text('S0'), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('RailTransition.fadeIn', () {
    testWidgets('hides the outgoing screen and fades the incoming in', (
      tester,
    ) async {
      await _switchTo(tester, transition: RailTransition.fadeIn);

      // Both layers are mounted mid-transition; only the incoming one
      // is interactive.
      expect(find.text('S0', skipOffstage: false), findsOneWidget);
      expect(find.text('S1'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('S1'), findsOneWidget);
      expect(find.text('S0'), findsNothing);
    });
  });

  group('RailTransition.fadeThrough', () {
    testWidgets('fades out before fading in without overlap', (tester) async {
      await _switchTo(
        tester,
        transition: RailTransition.fadeThrough,
        fraction: 0.15,
      );

      // During the outgoing phase the incoming layer is still fully
      // transparent while the outgoing layer is fading.
      expect(find.text('S0'), findsOneWidget);
      expect(find.text('S1'), findsOneWidget);

      await tester.pump(_kDuration * 0.5);
      await tester.pumpAndSettle();
      expect(find.text('S1'), findsOneWidget);
      expect(find.text('S0'), findsNothing);
    });
  });

  group('RailTransition.sharedAxis', () {
    testWidgets('slides horizontally toward a higher index on a bottom rail', (
      tester,
    ) async {
      await _switchTo(tester, transition: RailTransition.sharedAxis);

      // Incoming enters from the trailing (right) side; outgoing exits
      // to the leading (left) side. The content region is horizontally
      // centered on the surface.
      final contentCenter = tester.getCenter(find.byType(ClipRect).first);
      expect(
        tester.getCenter(find.text('S1')).dx,
        greaterThan(contentCenter.dx),
      );
      expect(tester.getCenter(find.text('S0')).dx, lessThan(contentCenter.dx));

      await tester.pumpAndSettle();
      expect(find.text('S1'), findsOneWidget);
      expect(
        tester.getCenter(find.text('S1')).dx,
        moreOrLessEquals(contentCenter.dx),
      );
    });

    testWidgets('slides horizontally toward a lower index on a bottom rail', (
      tester,
    ) async {
      await _switchTo(
        tester,
        transition: RailTransition.sharedAxis,
        fromIndex: 1,
        toIndex: 0,
      );

      final contentCenter = tester.getCenter(find.byType(ClipRect).first);
      expect(tester.getCenter(find.text('S0')).dx, lessThan(contentCenter.dx));
      expect(
        tester.getCenter(find.text('S1')).dx,
        greaterThan(contentCenter.dx),
      );

      await tester.pumpAndSettle();
      expect(find.text('S0'), findsOneWidget);
    });

    testWidgets('slides vertically toward a higher index beside a side rail', (
      tester,
    ) async {
      await _switchTo(
        tester,
        transition: RailTransition.sharedAxis,
        placement: RailPlacement.left,
      );

      final contentCenter = tester.getCenter(find.byType(ClipRect).first);
      expect(
        tester.getCenter(find.text('S1')).dy,
        greaterThan(contentCenter.dy),
      );
      expect(tester.getCenter(find.text('S0')).dy, lessThan(contentCenter.dy));
      expect(
        tester.getCenter(find.text('S1')).dx,
        moreOrLessEquals(contentCenter.dx),
      );

      await tester.pumpAndSettle();
      expect(find.text('S1'), findsOneWidget);
    });

    testWidgets('slides vertically toward a lower index beside a side rail', (
      tester,
    ) async {
      await _switchTo(
        tester,
        transition: RailTransition.sharedAxis,
        placement: RailPlacement.right,
        fromIndex: 1,
        toIndex: 0,
      );

      final contentCenter = tester.getCenter(find.byType(ClipRect).first);
      expect(tester.getCenter(find.text('S0')).dy, lessThan(contentCenter.dy));
      expect(
        tester.getCenter(find.text('S1')).dy,
        greaterThan(contentCenter.dy),
      );

      await tester.pumpAndSettle();
      expect(find.text('S0'), findsOneWidget);
    });
  });
}
