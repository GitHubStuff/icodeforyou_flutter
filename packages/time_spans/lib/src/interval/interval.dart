// packages/time_spans/lib/src/interval/interval.dart

/// An anchored span defined by two endpoints.
///
/// Unlike a [Duration] (a length with no position), an [Interval] knows
/// *where* it sits on the timeline.
///
/// `abstract base` rather than `sealed`: sealed restricts subtypes to
/// this library, which made the class uninstantiable with
/// [YearInterval]-style subtypes living in their own files — dead code
/// that no test could reach. `base` keeps the discipline that matters
/// (subtypes must `extends`, never `implements`, so [exact] cannot be
/// re-implemented inconsistently) while letting each concrete interval
/// own its file. If exhaustive switching over the hierarchy is ever
/// needed, convert to a parts-based sealed library instead.
abstract base class Interval {
  /// Creates an anchored span from [start] to [end].
  const Interval(this.start, this.end);

  /// Inclusive start of the span.
  final DateTime start;

  /// Exclusive end of the span.
  final DateTime end;

  /// The exact, anchored length between [start] and [end].
  Duration get exact => end.difference(start);
}
