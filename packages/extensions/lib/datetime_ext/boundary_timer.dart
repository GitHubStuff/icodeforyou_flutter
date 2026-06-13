// packages/extensions/lib/datetime_ext/boundary_timer.dart
import 'dart:async';

import 'package:extensions/datetime_ext/datetime_extension.dart'
    show DateTimeExt;
import 'package:extensions/datetime_ext/datetime_unit.dart';

/// A self-correcting, boundary-aligned repeating timer.
///
/// Unlike [Timer.periodic], which fires every `interval` from an arbitrary
/// start, [BoundaryTimer] re-targets the next [DateTimeUnit] boundary on every
/// cycle. Each tick lands on the top of the next second/minute/hour/day, and
/// because the delay is recomputed from the current clock every time, slop in
/// one cycle never accumulates into the next.
///
/// A tick whose work overruns its window does not pile up: the next boundary is
/// only scheduled once the previous tick completes, so the timer skips rather
/// than queuing late callbacks.
///
/// Exactly one [Timer] is outstanding at a time, and [stop] cancels it
/// immediately — no dangling waits survive a stop. Stop it two ways:
/// * externally, by calling [stop];
/// * internally, by returning `false` from the `onTick` callback.
class BoundaryTimer {
  /// Creates a timer that fires on every [unit] boundary.
  ///
  /// [_onTick] runs on each boundary; returning `false` stops the timer. It may
  /// be synchronous or asynchronous. [_now] supplies the current time and is
  /// injectable so the timer can be driven by a fake clock in tests. [_onError]
  /// receives any error thrown by [_onTick]; the timer stops when a tick throws.
  BoundaryTimer({
    required this.unit,
    required this._onTick,
    this._now = DateTime.now,
    this._onError,
  });

  /// The boundary the timer aligns each tick to.
  final DateTimeUnit unit;

  final FutureOr<bool> Function() _onTick;
  final DateTime Function() _now;
  final void Function(Object error, StackTrace stackTrace)? _onError;

  Timer? _timer;
  bool _running = false;

  /// Whether the timer is currently scheduling ticks.
  bool get isActive => _running;

  /// Starts the timer. Has no effect if it is already active.
  void start() {
    if (_running) return;
    _running = true;
    _schedule();
  }

  /// Stops the timer, cancelling any pending wait. Safe to call when idle.
  void stop() {
    if (!_running) return;
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  void _schedule() {
    _timer = Timer(
      Duration(microseconds: _now().next(unit)),
      () => unawaited(_onBoundary()),
    );
  }

  Future<void> _onBoundary() async {
    if (!_running) return;
    try {
      if (!await _onTick()) {
        _running = false;
        return;
      }
    } catch (error, stackTrace) {
      _running = false;
      _onError?.call(error, stackTrace);
      return;
    }
    if (_running) _schedule();
  }
}
