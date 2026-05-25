// animated_widgets/test/src/fader_widget/fader_state_test.dart

import 'package:animated_widgets/src/fader_widget/fader_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FaderState', () {
    const base = FaderState(
      current: 'a',
      isAnimating: false,
      queue: ['b', 'c'],
    );

    test('stores the fields it is constructed with', () {
      expect(base.current, 'a');
      expect(base.isAnimating, false);
      expect(base.queue, ['b', 'c']);
    });

    group('copyWith', () {
      test('no-args preserves every field', () {
        final copy = base.copyWith();
        expect(copy.current, 'a');
        expect(copy.isAnimating, false);
        expect(copy.queue, ['b', 'c']);
      });

      test('overrides current only', () {
        final copy = base.copyWith(current: 'z');
        expect(copy.current, 'z');
        expect(copy.isAnimating, false);
        expect(copy.queue, ['b', 'c']);
      });

      test('overrides isAnimating only', () {
        final copy = base.copyWith(isAnimating: true);
        expect(copy.current, 'a');
        expect(copy.isAnimating, true);
        expect(copy.queue, ['b', 'c']);
      });

      test('overrides queue only', () {
        final copy = base.copyWith(queue: const ['x']);
        expect(copy.current, 'a');
        expect(copy.isAnimating, false);
        expect(copy.queue, ['x']);
      });

      test('null current falls back to the existing value', () {
        // copyWith uses `current ?? this.current`, so a null argument keeps
        // the previous string rather than clearing it.
        final copy = base.copyWith();
        expect(copy.current, 'a');
      });
    });

    group('equality', () {
      test('identical instance is equal to itself', () {
        expect(base == base, isTrue);
      });

      test('equal when all fields match', () {
        const other = FaderState(
          current: 'a',
          isAnimating: false,
          queue: ['b', 'c'],
        );
        expect(base, equals(other));
        expect(base.hashCode, other.hashCode);
      });

      test('not equal when current differs', () {
        const other = FaderState(
          current: 'different',
          isAnimating: false,
          queue: ['b', 'c'],
        );
        expect(base, isNot(equals(other)));
      });

      test('not equal when isAnimating differs', () {
        const other = FaderState(
          current: 'a',
          isAnimating: true,
          queue: ['b', 'c'],
        );
        expect(base, isNot(equals(other)));
      });

      test('not equal when queue length differs', () {
        const other = FaderState(
          current: 'a',
          isAnimating: false,
          queue: ['b'],
        );
        expect(base, isNot(equals(other)));
      });

      test('not equal when a queue element differs', () {
        const other = FaderState(
          current: 'a',
          isAnimating: false,
          queue: ['b', 'DIFFERENT'],
        );
        expect(base, isNot(equals(other)));
      });

      test('not equal to an object of another type', () {
        // Exercises the `other is FaderState` short-circuit.
        // ignore: unrelated_type_equality_checks
        expect(base == Object(), isFalse);
      });

      test('equal when both queues are empty', () {
        const a = FaderState(current: null, isAnimating: false, queue: []);
        const b = FaderState(current: null, isAnimating: false, queue: []);
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('null current states are equal', () {
        const a = FaderState(current: null, isAnimating: true, queue: ['q']);
        const b = FaderState(current: null, isAnimating: true, queue: ['q']);
        expect(a, equals(b));
      });
    });
  });
}
