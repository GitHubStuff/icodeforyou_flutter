// packages/extensions/lib/duration/duration_ext.dart
import 'dart:core' show Duration;

/// {@template duration_ext.dart}
/// Duration constants and helpers for animation timing.
///
/// Members are accessed through the extension name —
/// `DurationExt.animate` — not through a [Duration] instance: static
/// members on an extension are namespaced by the extension, and the
/// `on Duration` clause plays no part in reaching them.
/// {@endtemplate}
extension DurationExt on Duration {
  /// The accepted minimum duration for an animation to read as motion
  /// rather than a 'jump'.
  ///
  /// Below roughly 200ms a transition completes faster than the eye
  /// tracks it, so the change registers as an instant swap. Use this as
  /// the floor when a fast animation is wanted but a perceptible one is
  /// required.
  static const Duration animate = Duration(milliseconds: 200);
}
