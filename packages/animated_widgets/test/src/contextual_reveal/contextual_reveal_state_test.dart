// animated_widgets/test/src/contextual_reveal/contextual_reveal_state_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// GestureDetector waits kDoubleTapTimeout (300ms) before firing onTap when
// onDoubleTap is also registered. All single-tap pumps must clear that window.
const _doubleTapTimeoutPlus = Duration(milliseconds: 350);

// Default theme durations: fadeIn=200ms, fadeOut=250ms, show=750ms.
const _afterFadeIn = Duration(milliseconds: 250);
const _afterShowAndFadeOut = Duration(milliseconds: 1100);

Widget _harness({
  required Widget tapChild,
  required Widget longChild,
  required Widget doubleChild,
  ContextualPosition doublePosition = ContextualPosition.modal,
  ContextualRevealTheme? theme,
  Widget body = const SizedBox(width: 200, height: 200, child: Text('body')),
  Alignment alignment = Alignment.center,
}) {
  return MaterialApp(
    theme: theme == null
        ? null
        : ThemeData.light().copyWith(extensions: [theme]),
    home: Scaffold(
      body: Align(
        alignment: alignment,
        child: ContextualReveal(
          body: body,
          tapChild: tapChild,
          longChild: longChild,
          doubleChild: doubleChild,
          doublePosition: doublePosition,
        ),
      ),
    ),
  );
}

Future<void> _singleTapAndWait(WidgetTester tester, Finder anchor) async {
  await tester.tap(anchor);
  // Wait past kDoubleTapTimeout so onTap fires.
  await tester.pump(_doubleTapTimeoutPlus);
  // Then pump through the fade-in animation.
  await tester.pump(_afterFadeIn);
  // Post-frame markNeedsBuild for content rect.
  await tester.pump();
}

Future<void> _drainAutoDismiss(WidgetTester tester) async {
  await tester.pump(_afterShowAndFadeOut);
  await tester.pumpAndSettle();
}

