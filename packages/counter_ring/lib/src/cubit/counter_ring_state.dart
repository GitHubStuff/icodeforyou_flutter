// packages/counter_ring/lib/src/cubit/counter_ring_state.dart
import 'package:counter_ring/counter_ring.dart' show CounterRingStatus;
import 'package:equatable/equatable.dart';

/// Immutable state for a counter moving [step] per tick from [start]
/// toward [finish], in either direction.
///
/// Value equality is provided by [Equatable] over every field, and
/// [stringify] is enabled so instances print their fields.
class CounterRingState extends Equatable {
  /// Creates a state with every field specified explicitly.
  ///
  /// Prefer [CounterRingState.initial] for a fresh counter; use this
  /// constructor (or [copyWith]) when deriving a new state from an
  /// existing one.
  const CounterRingState({
    required this.start,
    required this.finish,
    required this.step,
    required this.currentValue,
    required this.status,
  });

  /// Creates the starting state for a counter: [currentValue] is [start]
  /// and [status] is [CounterRingStatus.idle].
  const CounterRingState.initial({
    required double start,
    required double finish,
    required double step,
  }) : this(
         start: start,
         finish: finish,
         step: step,
         currentValue: start,
         status: CounterRingStatus.idle,
       );

  /// The value counting begins at, and the value a cancel rewinds to.
  final double start;

  /// The terminal value. Counting stops once [currentValue] reaches it.
  final double finish;

  /// Magnitude of each tick; direction is derived from [start] and [finish].
  final double step;

  /// The value the counter is currently at.
  final double currentValue;

  /// The current lifecycle phase.
  final CounterRingStatus status;

  /// True when [finish] is above [start], so the counter ascends.
  bool get isCountingUp => finish > start;

  /// +1 when counting up, -1 when counting down.
  ///
  /// Multiply [step] by this to get the signed delta for one tick.
  double get direction => isCountingUp ? 1 : -1;

  /// True when [status] is [CounterRingStatus.running].
  bool get isRunning => status == CounterRingStatus.running;

  /// True when [status] is [CounterRingStatus.finished].
  bool get isFinished => status == CounterRingStatus.finished;

  /// True when [value] has reached or passed [finish] in the counting
  /// direction.
  ///
  /// When counting up, this is `value >= finish`; when counting down,
  /// `value <= finish`.
  bool hasReachedFinish(double value) =>
      isCountingUp ? value >= finish : value <= finish;

  /// Returns a copy with [currentValue] and/or [status] replaced.
  ///
  /// [start], [finish], and [step] are fixed for the lifetime of a counter
  /// and are always carried over unchanged.
  CounterRingState copyWith({
    double? currentValue,
    CounterRingStatus? status,
  }) {
    return CounterRingState(
      start: start,
      finish: finish,
      step: step,
      currentValue: currentValue ?? this.currentValue,
      status: status ?? this.status,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [start, finish, step, currentValue, status];
}
