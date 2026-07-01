// packages/time_spans/lib/src/policy/lead_day_policy.dart

/// Resolves the birthday of a 29-February ("leapling") birth in common
/// (non-leap) years, where 29 February does not exist.
///
/// This choice is jurisdiction-dependent and has no universally correct value,
/// so it is an explicit parameter rather than a buried default behaviour.
enum LeapDayPolicy {
  /// The birthday falls on 28 February in common years — the leapling ages on
  /// the last existing day of February. Common in many jurisdictions and the
  /// default for general age reckoning.
  feb28,

  /// The birthday falls on 1 March in common years — the leapling ages the day
  /// after February ends. Used in England and Wales, among others.
  mar1,
}
