// packages/ping_pong/test/src/ping_pong_ball_test.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_pong/src/ping_pong_ball.dart';

void main() {
  const border = Color(0xFF123456);
  const child = SizedBox(key: Key('child'));

  Widget wrap(Widget widget) => Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: widget),
  );

  group('PingPongBall', () {
    test('exposes its fields', () {
      void onTap() {}
      final ball = PingPongBall(
        radius: 12,
        border: border,
        speed: 80,
        onTap: onTap,
        child: child,
      );

      expect(ball.radius, 12);
      expect(ball.border, border);
      expect(ball.speed, 80);
      expect(ball.onTap, same(onTap));
      expect(ball.child, same(child));
    });

    test('defaults speed and onTap to null', () {
      const ball = PingPongBall(radius: 12, border: border, child: child);

      expect(ball.speed, isNull);
      expect(ball.onTap, isNull);
    });

    test('diameter is twice the radius', () {
      const ball = PingPongBall(radius: 12, border: border, child: child);

      expect(ball.diameter, 24);
    });

    test('border width is two logical pixels', () {
      expect(PingPongBall.borderWidth, 2);
    });

    test('rejects a non-positive radius', () {
      expect(
        () => PingPongBall(radius: 0, border: border, child: child),
        throwsAssertionError,
      );
    });

    test('rejects a negative speed', () {
      expect(
        () => PingPongBall(
          radius: 12,
          border: border,
          speed: -1,
          child: child,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('lays out as a square of its diameter', (tester) async {
      await tester.pumpWidget(
        wrap(
          const PingPongBall(radius: 12, border: border, child: child),
        ),
      );

      expect(tester.getSize(find.byType(PingPongBall)), const Size(24, 24));
    });

    testWidgets('clips its child to an oval', (tester) async {
      await tester.pumpWidget(
        wrap(
          const PingPongBall(radius: 12, border: border, child: child),
        ),
      );

      expect(
        find.ancestor(
          of: find.byKey(const Key('child')),
          matching: find.byType(ClipOval),
        ),
        findsOneWidget,
      );
    });

    testWidgets('draws a circular foreground border', (tester) async {
      await tester.pumpWidget(
        wrap(
          const PingPongBall(radius: 12, border: border, child: child),
        ),
      );

      final box = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
      final decoration = box.decoration as BoxDecoration;
      final side = decoration.border! as Border;

      expect(box.position, DecorationPosition.foreground);
      expect(decoration.shape, BoxShape.circle);
      expect(side.top.color, border);
      expect(side.top.width, PingPongBall.borderWidth);
      expect(side.isUniform, isTrue);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          PingPongBall(
            radius: 12,
            border: border,
            onTap: () => taps++,
            child: child,
          ),
        ),
      );

      await tester.tap(find.byType(PingPongBall));

      expect(taps, 1);
    });

    testWidgets('is passive without onTap', (tester) async {
      await tester.pumpWidget(
        wrap(
          const PingPongBall(radius: 12, border: border, child: child),
        ),
      );

      await tester.tap(find.byType(PingPongBall), warnIfMissed: false);

      expect(tester.takeException(), isNull);
    });
  });
}
