// packages/time_spans/lib/src/measure/interval.dart

import 'package:equatable/equatable.dart';

import '../comparison/datetime_order.dart';

/// An anchored span defined by two endpoints.
///
/// Unlike a [Duration] (a length with no position), an [Interval] knows
/// *where* it sits on the timeline. It stores the endpoints exactly as the
/// caller supplied them — argument order is preserved — and exposes the
/// direction through [order] and the order-independent endpoints through
/// [earlier] and [later]. Subtypes add calendar-aware measurements
/// (`YearInterval.years`, `MonthInterval.months`) on top of this shared base.
///
/// Two intervals are equal when their [start] and [end] are equal; subtypes
/// that carry extra configuration (such as a `MonthPolicy`) extend [props].
abstract base class Interval extends Equatable {
  /// Creates an interval from its [start] and [end] endpoints, kept in the
  /// order given.
  const Interval(this.start, this.end);

  /// The start endpoint, as supplied by the caller.
  final DateTime start;

  /// The end endpoint, as supplied by the caller.
  final DateTime end;

  /// The signed, anchored length from [start] to [end].
  ///
  /// Negative when [start] is later than [end]; use [Duration.abs] for the
  /// magnitude, or [order] for the direction alone.
  Duration get exact => end.difference(start);

  /// The temporal direction of [start] relative to [end].
  DateTimeOrder get order => DateTimeOrder.direction(start, end);

  /// The earlier of the two endpoints, regardless of argument order.
  DateTime get earlier => start.isAfter(end) ? end : start;

  /// The later of the two endpoints, regardless of argument order.
  DateTime get later => start.isAfter(end) ? start : end;

  @override
  List<Object?> get props => [start, end];

  @override
  bool get stringify => true;
}
