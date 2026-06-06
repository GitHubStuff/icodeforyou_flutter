// test/src/contextual_reveal/contextual_reveal_test.dart

import 'package:animated_widgets/src/contextual_reveal/contextual_reveal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('ContextualReveal', () {
    testWidgets('default constructor mounts its state and shows the body', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const ContextualReveal(
            body: Text('body'),
            tapChild: Text('tap'),
            longChild: Text('long'),
            doubleChild: Text('double'),
          ),
        ),
      );

      expect(find.text('body'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('simple factory shares one child across gestures', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          ContextualReveal.simple(
            body: const Text('body'),
            sharedChild: const Text('shared'),
          ),
        ),
      );

      expect(find.text('body'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
