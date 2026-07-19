// packages/time_spans/lib/src/measure/legal_age.dart

import 'package:equatable/equatable.dart';

import '../calendar/year.dart';
import '../policy/leap_day_policy.dart';

/// 29 February — the only birth date that does not recur every year and so is
/// governed by a [LeapDayPolicy].
const int _leapDayOfFebruary = 29;

/// Whole-year age between a [birth] date and an [asOf] date, using the
/// literal-anniversary rule that civil age reckoning requires.
///
/// A person is `N` years old once [asOf] reaches the calendar date whose month
/// and day equal those of [birth]. This deliberately is **not** an `Interval`:
/// it has no anchored length, performs no UTC conversion, and reads only the
/// civil date. Unlike `YearInterval`, there is no end-of-month clamp — a
/// 28-February birth has a 28-February birthday every year, leap or not. The
/// single date that does not recur is 29 February, governed by [LeapDayPolicy].
///
/// ## Date-only by design
///
/// Only the year, month, and day of each input are read; time-of-day and
/// timezone are ignored. Age is a civil-date concept, so callers should pass
/// calendar dates (e.g. `DateTime(2002, 2, 28)`). No UTC conversion is
/// performed, because shifting to UTC could move an evening birth onto the
/// following civil date and report the wrong birthday.
///
/// ## Example
///
/// ```dart
/// final age = LegalAge.of(
///   birth: DateTime(2002, 2, 28),
///   asOf: DateTime(2020, 2, 28),
/// );
/// age.years;          // 18  (literal 28-Feb birthday, no clamp)
/// age.isAtLeast(18);  // true
/// ```
class LegalAge extends Equatable {
  /// Computes the age at [asOf] for someone born on [birth].
  ///
  /// Reads only the calendar date (year, month, day) of each argument. The
  /// [leapDayPolicy] resolves the birthday of a 29-February birth in common
  /// years and is ignored for every other birth date.
  factory LegalAge.of({
    required DateTime birth,
    required DateTime asOf,
    LeapDayPolicy leapDayPolicy = LeapDayPolicy.feb28,
  }) {
    final candidate = asOf.year - birth.year;
    if (candidate <= 0) return const LegalAge._(years: 0);

    final (birthdayMonth, birthdayDay) = _birthdayIn(
      asOf.year,
      birthMonth: birth.month,
      birthDay: birth.day,
      policy: leapDayPolicy,
    );

    final reached =
        asOf.month > birthdayMonth ||
        (asOf.month == birthdayMonth && asOf.day >= birthdayDay);

    return LegalAge._(years: reached ? candidate : candidate - 1);
  }

  /// Creates an age from an already-computed year count.
  ///
  /// Private so that [LegalAge.of] is the single source of truth.
  const LegalAge._({required this.years});

  /// Completed whole years of age. Never negative; an [asOf] earlier than
  /// [birth] yields zero.
  final int years;

  /// Whether this age meets or exceeds [minimumYears] — e.g. `isAtLeast(18)`
  /// or `isAtLeast(21)` for threshold gating.
  bool isAtLeast(int minimumYears) => years >= minimumYears;

  /// Returns the `(month, day)` on which a [birthMonth]/[birthDay] birth falls
  /// in [targetYear].
  ///
  /// The literal month and day are returned unless the birth is 29 February
  /// and [targetYear] is common, in which case [policy] decides between
  /// 28 February and 1 March. Leapness is resolved through [Year].
  static (int month, int day) _birthdayIn(
    int targetYear, {
    required int birthMonth,
    required int birthDay,
    required LeapDayPolicy policy,
  }) {
    final isLeaplingInCommonYear =
        birthMonth == DateTime.february &&
        birthDay == _leapDayOfFebruary &&
        !Year(targetYear).isLeapYear;
    if (!isLeaplingInCommonYear) return (birthMonth, birthDay);

    return switch (policy) {
      LeapDayPolicy.feb28 => (DateTime.february, 28),
      LeapDayPolicy.mar1 => (DateTime.march, 1),
    };
  }

  @override
  List<Object?> get props => [years];

  @override
  bool get stringify => true;
}
