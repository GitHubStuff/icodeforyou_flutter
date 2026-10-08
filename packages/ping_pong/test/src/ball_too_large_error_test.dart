// packages/ping_pong/test/src/ball_too_large_error_test.dart

import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:ping_pong/src/ball_too_large_error.dart';

void main() {
  group('BallTooLargeError', () {
    final error = BallTooLargeError(
      index: 4,
      radius: 60,
      bounds: const Size(100, 80),
    );

    test('is an Error', () {
      expect(error, isA<Error>());
    });

    test('exposes its fields', () {
      expect(error.index, 4);
      expect(error.radius, 60);
      expect(error.bounds, const Size(100, 80));
    });

    test('describes the ball and the arena', () {
      expect(
        error.toString(),
        'Ball 4 of radius 60.0 cannot fit in an arena of 100.0 x 80.0',
      );
    });
  });
}
