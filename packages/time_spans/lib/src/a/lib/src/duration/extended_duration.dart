// packages/time_spans/lib/src/duration/extended_duration.dart

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../calendar/average_month.dart';

/// Months in a year, used to normalize [ExtendedDuration.years] and
/// [ExtendedDuration.months] against each other.
const int _monthsPerYear = 12;

/// Days in a week, used when folding [ExtendedDuration.weeks] into days.
const int _daysPerWeek = 7;

/// Hours in a day.
const int _hoursPerDay = 24;

/// Minutes in an hour.
const int _minutesPerHour = 60;

/// Seconds in a minute.
const int _secondsPerMinute = 60;

/// Milliseconds in a second.
const int _millisecondsPerSecond = 1000;

/// Microseconds in a millisecond.
const int _microsecondsPerMillisecond = 1000;

/// A normalized, component-wise breakdown of a span of time.
///
/// Every field is a remainder within its own unit ([hours] is `0..23`,
/// [minutes] is `0..59`, and so on), with overflow carried into the
/// next-larger unit. The fields do not overlap: each holds only what is
/// left after the larger units have taken their share. Because [props] is
/// built from these fields, construction goes through normalizing factories
/// so that equality stays meaningful — there is no public generative
/// constructor.
///
/// Three construction paths exist:
///
/// * [ExtendedDuration.from] — an elapsed [Duration]; no calendar fields,
///   always exact.
/// * [ExtendedDuration.period] — an unanchored calendar span; [years] and
///   [months] are present but [resolvedYearDays] / [resolvedMonthDays] stay
///   `null`, so [toDuration] estimates them via [averageDaysPerMonth].
/// * a calendar-aware factory anchored to real dates that populates the
///   resolved counts for exact conversion.
class ExtendedDuration extends Equatable {
  const ExtendedDuration._({
    this.years = 0,
    this.months = 0,
    this.weeks = 0,
    this.days = 0,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
    this.milliseconds = 0,
    this.microseconds = 0,
    this.resolvedYearDays,
    this.resolvedMonthDays,
  });

  /// Breaks [duration] down into normalized [weeks] through [microseconds].
  ///
  /// [years] and [months] stay `0` and [resolvedYearDays] /
  /// [resolvedMonthDays] stay `null`: a [Duration] is elapsed microseconds
  /// with no calendar anchor, so whole years and months are not derivable
  /// from it. For a negative [duration] every component shares its sign.
  factory ExtendedDuration.from(Duration duration) {
    final clock = _decompose(duration);
    return ExtendedDuration._(
      weeks: clock.weeks,
      days: clock.days,
      hours: clock.hours,
      minutes: clock.minutes,
      seconds: clock.seconds,
      milliseconds: clock.milliseconds,
      microseconds: clock.microseconds,
    );
  }

  /// Builds an unanchored calendar span from the given components.
  ///
  /// All fields are normalized — surplus months carry into [years], and the
  /// sub-month units are re-decomposed so each lands in its own range with a
  /// shared sign. [resolvedYearDays] / [resolvedMonthDays] are `null` by
  /// definition: an unanchored span has no dates to resolve against, so
  /// [toDuration] estimates the calendar portion.
  factory ExtendedDuration.period({
    int years = 0,
    int months = 0,
    int weeks = 0,
    int days = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
    int milliseconds = 0,
    int microseconds = 0,
  }) {
    final totalMonths = years * _monthsPerYear + months;
    final clock = _decompose(
      Duration(
        days: weeks * _daysPerWeek + days,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
        microseconds: microseconds,
      ),
    );
    return ExtendedDuration._(
      years: totalMonths ~/ _monthsPerYear,
      months: totalMonths.remainder(_monthsPerYear),
      weeks: clock.weeks,
      days: clock.days,
      hours: clock.hours,
      minutes: clock.minutes,
      seconds: clock.seconds,
      milliseconds: clock.milliseconds,
      microseconds: clock.microseconds,
    );
  }

  /// Constructs an instance from explicit, already-normalized components.
  ///
  /// Test-only seam: production code reaches [ExtendedDuration] through
  /// [from], [period], or a calendar-aware factory, all of which normalize.
  /// Leave [resolvedYearDays] / [resolvedMonthDays] `null` to exercise the
  /// estimate path, or supply them to exercise the exact path.
  @visibleForTesting
  factory ExtendedDuration.ofComponents({
    int years = 0,
    int months = 0,
    int weeks = 0,
    int days = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
    int milliseconds = 0,
    int microseconds = 0,
    int? resolvedYearDays,
    int? resolvedMonthDays,
  }) {
    return ExtendedDuration._(
      years: years,
      months: months,
      weeks: weeks,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
      microseconds: microseconds,
      resolvedYearDays: resolvedYearDays,
      resolvedMonthDays: resolvedMonthDays,
    );
  }

