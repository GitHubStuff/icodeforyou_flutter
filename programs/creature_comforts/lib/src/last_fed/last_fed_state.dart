// programs/creature_comforts/lib/src/last_fed/last_fed_state.dart
import 'package:creature_comforts_service/creature_comforts_service.dart'
    show CrittersStatus, LastFedFailure;
import 'package:equatable/equatable.dart';

/// State machine for [LastFedCubit].
///
/// Three terminal shapes correspond to the three render modes any
/// last-fed-aware widget needs:
///
///  - [LastFedInitializing] — first stream event has not yet arrived;
///    consumers show loading affordances.
///  - [LastFedFailureState]  — stream emitted a [LastFedFailure];
///    consumers render error affordances. Carries the failure so they
///    can surface its message.
///  - [LastFedReady]         — a timestamp has been observed. Carries
///    the timestamp, the derived [CrittersStatus] (single source of
///    truth for the alive/dead rule), and a [tick] counter incremented
///    by the cubit every minute so widgets that render elapsed-time
///    strings rebuild without the cubit re-emitting equal state.
///
/// Sealed so widget-side `switch` expressions are exhaustive; adding a
/// new state forces every consumer to acknowledge it.
sealed class LastFedState extends Equatable {
  const LastFedState();

  @override
  List<Object?> get props => const [];
}

/// Cubit is awaiting the first event from `LastFedService.watch()`.
final class LastFedInitializing extends LastFedState {
  const LastFedInitializing();
}

/// The most recent stream event was a failure.
///
/// Held as state (rather than fired as a one-shot side effect) so the
/// error remains visible until the next successful emission replaces
/// it — preserves the previous `_FailureBlock` behavior in
/// `LastFedDisplay`.
///
/// Named with the `State` suffix to disambiguate from the
/// service-layer [LastFedFailure] type it wraps.
final class LastFedFailureState extends LastFedState {
  const LastFedFailureState({required this.failure});

  final LastFedFailure failure;

  @override
  List<Object?> get props => [failure];
}

/// A last-fed timestamp has been observed.
///
/// [status] is recomputed by the cubit on every state transition (new
/// timestamp arrival or minute tick) so consumers never re-derive it
/// and the alive/dead rule stays in exactly one place
/// ([crittersStatusFor]).
///
/// [tick] is a monotonically increasing counter the cubit increments
/// once per minute to drive elapsed-string rebuilds in
/// `LastFedDisplay` without changing [lastFed]. Including it in
/// equality is intentional: equal-but-tick-bumped states must still
/// trigger rebuilds for time-dependent renders.
final class LastFedReady extends LastFedState {
  const LastFedReady({
    required this.lastFed,
    required this.status,
    required this.tick,
  });

  /// Timestamp of the most recent feeding, in UTC as delivered by the
  /// service stream.
  final DateTime lastFed;

  /// Cached classification of [lastFed]. Single source of truth for the
  /// alive/dead rule across every consumer of this state.
  final CrittersStatus status;

  /// Minute-cadence counter; bumped by the cubit so consumers rendering
  /// elapsed strings rebuild without [lastFed] changing.
  final int tick;

  @override
  List<Object?> get props => [lastFed, status, tick];
}
