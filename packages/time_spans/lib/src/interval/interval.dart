/// An anchored span defined by two endpoints.
///
/// Unlike a [Duration] (a length with no position), an [Interval] knows
/// *where* it sits on the timeline.
sealed class Interval {
  const Interval._(this.start, this.end);

  /// Inclusive start of the span.
  final DateTime start;

  /// Exclusive end of the span.
  final DateTime end;

  /// The exact, anchored length between [start] and [end].
  Duration get exact => end.difference(start);
}
