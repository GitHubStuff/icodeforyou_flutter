// packages/animated_widgets/test/src/fader_widget/src/cubit/fader_cubit_test.dart

import 'package:animated_widgets/src/fader_widget/fader_widget.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Readable FaderState literals for the expect() blocks.
  FaderState st({
    String? current,
    bool isAnimating = false,
    List<String> queue = const [],
  }) {
    return FaderState(current: current, isAnimating: isAnimating, queue: queue);
  }

  group('FaderCubit', () {
    test('starts idle with no current string and an empty queue', () {
      final cubit = FaderCubit();
      addTearDown(cubit.close);

      expect(cubit.state, st());
    });

    group('push', () {
      blocTest<FaderCubit, FaderState>(
        'emits the string immediately when idle',
        build: FaderCubit.new,
        act: (cubit) => cubit.push('a'),
        expect: () => [st(current: 'a')],
      );

      blocTest<FaderCubit, FaderState>(
        'queues the string (FIFO) while a fade is in flight',
        build: FaderCubit.new,
        act: (cubit) => cubit
          ..fadeStarted()
          ..push('b')
          ..push('c'),
        expect: () => [
          st(isAnimating: true),
          st(isAnimating: true, queue: ['b']),
          st(isAnimating: true, queue: ['b', 'c']),
        ],
      );
    });

    group('fadeStarted', () {
      blocTest<FaderCubit, FaderState>(
        'records that a fade has begun',
        build: FaderCubit.new,
        act: (cubit) => cubit.fadeStarted(),
        expect: () => [st(isAnimating: true)],
      );

      blocTest<FaderCubit, FaderState>(
        'is a no-op when a fade is already in flight',
        build: FaderCubit.new,
        act: (cubit) => cubit
          ..fadeStarted()
          ..fadeStarted(),
        expect: () => [st(isAnimating: true)],
      );
    });

    group('fadeComplete', () {
      blocTest<FaderCubit, FaderState>(
        'goes idle when the queue is empty',
        build: FaderCubit.new,
        act: (cubit) => cubit
          ..fadeStarted()
          ..fadeComplete(),
        expect: () => [
          st(isAnimating: true),
          st(),
        ],
      );

      blocTest<FaderCubit, FaderState>(
        'pulls the next queued string when the queue is not empty',
        build: FaderCubit.new,
        act: (cubit) => cubit
          ..push('a')
          ..fadeStarted()
          ..push('b')
          ..fadeComplete(),
        expect: () => [
          st(current: 'a'),
          st(current: 'a', isAnimating: true),
          st(current: 'a', isAnimating: true, queue: ['b']),
          st(current: 'b'),
        ],
      );
    });

    group('clear', () {
      blocTest<FaderCubit, FaderState>(
        'drops every queued string but leaves the current string untouched',
        build: FaderCubit.new,
        act: (cubit) => cubit
          ..push('a')
          ..fadeStarted()
          ..push('b')
          ..push('c')
          ..clear(),
        expect: () => [
          st(current: 'a'),
          st(current: 'a', isAnimating: true),
          st(current: 'a', isAnimating: true, queue: ['b']),
          st(current: 'a', isAnimating: true, queue: ['b', 'c']),
          st(current: 'a', isAnimating: true),
        ],
      );
    });
  });
}
