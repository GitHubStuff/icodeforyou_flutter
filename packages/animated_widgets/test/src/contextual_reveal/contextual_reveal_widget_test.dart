// animated_widgets/test/src/contextual_reveal/contextual_reveal_widget_test.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContextualReveal — primary constructor', () {
    test('exposes body, tapChild, longChild, doubleChild, doublePosition', () {
      const body = SizedBox(key: Key('body'));
      const tap = SizedBox(key: Key('tap'));
      const long = SizedBox(key: Key('long'));
      const dbl = SizedBox(key: Key('dbl'));
      const widget = ContextualReveal(
        body: body,
        tapChild: tap,
        longChild: long,
        doubleChild: dbl,
        doublePosition: ContextualPosition.bottomSheet,
      );
      expect(widget.body, body);
      expect(widget.tapChild, tap);
      expect(widget.longChild, long);
      expect(widget.doubleChild, dbl);
      expect(widget.doublePosition, ContextualPosition.bottomSheet);
    });

    test('doublePosition defaults to modal', () {
      const widget = ContextualReveal(
        body: SizedBox(),
        tapChild: SizedBox(),
        longChild: SizedBox(),
        doubleChild: SizedBox(),
      );
      expect(widget.doublePosition, ContextualPosition.modal);
    });

    testWidgets('createState returns a State<ContextualReveal>',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ContextualReveal(
            body: Text('body'),
            tapChild: Text('tap'),
            longChild: Text('long'),
            doubleChild: Text('dbl'),
          ),
        ),
      );
      expect(find.text('body'), findsOneWidget);
    });
  });

  group('ContextualReveal.simple — factory', () {
    test('shares the same widget instance across all three children', () {
      const shared = SizedBox(key: Key('shared'));
      final widget = ContextualReveal.simple(
        body: const SizedBox(key: Key('body')),
        sharedChild: shared,
      );
      expect(widget.tapChild, shared);
      expect(widget.longChild, shared);
      expect(widget.doubleChild, shared);
    });

    test('uses ContextualPosition.modal', () {
      final widget = ContextualReveal.simple(
        body: const SizedBox(),
        sharedChild: const SizedBox(),
      );
      expect(widget.doublePosition, ContextualPosition.modal);
    });

    test('forwards key', () {
      const key = Key('factory_key');
      final widget = ContextualReveal.simple(
        body: const SizedBox(),
        sharedChild: const SizedBox(),
        key: key,
      );
      expect(widget.key, key);
    });
  });
}
