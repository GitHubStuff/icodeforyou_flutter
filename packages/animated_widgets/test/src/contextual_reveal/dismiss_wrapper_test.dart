// test/src/contextual_reveal/dismiss_wrapper_test.dart

import 'package:animated_widgets/src/contextual_reveal/contextual_reveal.dart';
import 'package:animated_widgets/src/contextual_reveal/src/contextual_position.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(ContextualPosition position) {
    return MaterialApp(
      home: Scaffold(
        body: ContextualReveal(
          body: const Text('body'),
          tapChild: const Text('tap'),
          longChild: const Text('long'),
          doubleChild: const Text('double'),
          doublePosition: position,
        ),
      ),
    );
  }

  Future<void> doubleTap(WidgetTester tester, Offset at) async {
    await tester.tapAt(at);
    await tester.pump(kDoubleTapMinTime);
    await tester.tapAt(at);
    await tester.pump();
  }

  group('_DismissWrapper', () {
    testWidgets('renders a close button alongside the child in a popover', (
      tester,
    ) async {
      await tester.pumpWidget(host(ContextualPosition.popover));
      final center = tester.getCenter(find.text('body'));

      await doubleTap(tester, center);
      await tester.pumpAndSettle();

      // build + Column children: the wrapped child and the close affordance.
      expect(find.text('double'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // onTap: onDismiss fires and tears the popover down.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('double'), findsNothing);
    });

    testWidgets('its close button dismisses a bottom sheet', (tester) async {
      await tester.pumpWidget(host(ContextualPosition.bottomSheet));
      final center = tester.getCenter(find.text('body'));

      await doubleTap(tester, center);
      await tester.pumpAndSettle();

      expect(find.text('double'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('double'), findsNothing);
    });
  });
}
