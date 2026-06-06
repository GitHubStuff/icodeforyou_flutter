// test/src/contextual_reveal/contextual_reveal_state_test.dart

import 'package:animated_widgets/src/contextual_reveal/contextual_reveal.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  Widget reveal({
    ContextualPosition doublePosition = ContextualPosition.modal,
  }) {
    return ContextualReveal(
      body: const Text('body'),
      tapChild: const Text('tap'),
      longChild: const Text('long'),
      doubleChild: const Text('double'),
      doublePosition: doublePosition,
    );
  }

  Future<void> singleTap(WidgetTester tester, Offset at) async {
    await tester.tapAt(at);
    // Let the tap win the arena against the double-tap recognizer.
    await tester.pump(kDoubleTapTimeout);
  }

  Future<void> doubleTap(WidgetTester tester, Offset at) async {
    await tester.tapAt(at);
    await tester.pump(kDoubleTapMinTime);
    await tester.tapAt(at);
    await tester.pump();
  }

  group('ContextualReveal gestures', () {
    testWidgets('mounts and shows the body', (tester) async {
      await tester.pumpWidget(host(reveal()));

      expect(find.text('body'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('tap reveals the tap child and the timer dismisses it', (
      tester,
    ) async {
      await tester.pumpWidget(host(reveal()));
      final center = tester.getCenter(find.text('body'));

      await singleTap(tester, center);
      await tester.pump(const Duration(milliseconds: 300)); // finish fade-in

      expect(find.text('tap'), findsOneWidget);

      // Past the 750ms show window: timer fires -> fade-out -> remove.
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(find.text('tap'), findsNothing);
    });

    testWidgets('a second tap is ignored while the popover is visible', (
      tester,
    ) async {
      await tester.pumpWidget(host(reveal()));
      final center = tester.getCenter(find.text('body'));

      await singleTap(tester, center);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('tap'), findsOneWidget);

      await singleTap(tester, center); // isVisible -> early return
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('tap'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();
    });

    testWidgets('long press reveals; release dismisses', (tester) async {
      await tester.pumpWidget(host(reveal()));
      final center = tester.getCenter(find.text('body'));

      final gesture = await tester.startGesture(center);
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 250)); // fade-in
      expect(find.text('long'), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('long'), findsNothing);
    });

    testWidgets('double-tap popover dismisses via barrier and close button', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(reveal(doublePosition: ContextualPosition.popover)),
      );
      final center = tester.getCenter(find.text('body'));

      // Cycle one: dismiss by tapping the interactive barrier region.
      await doubleTap(tester, center);
      await tester.pumpAndSettle();
      expect(find.text('double'), findsOneWidget);

      await tester.tapAt(const Offset(700, 500));
      await tester.pumpAndSettle();
      expect(find.text('double'), findsNothing);

      // Cycle two: dismiss by tapping the close button in the wrapper.
      await doubleTap(tester, center);
      await tester.pumpAndSettle();
      expect(find.text('double'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('double'), findsNothing);
    });

    testWidgets('double-tap modal shows a dialog and closes it', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(reveal(doublePosition: ContextualPosition.modal)),
      );
      final center = tester.getCenter(find.text('body'));

      await doubleTap(tester, center);
      await tester.pumpAndSettle();
      expect(find.text('double'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('double'), findsNothing);
    });

    testWidgets('double-tap bottom sheet shows a sheet and closes it', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(reveal(doublePosition: ContextualPosition.bottomSheet)),
      );
      final center = tester.getCenter(find.text('body'));

      await doubleTap(tester, center);
      await tester.pumpAndSettle();
      expect(find.text('double'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('double'), findsNothing);
    });

    testWidgets('double-tap push navigates to a new route', (tester) async {
      await tester.pumpWidget(
        host(reveal(doublePosition: ContextualPosition.push)),
      );
      final center = tester.getCenter(find.text('body'));

      await doubleTap(tester, center);
      await tester.pumpAndSettle();

      expect(find.text('double'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
    });

    testWidgets('dispose cancels a pending tap timer', (tester) async {
      await tester.pumpWidget(host(reveal()));
      final center = tester.getCenter(find.text('body'));

      await singleTap(tester, center); // schedules the show timer
      await tester.pumpWidget(const SizedBox()); // dispose mid-flight

      expect(tester.takeException(), isNull);
    });
  });
}
