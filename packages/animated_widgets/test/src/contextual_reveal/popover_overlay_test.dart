// test/src/contextual_reveal/popover_overlay_test.dart

import 'package:animated_widgets/src/contextual_reveal/contextual_reveal.dart';
import 'package:animated_widgets/src/contextual_reveal/src/contextual_position.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({
    AlignmentGeometry alignment = Alignment.topLeft,
    ContextualPosition doublePosition = ContextualPosition.modal,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: alignment,
          child: ContextualReveal(
            body: const Text('body'),
            tapChild: const Text('tap'),
            longChild: const Text('long'),
            doubleChild: const Text('double'),
            doublePosition: doublePosition,
          ),
        ),
      ),
    );
  }

  Future<void> singleTap(WidgetTester tester, Offset at) async {
    await tester.tapAt(at);
    await tester.pump(kDoubleTapTimeout);
  }

  Future<void> doubleTap(WidgetTester tester, Offset at) async {
    await tester.tapAt(at);
    await tester.pump(kDoubleTapMinTime);
    await tester.tapAt(at);
    await tester.pump();
  }

  group('_PopoverOverlay', () {
    testWidgets('tap inserts a non-interactive overlay below a top anchor', (
      tester,
    ) async {
      await tester.pumpWidget(host());
      final center = tester.getCenter(find.text('body'));

      await singleTap(tester, center);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('tap'), findsOneWidget);

      // The show timer elapses, fading out and removing the entry.
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(find.text('tap'), findsNothing);
    });

    testWidgets('a bottom anchor places the overlay in the space above', (
      tester,
    ) async {
      await tester.pumpWidget(host(alignment: Alignment.bottomCenter));
      final center = tester.getCenter(find.text('body'));

      await singleTap(tester, center);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('tap'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();
    });

    testWidgets('double-tap inserts an interactive overlay with a barrier', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(doublePosition: ContextualPosition.popover),
      );
      final center = tester.getCenter(find.text('body'));

      await doubleTap(tester, center);
      await tester.pumpAndSettle();

      expect(find.text('double'), findsOneWidget);

      // Tap the full-screen barrier away from the content to dismiss.
      await tester.tapAt(const Offset(700, 500));
      await tester.pumpAndSettle();

      expect(find.text('double'), findsNothing);
    });
  });
}
