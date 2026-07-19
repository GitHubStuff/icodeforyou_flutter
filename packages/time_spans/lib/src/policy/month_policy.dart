// packages/time_spans/lib/src/policy/month_policy.dart

/// Resolves a day-of-month that does not exist in the target month after
/// month or year arithmetic — for example the result of adding one month to
/// 31 January, since February has no 31st.
///
/// Like [LeapDayPolicy], this choice has no universally correct value, so it
/// is an explicit parameter rather than a buried default.
enum MonthPolicy {
  /// Pin the result to the last valid day of the target month.
  ///
  /// 31 January + 1 month → 28 February (29 in a leap year); 31 March +
  /// 1 month → 30 April. The conventional default for calendar arithmetic.
  clamp,

  /// Carry the excess days into the following month.
  ///
  /// 31 January + 1 month → 3 March, since the 3 days beyond 28 February
  /// spill over. Mirrors the rollover behaviour of constructing
  /// `DateTime(year, month + 1, day)` with an out-of-range day.
  overflow,
}
