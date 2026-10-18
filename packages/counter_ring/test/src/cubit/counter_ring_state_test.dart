import 'package:counter_ring/counter_ring.dart'
    show CounterRingState, CounterRingStatus;
import 'package:flutter_test/flutter_test.dart';

void main() {
  const up = CounterRingState(
    start: 0,
    finish: 100,
    step: 10,
    currentValue: 40,
    status: CounterRingStatus.running,
  );

  const down = CounterRingState(
    start: 100,
    finish: 0,
    step: 10,
    currentValue: 60,
    status: CounterRingStatus.running,
  );

  group('CounterRingState', () {
    group('constructor', () {
      test('assigns every field', () {
        expect(up.start, 0);
        expect(up.finish, 100);
        expect(up.step, 10);
        expect(up.currentValue, 40);
        expect(up.status, CounterRingStatus.running);
      });
    });

    group('initial', () {
      test('sets currentValue to start and status to idle', () {
        const state = CounterRingState.initial(start: 5, finish: 55, step: 10);

        expect(state.start, 5);
        expect(state.finish, 55);
        expect(state.step, 10);
        expect(state.currentValue, 5);
        expect(state.status, CounterRingStatus.idle);
      });
    });

    group('isCountingUp', () {
      test('is true when finish is above start', () {
        expect(up.isCountingUp, isTrue);
      });

      test('is false when finish is below start', () {
        expect(down.isCountingUp, isFalse);
      });
    });

    group('direction', () {
      test('is +1 when counting up', () {
        expect(up.direction, 1);
      });

      test('is -1 when counting down', () {
        expect(down.direction, -1);
      });
    });

    group('isRunning', () {
      test('is true only for running', () {
        for (final status in CounterRingStatus.values) {
          final state = up.copyWith(status: status);
          expect(
            state.isRunning,
            status == CounterRingStatus.running,
            reason: '$status',
          );
        }
      });
    });

    group('isFinished', () {
      test('is true only for finished', () {
        for (final status in CounterRingStatus.values) {
          final state = up.copyWith(status: status);
          expect(
            state.isFinished,
            status == CounterRingStatus.finished,
            reason: '$status',
          );
        }
      });
    });

    group('hasReachedFinish', () {
      test('counting up: false below finish', () {
        expect(up.hasReachedFinish(99.9), isFalse);
      });

      test('counting up: true at finish', () {
        expect(up.hasReachedFinish(100), isTrue);
      });

      test('counting up: true past finish', () {
        expect(up.hasReachedFinish(120), isTrue);
      });

      test('counting down: false above finish', () {
        expect(down.hasReachedFinish(0.1), isFalse);
      });

      test('counting down: true at finish', () {
        expect(down.hasReachedFinish(0), isTrue);
      });

      test('counting down: true past finish', () {
        expect(down.hasReachedFinish(-20), isTrue);
      });
    });

    group('copyWith', () {
      test('replaces currentValue only', () {
        final copy = up.copyWith(currentValue: 50);

        expect(copy.currentValue, 50);
        expect(copy.status, up.status);
        expect(copy.start, up.start);
        expect(copy.finish, up.finish);
        expect(copy.step, up.step);
      });

      test('replaces status only', () {
        final copy = up.copyWith(status: CounterRingStatus.stopped);

        expect(copy.status, CounterRingStatus.stopped);
        expect(copy.currentValue, up.currentValue);
        expect(copy.start, up.start);
        expect(copy.finish, up.finish);
        expect(copy.step, up.step);
      });

      test('replaces both currentValue and status', () {
        final copy = up.copyWith(
          currentValue: 100,
          status: CounterRingStatus.finished,
        );

        expect(copy.currentValue, 100);
        expect(copy.status, CounterRingStatus.finished);
      });

      test('returns an equal state when given no arguments', () {
        expect(up.copyWith(), up);
      });
    });

    group('equality', () {
      test('equal states with identical fields', () {
        const other = CounterRingState(
          start: 0,
          finish: 100,
          step: 10,
          currentValue: 40,
          status: CounterRingStatus.running,
        );

        expect(up, other);
        expect(up.hashCode, other.hashCode);
      });

      test('differ when any field differs', () {
        expect(up, isNot(up.copyWith(currentValue: 41)));
        expect(up, isNot(up.copyWith(status: CounterRingStatus.idle)));
        expect(up, isNot(down));
      });

      test('props lists every field in declaration order', () {
        expect(
          up.props,
          [0.0, 100.0, 10.0, 40.0, CounterRingStatus.running],
        );
      });
    });

    group('stringify', () {
      test('is enabled', () {
        expect(up.stringify, isTrue);
      });

      test('toString includes the type and every field', () {
        final text = up.toString();

        expect(text, contains('CounterRingState'));
        expect(text, contains('0.0'));
        expect(text, contains('100.0'));
        expect(text, contains('10.0'));
        expect(text, contains('40.0'));
        expect(text, contains('CounterRingStatus.running'));
      });
    });
  });
}
