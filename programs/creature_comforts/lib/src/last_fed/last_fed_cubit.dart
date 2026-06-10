// programs/creature_comforts/lib/src/last_fed/last_fed_cubit.dart
import 'dart:async';

import 'package:creature_comforts/src/last_fed/last_fed_state.dart';
import 'package:creature_comforts_service/creature_comforts_service.dart'
    show LastFedFailure, LastFedService, crittersStatusFor;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Either;

/// App-wide owner of last-fed data.
///
/// Subscribes once to [LastFedService.watch], classifies each timestamp
/// into a [CrittersStatus] via [crittersStatusFor], and ticks once a
/// minute so elapsed-time renders stay fresh.
///
/// Provided at the root in `app.dart` (alongside [AuthCubit] and
/// [HapticsCubit]) so every screen that needs feeding data — the home
/// screen's pet image and last-fed display, the edit screen's last-fed
/// display, future notifications/haptics features — reads from one
/// subscription and one timer rather than each starting their own.
///
/// Design rules in force:
///
///  - SRP: this cubit knows nothing about screens. It owns "what is
///    the most recent feeding, and what status does that imply."
///  - DIP: takes [LastFedService] via constructor. The widget that
///    creates the cubit (`app.dart`) does the registry lookup once.
///  - DRY: the alive/dead rule lives in [crittersStatusFor]. This
///    cubit is the only caller in the program; consumers read the
///    cached [LastFedReady.status] and never re-derive.
final class LastFedCubit extends Cubit<LastFedState> {
  /// Constructs the cubit and immediately subscribes to [lastFed].
  ///
  /// [now] is injectable so tests can drive classification with a fake
  /// clock; in production it defaults to [DateTime.now].
  LastFedCubit({
    required LastFedService lastFed,
    DateTime Function()? now,
  }) : _lastFed = lastFed,
       _now = now ?? DateTime.now,
       super(const LastFedInitializing()) {
    _sub = _lastFed.watch().listen(_onEvent);
  }

  /// Cadence of the elapsed-time refresh. Matches the finest unit
  /// rendered by `LastFedDisplay`.
  static const Duration _kTickInterval = Duration(minutes: 1);

  final LastFedService _lastFed;
  final DateTime Function() _now;

  late final StreamSubscription<Either<LastFedFailure, DateTime>> _sub;
  Timer? _tick;
  int _tickCounter = 0;

  void _onEvent(Either<LastFedFailure, DateTime> event) {
    event.match(
      (failure) {
        _stopTicking();
        emit(LastFedFailureState(failure: failure));
      },
      (lastFed) {
        emit(
          LastFedReady(
            lastFed: lastFed,
            status: crittersStatusFor(lastFed, now: _now()),
            tick: _tickCounter,
          ),
        );
        _ensureTicking();
      },
    );
  }

  void _ensureTicking() {
    _tick ??= Timer.periodic(_kTickInterval, (_) => _onTick());
  }

  void _stopTicking() {
    _tick?.cancel();
    _tick = null;
  }

  void _onTick() {
    final current = state;
    if (current is! LastFedReady) {
      // Defensive: the timer is gated by _ensureTicking / _stopTicking
      // so this shouldn't be reachable, but if it is, stop the timer
      // rather than emit a wrong-shaped state.
      _stopTicking();
      return;
    }
    _tickCounter++;
    emit(
      LastFedReady(
        lastFed: current.lastFed,
        status: crittersStatusFor(current.lastFed, now: _now()),
        tick: _tickCounter,
      ),
    );
  }

  @override
  Future<void> close() async {
    _stopTicking();
    await _sub.cancel();
    return super.close();
  }
}
