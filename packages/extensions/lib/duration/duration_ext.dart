import 'dart:core' show Duration;

extension DurationExt on Duration {
  /// Accepted minimun for an animation to not appear like a 'jump' 200ms
  static const Duration animate = Duration(milliseconds: 200);
}