  /// Splits [duration] into normalized sub-month components, shared by the
  /// factories that need a canonical clock breakdown.
  static ({
    int weeks,
    int days,
    int hours,
    int minutes,
    int seconds,
    int milliseconds,
    int microseconds,
  })
  _decompose(Duration duration) => (
    weeks: duration.inDays ~/ _daysPerWeek,
    days: duration.inDays.remainder(_daysPerWeek),
    hours: duration.inHours.remainder(_hoursPerDay),
    minutes: duration.inMinutes.remainder(_minutesPerHour),
    seconds: duration.inSeconds.remainder(_secondsPerMinute),
    milliseconds: duration.inMilliseconds.remainder(_millisecondsPerSecond),
    microseconds: duration.inMicroseconds.remainder(
      _microsecondsPerMillisecond,
    ),
  );

  /// Whole calendar years in the span.
  ///
  /// Calendar-relative: not convertible to a fixed microsecond count, and
  /// always `0` when built via [ExtendedDuration.from]. Converted using
  /// [resolvedYearDays] when present, otherwise estimated.
  final int years;

  /// Whole calendar months remaining after [years]; normalized to `0..11`.
  ///
  /// Calendar-relative, like [years]; always `0` when built via
  /// [ExtendedDuration.from]. Converted using [resolvedMonthDays] when
  /// present, otherwise estimated.
  final int months;

  /// Whole weeks remaining after the calendar fields.
  final int weeks;

  /// Whole days remaining after [weeks]; `0..6` when [weeks] is populated.
  final int days;

  /// Whole hours remaining after [days]; normalized to `0..23`.
  final int hours;

  /// Whole minutes remaining after [hours]; normalized to `0..59`.
  final int minutes;

  /// Whole seconds remaining after [minutes]; normalized to `0..59`.
  final int seconds;

  /// Whole milliseconds remaining after [seconds]; normalized to `0..999`.
  final int milliseconds;

  /// Remaining microseconds after [milliseconds]; normalized to `0..999`.
  final int microseconds;

  /// Days the calendar factory resolved [years] to, or `null` when the span
  /// is unanchored.
  ///
  /// When `null`, [toDuration] estimates the [years] contribution instead of
  /// using a concrete figure.
  final int? resolvedYearDays;

  /// Days the calendar factory resolved [months] to, or `null` when the span
  /// is unanchored.
  ///
  /// When `null`, [toDuration] estimates the [months] contribution instead of
  /// using a concrete figure.
  final int? resolvedMonthDays;

  /// Total days contributed by the calendar fields.
  ///
  /// Resolved units use their stored day counts exactly; unresolved units are
  /// folded into a single month total and estimated with one
  /// [averageDaysPerMonth] tier, so a mixed span never blends two averaging
  /// tiers.
  int get _calendarDays {
    final resolved = (resolvedYearDays ?? 0) + (resolvedMonthDays ?? 0);
    final unresolvedMonths =
        (resolvedYearDays == null ? years * _monthsPerYear : 0) +
        (resolvedMonthDays == null ? months : 0);
    if (unresolvedMonths == 0) {
      return resolved;
    }
    final estimated =
        (unresolvedMonths * averageDaysPerMonth(unresolvedMonths)).round();
    return resolved + estimated;
  }

  /// Returns a [Duration] for this span.
  ///
  /// The conversion is exact for every resolved field; any unresolved
  /// calendar field is approximated via [averageDaysPerMonth]. A span built
  /// from [ExtendedDuration.from] is therefore always exact, since it carries
  /// no calendar fields to estimate.
  Duration toDuration() => Duration(
    days: _calendarDays + (weeks * _daysPerWeek) + days,
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
    microseconds: microseconds,
  );

  @override
  List<Object?> get props => [
    years,
    months,
    weeks,
    days,
    hours,
    minutes,
    seconds,
    milliseconds,
    microseconds,
    resolvedYearDays,
    resolvedMonthDays,
  ];

  @override
  bool get stringify => true;
}
