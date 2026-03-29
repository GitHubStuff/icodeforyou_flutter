// extensions/lib/src/datetime_ordering.dart

/// Describes the temporal relationship between two [DateTime] objects.
enum DateTimeOrdering {
  /// The start event occurs before the end event.
  before,

  /// The start event and end event occur at the same time.
  now,

  /// The start event occurs after the end event.
  after
  ;

  /// Returns the [DateTimeOrdering] of [startEvent] relative to [endEvent].
  static DateTimeOrdering direction(DateTime startEvent, DateTime endEvent) {
    if (startEvent.isBefore(endEvent)) return DateTimeOrdering.before;
    if (startEvent.isAfter(endEvent)) return DateTimeOrdering.after;
    return DateTimeOrdering.now;
  }
}
