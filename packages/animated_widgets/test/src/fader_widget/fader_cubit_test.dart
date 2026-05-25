// animated_widgets/test/src/fader_widget/fader_cubit_test.dart

import 'package:animated_widgets/src/fader_widget/fader_widget.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FaderCubit', () {
    test('initial state is idle, empty and not animating', () {
      final cubit = FaderCubit();
      addTearDown(cubit.close);

      expect(cubit.state.current, isNull);
      expect(cubit.state.isAnimating, isFalse);
      expect(cubit.state.queue, isEmpty);
    });

    group('push', () {
      blocTest<FaderCubit, FaderState>(
        'emits the string immediately when idle',
        build: FaderCubit.new,
        act: (cubit) => cubit.push('hello'),
        expect: () => [
          isA<FaderState>()
              .having((s) => s.current, 'current', 'hello')
              .having((s) => s.isAnimating, 'isAnimating', false)
              .having((s) => s.queue, 'queue', isEmpty),
        ],
      );

      blocTest<FaderCubit, FaderState>(
        'queues subsequent strings while a fade is in flight',
        build: FaderCubit.new,
        act: (cubit) {
          cubit
            ..push('first')
            ..fadeStarted()
            ..push('second');
        },
        expect: () => [
          // first emitted immediately
          isA<FaderState>().having((s) => s.current, 'current', 'first'),
          // fadeStarted flips isAnimating
          isA<FaderState>().having((s) => s.isAnimating, 'isAnimating', true),
          // second is queued, not shown
          isA<FaderState>()
              .having((s) => s.current, 'current', 'first')
              .having((s) => s.queue, 'queue', ['second']),
        ],
      );

      blocTest<FaderCubit, FaderState>(
        'an idle field accepts a new string immediately even with one shown',
        build: FaderCubit.new,
        act: (cubit) {
          // Push, complete (idle again), then push once more. The second push
          // must show immediately because isAnimating is false.
          cubit
            ..push('one')
            ..fadeStarted()
            ..fadeComplete() // queue empty → back to idle
            ..push('two');
        },
        verify: (cubit) {
          expect(cubit.state.current, 'two');
          expect(cubit.state.queue, isEmpty);
        },
      );
    });

    group('fadeStarted', () {
      blocTest<FaderCubit, FaderState>(
        'sets isAnimating to true when not already animating',
        build: FaderCubit.new,
        seed: () => const FaderState(
          current: 'x',
          isAnimating: false,
          queue: [],
        ),
        act: (cubit) => cubit.fadeStarted(),
        expect: () => [
          isA<FaderState>().having((s) => s.isAnimating, 'isAnimating', true),
        ],
      );

      blocTest<FaderCubit, FaderState>(
        'is a no-op when already animating',
        build: FaderCubit.new,
        seed: () => const FaderState(
          current: 'x',
          isAnimating: true,
          queue: [],
        ),
        act: (cubit) => cubit.fadeStarted(),
        expect: () => <FaderState>[],
      );
    });

    group('fadeComplete', () {
      blocTest<FaderCubit, FaderState>(
        'goes idle when the queue is empty',
        build: FaderCubit.new,
        seed: () => const FaderState(
          current: 'x',
          isAnimating: true,
          queue: [],
        ),
        act: (cubit) => cubit.fadeComplete(),
        expect: () => [
          isA<FaderState>().having((s) => s.isAnimating, 'isAnimating', false),
        ],
      );

      blocTest<FaderCubit, FaderState>(
        'pulls the next queued string in FIFO order',
        build: FaderCubit.new,
        act: (cubit) {
          cubit
            ..push('a')
            ..fadeStarted()
            ..push('b')
            ..push('c')
            ..fadeComplete(); // should surface 'b' and leave ['c']
        },
        verify: (cubit) {
          expect(cubit.state.current, 'b');
          expect(cubit.state.queue, ['c']);
          expect(cubit.state.isAnimating, isFalse);
        },
      );

      test('drains the entire queue across successive completions', () {
        final cubit = FaderCubit();
        addTearDown(cubit.close);

        cubit
          ..push('a')
          ..fadeStarted()
          ..push('b')
          ..push('c');

        expect(cubit.state.current, 'a');
        expect(cubit.state.queue, ['b', 'c']);

        cubit.fadeComplete();
        expect(cubit.state.current, 'b');
        expect(cubit.state.queue, ['c']);

        cubit
          ..fadeStarted()
          ..fadeComplete();
        expect(cubit.state.current, 'c');
        expect(cubit.state.queue, isEmpty);

        cubit
          ..fadeStarted()
          ..fadeComplete();
        expect(cubit.state.current, 'c');
        expect(cubit.state.isAnimating, isFalse);
      });
    });

    group('clear', () {
      blocTest<FaderCubit, FaderState>(
        'empties the queue but leaves the on-screen string',
        build: FaderCubit.new,
        act: (cubit) {
          cubit
            ..push('shown')
            ..fadeStarted()
            ..push('queued1')
            ..push('queued2')
            ..clear();
        },
        verify: (cubit) {
          expect(cubit.state.current, 'shown');
          expect(cubit.state.queue, isEmpty);
        },
      );

      blocTest<FaderCubit, FaderState>(
        'syncs an empty queue snapshot when called while idle',
        build: FaderCubit.new,
        seed: () => const FaderState(
          current: 'shown',
          isAnimating: false,
          queue: [],
        ),
        act: (cubit) => cubit.clear(),
        verify: (cubit) {
          expect(cubit.state.queue, isEmpty);
        },
      );
    });

    test('exposed queue snapshot is unmodifiable', () {
      final cubit = FaderCubit();
      addTearDown(cubit.close);

      cubit
        ..push('a')
        ..fadeStarted()
        ..push('b');

      expect(() => cubit.state.queue.add('mutation'), throwsUnsupportedError);
    });
  });
}
