// packages/counter_ring/lib/src/cubit/counter_ring_cubit.dart
import 'dart:async';

import 'package:counter_ring/counter_ring.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Drives a [CounterRing] by advancing a numeric value from `start`
/// towards `finish` in fixed `step` increments on a periodic [Timer].
///
/// The counting direction is derived from the relative order of `start`
/// and `finish`; `step` is always a positive magnitude. When the next
/// value would reach or overshoot `finish`, the cubit clamps to `finish`
/// exactly and transitions to [CounterRingStatus.finished].
///
/// This cubit owns the [Timer]. The timer is always cancelled on [stop],
/// [cancel], on reaching `finish`, and on [close], so no tick can fire
/// against a stopped, cancelled, finished, or closed cubit.
///
/// The caller owns this cubit's lifecycle and must call [close].
///
/// ```dart
/// final cubit = CounterRingCubit(
///   start: 0,
///   finish: 100,
///   step: 10,
///   interval: const Duration(milliseconds: 100),
/// )..start();
/// // ...
/// await cubit.close();
/// ```
class CounterRingCubit extends Cubit<CounterRingState> {
  /// Creates a cubit whose initial state is [CounterRingState.initial]
  /// built from [start], [finish], and [step].
  ///
  /// [start] is the value counting begins at and the value [cancel]
  /// rewinds to. [finish] is the terminal value. The two must differ.
  ///
  /// [step] is the magnitude added on each tick and must be positive;
  /// the sign is derived from whether [finish] is above or below [start].
  ///
  /// [interval] is the period between ticks once [start] has been called.
  CounterRingCubit({
    double start = 0,
    double finish = 100,
    double step = 10,
    this.interval = const Duration(seconds: 1),
  }) : assert(start != finish, 'start must differ from finish'),
       assert(step > 0, 'step must be positive; direction is derived'),
       super(
         CounterRingState.initial(start: start, finish: finish, step: step),
       );

  /// The period between consecutive ticks while running.
  final Duration interval;

  Timer? _timer;

  /// Starts counting, or resumes after [stop].
  ///
  /// Transitions to [CounterRingStatus.running] and schedules a periodic
  /// timer with [interval]. Does nothing if the cubit is already running
  /// or has already reached `finish`.
  void start() {
    if (state.isRunning || state.isFinished) return;
    emit(state.copyWith(status: CounterRingStatus.running));
    _timer = Timer.periodic(interval, _onTick);
  }

  /// Pauses at the current value. [start] resumes from that value.
  ///
  /// Cancels the timer unconditionally and transitions to
  /// [CounterRingStatus.stopped] only if the cubit was running; calling
  /// [stop] on a cubit that is not running emits nothing.
  void stop() {
    _stopTimer();
    if (state.isRunning) {
      emit(state.copyWith(status: CounterRingStatus.stopped));
    }
  }

  /// Stops and rewinds to [CounterRingState.start].
  ///
  /// Cancels the timer and replaces the state with a fresh
  /// [CounterRingState.initial] carrying the same `start`, `finish`, and
  /// `step`. A subsequent [start] counts from the beginning again, even
  /// if the cubit had previously finished.
  void cancel() {
    _stopTimer();
    emit(
      CounterRingState.initial(
        start: state.start,
        finish: state.finish,
        step: state.step,
      ),
    );
  }

  void _onTick(Timer _) {
    final next = state.currentValue + state.step * state.direction;
    if (state.hasReachedFinish(next)) {
      _stopTimer();
      emit(
        state.copyWith(
          currentValue: state.finish,
          status: CounterRingStatus.finished,
        ),
      );
      return;
    }
    emit(state.copyWith(currentValue: next));
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancels any running timer before closing the underlying [Cubit].
  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