void main() {
  group('ContextualReveal — initial render', () {
    testWidgets('renders body before any gesture', (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
        ),
      );
      expect(find.text('body'), findsOneWidget);
      expect(find.text('TAP'), findsNothing);
      expect(find.text('LONG'), findsNothing);
      expect(find.text('DOUBLE'), findsNothing);
    });
  });

  group('ContextualReveal — tap gesture', () {
    testWidgets('tap inserts non-interactive popover with tapChild',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
        ),
      );

      await _singleTapAndWait(tester, find.text('body'));
      expect(find.text('TAP'), findsOneWidget);

      await _drainAutoDismiss(tester);
    });

    testWidgets('tap auto-dismisses after showDuration + fadeOut',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
        ),
      );

      await _singleTapAndWait(tester, find.text('body'));
      expect(find.text('TAP'), findsOneWidget);

      await _drainAutoDismiss(tester);
      expect(find.text('TAP'), findsNothing);
    });

    testWidgets('second tap while popover visible is ignored',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
        ),
      );

      await _singleTapAndWait(tester, find.text('body'));
      expect(find.text('TAP'), findsOneWidget);

      // Tap again while visible — _onTap early-return at isVisible check.
      // warnIfMissed because the body may be partially obscured by popover.
      await tester.tap(find.text('body'), warnIfMissed: false);
      await tester.pump(_doubleTapTimeoutPlus);
      await tester.pump(_afterFadeIn);
      // Still visible from the first tap — early-return is silent.
      expect(find.text('TAP'), findsOneWidget);

      await _drainAutoDismiss(tester);
    });
  });

  group('ContextualReveal — long press gesture', () {
    testWidgets('long press inserts popover with longChild then dismisses',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('body')),
      );
      // kLongPressTimeout is 500ms.
      await tester.pump(const Duration(milliseconds: 600));
      // Fade in.
      await tester.pump(_afterFadeIn);
      await tester.pump();
      expect(find.text('LONG'), findsOneWidget);

      await gesture.up();
      // onLongPressEnd → _fadeOut.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('LONG'), findsNothing);
    });
  });

  group('ContextualReveal — double tap × ContextualPosition.popover', () {
    testWidgets('shows interactive popover with dismiss icon', (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
          doublePosition: ContextualPosition.popover,
        ),
      );

      await tester.tap(find.text('body'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('body'));
      await tester.pump();
      await tester.pump(_afterFadeIn);
      await tester.pump();

      expect(find.text('DOUBLE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('tapping close icon dismisses interactive popover',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
          doublePosition: ContextualPosition.popover,
        ),
      );

      await tester.tap(find.text('body'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('body'));
      await tester.pump();
      await tester.pump(_afterFadeIn);
      await tester.pump();
      expect(find.text('DOUBLE'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('DOUBLE'), findsNothing);
    });

    testWidgets('tapping dismiss region behind popover dismisses it',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
          doublePosition: ContextualPosition.popover,
        ),
      );

      await tester.tap(find.text('body'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('body'));
      await tester.pump();
      await tester.pump(_afterFadeIn);
      await tester.pump();
      expect(find.text('DOUBLE'), findsOneWidget);

      // Tap top-left corner — far from popover content, hits dismiss region.
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('DOUBLE'), findsNothing);
    });
  });

  group('ContextualReveal — double tap × ContextualPosition.modal', () {
    testWidgets('shows modal dialog with dismiss icon and doubleChild',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
        ),
      );

      await tester.tap(find.text('body'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('body'));
      await tester.pumpAndSettle();

      expect(find.text('DOUBLE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('tapping close icon pops modal', (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
        ),
      );

      await tester.tap(find.text('body'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('body'));
      await tester.pumpAndSettle();
      expect(find.text('DOUBLE'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('DOUBLE'), findsNothing);
    });
  });

  group('ContextualReveal — double tap × ContextualPosition.bottomSheet', () {
    testWidgets('shows bottom sheet with dismiss icon and doubleChild',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
          doublePosition: ContextualPosition.bottomSheet,
        ),
      );

      await tester.tap(find.text('body'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('body'));
      await tester.pumpAndSettle();

      expect(find.text('DOUBLE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('tapping close icon dismisses bottom sheet', (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
          doublePosition: ContextualPosition.bottomSheet,
        ),
      );

      await tester.tap(find.text('body'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('body'));
      await tester.pumpAndSettle();
      expect(find.text('DOUBLE'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('DOUBLE'), findsNothing);
    });
  });

  group('ContextualReveal — double tap × ContextualPosition.push', () {
    testWidgets('pushes new route showing doubleChild with default BackButton',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
          doublePosition: ContextualPosition.push,
        ),
      );

      await tester.tap(find.text('body'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('body'));
      await tester.pumpAndSettle();

      expect(find.text('DOUBLE'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('uses theme.backButton when provided', (tester) async {
      final customTheme = const ContextualRevealLight().copyWith(
        backButton: const Icon(Icons.arrow_back_ios, key: Key('custom_back')),
      );

      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
          doublePosition: ContextualPosition.push,
          theme: customTheme,
        ),
      );

      await tester.tap(find.text('body'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('body'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom_back')), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('back button pops the pushed route', (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
          doublePosition: ContextualPosition.push,
        ),
      );

      await tester.tap(find.text('body'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('body'));
      await tester.pumpAndSettle();
      expect(find.text('DOUBLE'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('DOUBLE'), findsNothing);
      expect(find.text('body'), findsOneWidget);
    });
  });

  group('ContextualReveal — popover positioning', () {
    testWidgets('popover renders below anchor when no space above',
        (tester) async {
      // Anchor near top of screen — popover must render below.
      await tester.pumpWidget(
        _harness(
          tapChild: const SizedBox(
            width: 100,
            height: 80,
            child: Text('TAP'),
          ),
          longChild: const Text('L'),
          doubleChild: const Text('D'),
          body: const SizedBox(width: 100, height: 50, child: Text('body')),
          alignment: Alignment.topCenter,
        ),
      );

      await _singleTapAndWait(tester, find.text('body'));
      expect(find.text('TAP'), findsOneWidget);

      final anchorBottom = tester.getBottomLeft(find.text('body')).dy;
      final popoverTop = tester.getTopLeft(find.text('TAP')).dy;
      expect(popoverTop, greaterThanOrEqualTo(anchorBottom));

      await _drainAutoDismiss(tester);
    });

    testWidgets('popover renders above anchor when space allows',
        (tester) async {
      // Anchor near bottom — popover should render above.
      await tester.pumpWidget(
        _harness(
          tapChild: const SizedBox(
            width: 100,
            height: 80,
            child: Text('TAP'),
          ),
          longChild: const Text('L'),
          doubleChild: const Text('D'),
          body: const SizedBox(width: 100, height: 50, child: Text('body')),
          alignment: Alignment.bottomCenter,
        ),
      );

      await _singleTapAndWait(tester, find.text('body'));
      expect(find.text('TAP'), findsOneWidget);

      final anchorTop = tester.getTopLeft(find.text('body')).dy;
      final popoverBottom = tester.getBottomLeft(find.text('TAP')).dy;
      expect(popoverBottom, lessThanOrEqualTo(anchorTop));

      await _drainAutoDismiss(tester);
    });
  });

  group('ContextualReveal — dispose', () {
    testWidgets('removes widget from tree without exception', (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
        ),
      );
      expect(find.text('body'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('replaced'))),
      );
      expect(find.text('replaced'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes cleanly while popover visible', (tester) async {
      await tester.pumpWidget(
        _harness(
          tapChild: const Text('TAP'),
          longChild: const Text('LONG'),
          doubleChild: const Text('DOUBLE'),
        ),
      );

      await _singleTapAndWait(tester, find.text('body'));
      expect(find.text('TAP'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('replaced'))),
      );
      // Drain pending timer scheduled by _onTap.
      await tester.pump(_afterShowAndFadeOut);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
