// packages/duration_widget/lib/src/ticking_clock_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// A [Cubit] that emits an updated [DateTime] at a fixed periodic [interval].
///
/// Starting from an initial [DateTime], this cubit maintains an internal [Timer]
/// that increments the emitted state by [interval] on every tick.
///
/// ### Example
///
/// ```dart
/// final clockCubit = TickingClockCubit(
///   DateTime.now(),
///   const Duration(seconds: 1),
/// );
///
/// // Don't forget to close when no longer needed:
/// await clockCubit.close();
/// ```
///
/// See also:
///
///  * [Cubit], the state management primitive from `package:bloc`.
///  * [Timer.periodic], the underlying periodic scheduler.
class TickingClockCubit extends Cubit<DateTime> {
  /// Creates a [TickingClockCubit] initialized to [start] that ticks every
  /// [interval].
  ///
  /// Throws an [AssertionError] if [interval] is not strictly greater than
  /// [Duration.zero].
  TickingClockCubit(super.initialState, this.interval)
    : assert(interval > Duration.zero, 'interval must be positive') {
    _timer = Timer.periodic(interval, (_) => emit(state.add(interval)));
  }

  /// The frequency at which new [DateTime] states are emitted.
  ///
  /// Each periodic tick advances the current [state] by this exact amount.
  final Duration interval;

  /// The underlying periodic timer responsible for driving state emissions.
  late final Timer _timer;

  /// Cancels the internal [_timer] and closes the cubit.
  ///
  /// Subsequent calls to emit state will fail after this method completes.
  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
