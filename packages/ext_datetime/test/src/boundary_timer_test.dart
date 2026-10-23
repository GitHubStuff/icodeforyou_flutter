// packages/ext_datetime/test/src/boundary_timer_test.dart

import 'dart:async';

import 'package:ext_datetime/ext_datetime.dart' show DateTimeUnit;
import 'package:ext_datetime/src/boundary_timer.dart' show BoundaryTimer;
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoundaryTimer', () {
    /// A frozen clock 500 ms before a second boundary, so with
    /// [DateTimeUnit.second] every scheduled wait is exactly 500 ms.
    final frozen = DateTime.utc(2026, 1, 1, 0, 0, 0, 500);
    DateTime clock() => frozen;

    group('construction', () {
      test('exposes the configured unit', () {
        final timer = BoundaryTimer(
          unit: DateTimeUnit.minute,
          onTick: () => true,
          now: clock,
        );
        expect(timer.unit, DateTimeUnit.minute);
      });

      test('is inactive before start', () {
        final timer = BoundaryTimer(
          unit: DateTimeUnit.second,
          onTick: () => true,
          now: clock,
        );
        expect(timer.isActive, isFalse);
      });

      test('defaults the clock to DateTime.now', () {
        fakeAsync((fake) {
          var ticks = 0;
          BoundaryTimer(
            unit: DateTimeUnit.usec,
            onTick: () {
              ticks++;
              return false;
            },
          ).start();

          // The real clock is at most one microsecond from a usec boundary.
          fake.elapse(const Duration(milliseconds: 1));
          expect(ticks, 1);
        });
      });
    });

    group('start', () {
      test('marks the timer active', () {
        fakeAsync((fake) {
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () => true,
            now: clock,
          )..start();
          expect(timer.isActive, isTrue);
          timer.stop();
        });
      });

      test('does not tick before the boundary', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () {
              ticks++;
              return true;
            },
            now: clock,
          )..start();

          fake.elapse(const Duration(milliseconds: 499));
          expect(ticks, 0);
          timer.stop();
        });
      });

      test('ticks exactly on the boundary', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () {
              ticks++;
              return true;
            },
            now: clock,
          )..start();

          fake.elapse(const Duration(milliseconds: 499));
          expect(ticks, 0);
          fake.elapse(const Duration(milliseconds: 1));
          expect(ticks, 1);
          timer.stop();
        });
      });

      test('is idempotent — a second start does not double-schedule', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer =
              BoundaryTimer(
                  unit: DateTimeUnit.second,
                  onTick: () {
                    ticks++;
                    return false;
                  },
                  now: clock,
                )
                ..start()
                ..start()
                ..start();

          fake.elapse(const Duration(seconds: 5));
          expect(ticks, 1);
          expect(timer.isActive, isFalse);
        });
      });

      test('can be restarted after it has stopped itself', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () {
              ticks++;
              return false;
            },
            now: clock,
          )..start();

          fake.elapse(const Duration(milliseconds: 600));
          expect(ticks, 1);
          expect(timer.isActive, isFalse);

          timer.start();
          expect(timer.isActive, isTrue);
          fake.elapse(const Duration(milliseconds: 600));
          expect(ticks, 2);
          expect(timer.isActive, isFalse);
        });
      });

      test('can be restarted after an external stop', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () {
              ticks++;
              return true;
            },
            now: clock,
          )..start();

          fake.elapse(const Duration(milliseconds: 600));
          expect(ticks, 1);
          timer.stop();

          fake.elapse(const Duration(seconds: 3));
          expect(ticks, 1);

          timer.start();
          fake.elapse(const Duration(milliseconds: 600));
          expect(ticks, 2);
          timer.stop();
        });
      });

      test('aligns to each unit boundary from the injected clock', () {
        final instant = DateTime.utc(2026, 1, 15, 10, 30, 45, 123, 456);
        const expectedWaits = <DateTimeUnit, Duration>{
          DateTimeUnit.usec: Duration(microseconds: 1),
          DateTimeUnit.msec: Duration(microseconds: 544),
          DateTimeUnit.second: Duration(milliseconds: 876, microseconds: 544),
          DateTimeUnit.minute: Duration(
            seconds: 14,
            milliseconds: 876,
            microseconds: 544,
          ),
          DateTimeUnit.hour: Duration(
            minutes: 29,
            seconds: 14,
            milliseconds: 876,
            microseconds: 544,
          ),
          DateTimeUnit.day: Duration(
            hours: 13,
            minutes: 29,
            seconds: 14,
            milliseconds: 876,
            microseconds: 544,
          ),
          DateTimeUnit.month: Duration(
            days: 16,
            hours: 13,
            minutes: 29,
            seconds: 14,
            milliseconds: 876,
            microseconds: 544,
          ),
          DateTimeUnit.year: Duration(
            days: 350,
            hours: 13,
            minutes: 29,
            seconds: 14,
            milliseconds: 876,
            microseconds: 544,
          ),
        };

        for (final unit in DateTimeUnit.values) {
          fakeAsync((fake) {
            var ticks = 0;
            final timer = BoundaryTimer(
              unit: unit,
              onTick: () {
                ticks++;
                return false;
              },
              now: () => instant,
            )..start();

            final wait = expectedWaits[unit]!;
            fake.elapse(wait - const Duration(microseconds: 1));
            expect(ticks, 0, reason: '$unit fired early');
            fake.elapse(const Duration(microseconds: 1));
            expect(ticks, 1, reason: '$unit did not fire on the boundary');
            expect(timer.isActive, isFalse);
          });
        }
      });
    });

    group('rescheduling', () {
      test('keeps ticking while onTick returns true', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () {
              ticks++;
              return true;
            },
            now: clock,
          )..start();

          fake.elapse(const Duration(milliseconds: 1600));
          expect(ticks, 3);
          expect(timer.isActive, isTrue);

          fake.elapse(const Duration(milliseconds: 1000));
          expect(ticks, 5);
          timer.stop();
        });
      });

      test('recomputes the wait from the clock after every tick', () {
        fakeAsync((fake) {
          // The clock jumps closer to the boundary after the first tick, so
          // the second wait must shrink accordingly.
          var calls = 0;
          DateTime jumpingClock() {
            calls++;
            return calls == 1
                ? DateTime.utc(2026, 1, 1, 0, 0, 0, 500)
                : DateTime.utc(2026, 1, 1, 0, 0, 0, 900);
          }

          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () {
              ticks++;
              return true;
            },
            now: jumpingClock,
          )..start();

          fake.elapse(const Duration(milliseconds: 500));
          expect(ticks, 1);

          fake.elapse(const Duration(milliseconds: 99));
          expect(ticks, 1);
          fake.elapse(const Duration(milliseconds: 1));
          expect(ticks, 2);
          timer.stop();
        });
      });

      test('stops when onTick returns false', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () {
              ticks++;
              return false;
            },
            now: clock,
          )..start();

          fake.elapse(const Duration(seconds: 10));
          expect(ticks, 1);
          expect(timer.isActive, isFalse);
        });
      });

      test('stops after a finite run when onTick turns false', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () => ++ticks < 4,
            now: clock,
          )..start();

          fake.elapse(const Duration(seconds: 10));
          expect(ticks, 4);
          expect(timer.isActive, isFalse);
        });
      });

      test('supports an asynchronous onTick returning true', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () async {
              ticks++;
              return true;
            },
            now: clock,
          )..start();

          fake.elapse(const Duration(milliseconds: 1600));
          expect(ticks, 3);
          expect(timer.isActive, isTrue);
          timer.stop();
        });
      });

      test('supports an asynchronous onTick returning false', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () async {
              ticks++;
              return false;
            },
            now: clock,
          )..start();

          fake.elapse(const Duration(seconds: 10));
          expect(ticks, 1);
          expect(timer.isActive, isFalse);
        });
      });

      test(
        'does not schedule the next tick until the current one completes',
        () {
          fakeAsync((fake) {
            var ticks = 0;
            final gate = Completer<bool>();
            final timer = BoundaryTimer(
              unit: DateTimeUnit.second,
              onTick: () {
                ticks++;
                if (ticks == 1) return gate.future;
                return true;
              },
              now: clock,
            )..start();

            // First tick fires and then blocks on the gate.
            fake.elapse(const Duration(milliseconds: 500));
            expect(ticks, 1);

            // Time passes but no new boundary is scheduled while blocked.
            fake.elapse(const Duration(seconds: 5));
            expect(ticks, 1);
            expect(timer.isActive, isTrue);

            // Releasing the gate schedules the next boundary from the clock.
            gate.complete(true);
            fake.flushMicrotasks();
            fake.elapse(const Duration(milliseconds: 499));
            expect(ticks, 1);
            fake.elapse(const Duration(milliseconds: 1));
            expect(ticks, 2);
            timer.stop();
          });
        },
      );
    });

    group('stop', () {
      test('is a no-op when idle', () {
        final timer = BoundaryTimer(
          unit: DateTimeUnit.second,
          onTick: () => true,
          now: clock,
        );
        expect(timer.stop, returnsNormally);
        expect(timer.isActive, isFalse);
      });

      test('is a no-op when called twice', () {
        fakeAsync((fake) {
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () => true,
            now: clock,
          )..start();
          timer.stop();
          expect(timer.stop, returnsNormally);
          expect(timer.isActive, isFalse);
        });
      });

      test('cancels a pending wait so no tick ever fires', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () {
              ticks++;
              return true;
            },
            now: clock,
          )..start();

          fake.elapse(const Duration(milliseconds: 100));
          timer.stop();
          expect(timer.isActive, isFalse);

          fake.elapse(const Duration(seconds: 10));
          expect(ticks, 0);
        });
      });

      test('between ticks prevents any further ticks', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () {
              ticks++;
              return true;
            },
            now: clock,
          )..start();

          fake.elapse(const Duration(milliseconds: 1100));
          expect(ticks, 2);

          timer.stop();
          fake.elapse(const Duration(seconds: 10));
          expect(ticks, 2);
          expect(timer.isActive, isFalse);
        });
      });

      test(
        'called from inside a synchronous onTick suppresses rescheduling',
        () {
          fakeAsync((fake) {
            var ticks = 0;
            late final BoundaryTimer timer;
            timer = BoundaryTimer(
              unit: DateTimeUnit.second,
              onTick: () {
                ticks++;
                timer.stop();
                return true;
              },
              now: clock,
            )..start();

            fake.elapse(const Duration(seconds: 10));
            expect(ticks, 1);
            expect(timer.isActive, isFalse);
          });
        },
      );

      test(
        'while an asynchronous tick is in flight suppresses rescheduling',
        () {
          fakeAsync((fake) {
            var ticks = 0;
            final gate = Completer<bool>();
            final timer = BoundaryTimer(
              unit: DateTimeUnit.second,
              onTick: () {
                ticks++;
                return gate.future;
              },
              now: clock,
            )..start();

            fake.elapse(const Duration(milliseconds: 500));
            expect(ticks, 1);
            expect(timer.isActive, isTrue);

            timer.stop();
            expect(timer.isActive, isFalse);

            gate.complete(true);
            fake.flushMicrotasks();
            fake.elapse(const Duration(seconds: 10));
            expect(ticks, 1);
            expect(timer.isActive, isFalse);
          });
        },
      );

      test('leaves no pending timers behind', () {
        fakeAsync((fake) {
          BoundaryTimer(
              unit: DateTimeUnit.second,
              onTick: () => true,
              now: clock,
            )
            ..start()
            ..stop();
          expect(fake.pendingTimers, isEmpty);
        });
      });
    });

    group('errors', () {
      test('a synchronous throw stops the timer and reports to onError', () {
        fakeAsync((fake) {
          final boom = StateError('boom');
          Object? reported;
          StackTrace? reportedTrace;
          var ticks = 0;

          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () {
              ticks++;
              throw boom;
            },
            now: clock,
            onError: (error, stackTrace) {
              reported = error;
              reportedTrace = stackTrace;
            },
          )..start();

          fake.elapse(const Duration(seconds: 10));
          expect(ticks, 1);
          expect(reported, same(boom));
          expect(reportedTrace, isNotNull);
          expect(timer.isActive, isFalse);
        });
      });

      test(
        'an asynchronous failure stops the timer and reports to onError',
        () {
          fakeAsync((fake) {
            final boom = ArgumentError('async boom');
            Object? reported;
            var ticks = 0;

            final timer = BoundaryTimer(
              unit: DateTimeUnit.second,
              onTick: () {
                ticks++;
                return Future<bool>.error(boom);
              },
              now: clock,
              onError: (error, _) => reported = error,
            )..start();

            fake.elapse(const Duration(seconds: 10));
            expect(ticks, 1);
            expect(reported, same(boom));
            expect(timer.isActive, isFalse);
          });
        },
      );

      test('a throw with no onError stops the timer silently', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () {
              ticks++;
              throw StateError('silent');
            },
            now: clock,
          )..start();

          expect(
            () => fake.elapse(const Duration(seconds: 10)),
            returnsNormally,
          );
          expect(ticks, 1);
          expect(timer.isActive, isFalse);
        });
      });

      test('a non-Error throwable is still caught', () {
        fakeAsync((fake) {
          Object? reported;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            // ignore: only_throw_errors
            onTick: () => throw 'a string',
            now: clock,
            onError: (error, _) => reported = error,
          )..start();

          fake.elapse(const Duration(seconds: 1));
          expect(reported, 'a string');
          expect(timer.isActive, isFalse);
        });
      });

      test(
        'a throw on a later tick stops after the earlier ticks succeeded',
        () {
          fakeAsync((fake) {
            var ticks = 0;
            Object? reported;
            final timer = BoundaryTimer(
              unit: DateTimeUnit.second,
              onTick: () {
                ticks++;
                if (ticks == 3) throw StateError('third');
                return true;
              },
              now: clock,
              onError: (error, _) => reported = error,
            )..start();

            fake.elapse(const Duration(seconds: 10));
            expect(ticks, 3);
            expect(reported, isA<StateError>());
            expect(timer.isActive, isFalse);
          });
        },
      );

      test('can be restarted after an error', () {
        fakeAsync((fake) {
          var ticks = 0;
          final timer = BoundaryTimer(
            unit: DateTimeUnit.second,
            onTick: () {
              ticks++;
              if (ticks == 1) throw StateError('first');
              return false;
            },
            now: clock,
            onError: (_, _) {},
          )..start();

          fake.elapse(const Duration(seconds: 1));
          expect(ticks, 1);
          expect(timer.isActive, isFalse);

          timer.start();
          fake.elapse(const Duration(seconds: 1));
          expect(ticks, 2);
          expect(timer.isActive, isFalse);
        });
      });
    });
  });
}
