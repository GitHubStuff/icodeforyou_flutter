// test/src/contextual_reveal/push_route_test.dart

import 'package:animated_widgets/src/contextual_reveal/contextual_reveal.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host() {
    return const MaterialApp(
      home: Scaffold(
        body: ContextualReveal(
          body: Text('body'),
          tapChild: Text('tap'),
          longChild: Text('long'),
          doubleChild: Text('double'),
          doublePosition: ContextualPosition.push,
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

  group('_PushRoute', () {
    testWidgets('double-tap pushes a route with a back button and the child', (
      tester,
    ) async {
      await tester.pumpWidget(host());
      final center = tester.getCenter(find.text('body'));

      await doubleTap(tester, center);
      await tester.pumpAndSettle();

      // Scaffold + AppBar with the default BackButton, body shows the child.
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.text('double'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('double'), findsNothing);
    });
  });
}
