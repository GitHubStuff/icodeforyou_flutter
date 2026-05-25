// animated_widgets/test/src/animated_overlay/cubit/animated_overlay_state_test.dart

import 'package:animated_widgets/src/animated_overlay/cubit/animated_overlay_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedOverlayState', () {
    group('default constructor', () {
      test('defaults to null child and opacity 1.0', () {
        const state = AnimatedOverlayState();

        expect(state.child, isNull);
        expect(state.opacity, 1.0);
      });

      test('accepts a child and custom opacity', () {
        const child = Text('hello');
        const state = AnimatedOverlayState(child: child, opacity: 0.5);

        expect(state.child, same(child));
        expect(state.opacity, 0.5);
      });
    });

    group('hidden constructor', () {
      test('produces null child and opacity 1.0', () {
        const state = AnimatedOverlayState.hidden();

        expect(state.child, isNull);
        expect(state.opacity, 1.0);
      });
    });

    group('copyWith', () {
      const original = AnimatedOverlayState(
        child: Text('original'),
        opacity: 0.8,
      );

      test('returns identical fields when no arguments are provided', () {
        final copy = original.copyWith();

        expect(copy.child, same(original.child));
        expect(copy.opacity, original.opacity);
      });

      test('overrides child only', () {
        const newChild = Icon(Icons.star);
        final copy = original.copyWith(child: newChild);

        expect(copy.child, same(newChild));
        expect(copy.opacity, original.opacity);
      });

      test('overrides opacity only', () {
        final copy = original.copyWith(opacity: 0.25);

        expect(copy.child, same(original.child));
        expect(copy.opacity, 0.25);
      });

      test('overrides both child and opacity', () {
        const newChild = Icon(Icons.star);
        final copy = original.copyWith(child: newChild, opacity: 0.1);

        expect(copy.child, same(newChild));
        expect(copy.opacity, 0.1);
      });
    });
  });
}
