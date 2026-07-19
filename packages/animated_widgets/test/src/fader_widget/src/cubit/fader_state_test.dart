// packages/animated_widgets/test/src/fader_widget/src/cubit/fader_state_test.dart

import 'package:animated_widgets/src/fader_widget/fader_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FaderState st({
    String? current,
    bool isAnimating = false,
    List<String> queue = const [],
  }) {
    return FaderState(current: current, isAnimating: isAnimating, queue: queue);
  }

  group('FaderState', () {
    group('copyWith', () {
      test('returns an equal copy when no fields are provided', () {
        final original = st(current: 'a', isAnimating: true, queue: ['x']);

        expect(original.copyWith(), original);
      });

      test('overrides every provided field', () {
        final updated = st(current: 'a').copyWith(
          current: 'b',
          isAnimating: true,
          queue: ['x'],
        );

        expect(updated, st(current: 'b', isAnimating: true, queue: ['x']));
      });
    });

    group('equality', () {
      test('is equal to itself', () {
        final state = st(current: 'a');

        expect(state == state, isTrue);
      });

      test('is not equal to an object of another type', () {
        expect(st() == Object(), isFalse);
      });

      test('equates two instances with identical fields', () {
        expect(
          st(current: 'a', isAnimating: true, queue: ['x', 'y']),
          st(current: 'a', isAnimating: true, queue: ['x', 'y']),
        );
      });

      test('differs when current differs', () {
        expect(st(current: 'a'), isNot(st(current: 'b')));
      });

      test('differs when isAnimating differs', () {
        expect(st(isAnimating: false), isNot(st(isAnimating: true)));
      });

      test('differs when the queue length differs', () {
        expect(st(queue: ['x']), isNot(st(queue: ['x', 'y'])));
      });

      test('differs when a same-length queue element differs', () {
        expect(st(queue: ['x']), isNot(st(queue: ['y'])));
      });

      test('equates empty queues', () {
        expect(st(queue: []), st(queue: []));
      });
    });

    group('hashCode', () {
      test('matches for equal states', () {
        expect(
          st(current: 'a', isAnimating: true, queue: ['x']).hashCode,
          st(current: 'a', isAnimating: true, queue: ['x']).hashCode,
        );
      });
    });
  });
}
