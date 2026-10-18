// packages/counter_ring/lib/src/cubit/counter_ring_status.dart

/// Lifecycle phase of a counter ring.
///
/// Transitions are driven by the cubit: `idle` → `running` on start,
/// `running` → `stopped` on stop (and back to `running` on resume),
/// `running` → `finished` on reaching the terminal value, and any phase
/// → `idle` on cancel.
enum CounterRingStatus {
  /// Not yet started, or rewound by cancel. The value sits at the start.
  idle,

  /// Actively advancing on each tick.
  running,

  /// Paused at the current value; can be resumed.
  stopped,

  /// Reached the terminal value. Cannot advance further without a reset.
  finished,
}
