// packages/ext_duration/lib/src/ext_duration.dart

import 'package:ext_duration/src/formatter/duration_formatter.dart'
    show DurationFormatter;

/// Convenience extension so callers can write `duration.format(pattern)`.
extension ExtDuration on Duration {
  /// Formats this duration with a `sprintf`-style [pattern].
  ///
  /// See [DurationFormatter] for the supported conversions and flags.
  String format(String pattern) => DurationFormatter(pattern).format(this);
}
