// packages/time_spans/lib/src/calendar/year.dart

import 'package:equatable/equatable.dart';

/// A single proleptic Gregorian calendar year, identified by its [year]
/// number, that resolves its own leapness and length.
///
/// This is the canonical home of the Gregorian leap rule for the whole
/// package: a year is a leap year when it is divisible by 4, except for
/// century years, which must also be divisible by 400 (so 2000 is a leap
/// year, 1900 is not). Every other type that needs to know whether a year is
/// leap — `Month.lastDay`, the interval and age measurements — reads it from
/// here rather than re-deriving the rule.
///
/// The [year] number is interpreted the same way as [DateTime.year]: positive
/// for CE, and the rule is applied proleptically to years outside the range
/// the Gregorian calendar was historically in use.
class Year extends Equatable {
  /// Creates a [Year] for the given calendar [year] number.
  const Year(this.year);

  /// The calendar year number, interpreted as in [DateTime.year].
  final int year;

  /// Whether this is a leap year under the Gregorian rule.
  ///
  /// `true` when [year] is divisible by 4, except century years, which must
  /// also be divisible by 400. For example 2000 and 2024 are leap years;
  /// 1900 and 2023 are not.
  bool get isLeapYear => year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  /// The number of days in this year: `366` if [isLeapYear], otherwise `365`.
  int get inDays => isLeapYear ? 366 : 365;

  @override
  List<Object?> get props => [year];

  @override
  bool get stringify => true;
}
