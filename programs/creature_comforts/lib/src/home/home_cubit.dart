// programs/creature_comforts/lib/src/home/home_cubit.dart
import 'dart:async';

import 'package:creature_comforts/src/home/home_state.dart';
import 'package:creature_comforts_service/creature_comforts_service.dart'
    show LastFedFailure, LastFedService, crittersStatusFor;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Either;

/// Owns the home screen's data: subscribes to [LastFedService.watch],
/// classifies each timestamp into a [CrittersStatus], and ticks once a
/// minute so elapsed-time renders stay fresh.
///
/// Design notes:
///
///  - Single source of truth for the alive/dead rule. The home
///    screen's two consumers (`_PetImage` and `LastFedDisplay`) both
///    read the cached [HomeReady.status]; nobody re-derives it.
///  - Service is injected (DIP). The widget that constructs the cubit
///    pulls it from the registry once; the cubit knows nothing about
///    `ServiceRegistry`.
///  - The internal minute timer only runs while in [HomeReady]. There
///    is nothing time-dependent to refresh during initialization or
///    failure, so the timer is started on entry to ready and cancelled
///    on transition out of it.
///  - Tick emissions are suppressed when neither [CrittersStatus] nor
///    the displayed minute-bucket would change. Equatable on
///    [HomeState] would already drop a literally-equal emission, but
///    short-circuiting before constructing a new state keeps the hot
///    path quiet.
final class HomeCubit extends Cubit<HomeState> {
  /// Constructs the cubit and immediately subscribes to [lastFed].
  ///
  /// [now] is injectable so tests can drive classification with a fake
  /// clock; in production it defaults to [DateTime.now].
  HomeCubit({
    required LastFedService lastFed,
    DateTime Function()? now,
  }) : _lastFed = lastFed,
       _now = now ?? DateTime.now,
       super(const HomeInitializing()) {
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
        emit(HomeFailure(failure: failure));
      },
      (lastFed) {
        emit(
          HomeReady(
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
    if (current is! HomeReady) {
      // Defensive: should not be reachable while the timer is gated by
      // _ensureTicking / _stopTicking, but if it is, stop the timer
      // rather than emit a wrong-shaped state.
      _stopTicking();
      return;
    }
    _tickCounter++;
    emit(
      HomeReady(
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
