// extensions/lib/src/datetime_ordering.dart

/// Describes the temporal relationship between two [DateTime] objects.
enum DateTimeOrder {
  /// The start event occurs before the end event.
  before,

  /// The start event and end event occur at the same time.
  now,

  /// The start event occurs after the end event.
  after;

  /// Returns the [DateTimeOrder] of [startEvent] relative to [endEvent].
  static DateTimeOrder direction(DateTime startEvent, DateTime endEvent) {
    if (startEvent.isBefore(endEvent)) return DateTimeOrder.before;
    if (startEvent.isAfter(endEvent)) return DateTimeOrder.after;
    return DateTimeOrder.now;
  }
}
