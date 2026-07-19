// packages/time_spans/lib/src/measure/month_interval.dart

import '../calendar/month.dart';
import '../calendar/month_math.dart';
import '../policy/month_policy.dart';
import 'interval.dart';

/// An [Interval] that measures the whole-month span between its endpoints,
/// resolving day-of-month overflow through a [MonthPolicy].
///
/// Both endpoints are converted to UTC before [months] is measured, so
/// timezone offsets and daylight-saving transitions never shift a month
/// boundary. The count is order-independent and non-negative; use the
/// inherited [order] for direction and [exact] for the signed length.
///
/// A whole month is counted only when the later endpoint reaches or passes the
/// monthly anniversary of the earlier endpoint. Under [MonthPolicy.clamp] a
/// 31st-of-the-month anchor lands on the last day of a shorter target month
/// (resolved through [MonthMath] and [Month.lastDay]); under
/// [MonthPolicy.overflow] the surplus days spill into the following month.
final class MonthInterval extends Interval {
  /// Creates a month interval between [start] and [finish], resolving
  /// day-of-month overflow with [policy] (clamping by default).
  const MonthInterval({
    required DateTime start,
    required DateTime finish,
    this.policy = MonthPolicy.clamp,
  }) : super(start, finish);

  /// How a day-of-month that overflows a shorter target month is resolved
  /// while counting anniversaries.
  final MonthPolicy policy;

  /// The number of whole [policy]-adjusted calendar months spanned.
  ///
  /// Always non-negative; the direction lives on [order].
  int get months =>
      MonthMath.wholeMonthsBetween(earlier.toUtc(), later.toUtc(), policy);

  /// The number of whole calendar years spanned, derived from [months].
  int get years => months ~/ Month.values.length;

  /// The exact span actually consumed by the whole [months].
  ///
  /// Measured from [earlier] up to the last monthly anniversary at or before
  /// [later]; the leftover tail is `exact.abs() - consumed`.
  Duration get consumed {
    final origin = earlier.toUtc();
    return MonthMath.addMonths(origin, months, policy).difference(origin);
  }

  @override
  List<Object?> get props => [start, end, policy];
}
