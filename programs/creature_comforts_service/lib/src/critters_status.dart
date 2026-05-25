// packages/creature_comforts_service/lib/src/critters_status.dart

/// The lifecycle status of the household critters, derived from how
/// long it has been since they were last fed.
///
/// A domain concept, not a UI concept. Presentation layers map each
/// case to their own visuals; the classification itself lives here so
/// every consumer agrees on it.
enum CrittersStatus {
  /// Last feeding is within [crittersDeathThreshold].
  alive,

  /// Last feeding exceeds [crittersDeathThreshold].
  dead,
}

/// Elapsed-time threshold past which the critters are [CrittersStatus.dead].
///
/// Top-level constant so tests, copy, and any "N days remaining"
/// affordance reference the same value.
const Duration crittersDeathThreshold = Duration(days: 7);

/// Pure classification of [lastFed] into a [CrittersStatus].
///
/// [now] is injectable so tests don't depend on wall-clock time.
/// Comparison runs in UTC to side-step DST and timezone surprises
/// around the week-long boundary.
///
/// A null or future-dated [lastFed] resolves to [CrittersStatus.alive]:
/// "never recorded" shouldn't punish a fresh install, and clock skew
/// shouldn't flip the UI to a death screen.
CrittersStatus crittersStatusFor(
  DateTime? lastFed, {
  DateTime? now,
}) {
  if (lastFed == null) return CrittersStatus.alive;
  final reference = (now ?? DateTime.now()).toUtc();
  final fed = lastFed.toUtc();
  if (!fed.isBefore(reference)) return CrittersStatus.alive;
  final elapsed = reference.difference(fed);
  return elapsed > crittersDeathThreshold
      ? CrittersStatus.dead
      : CrittersStatus.alive;
}
