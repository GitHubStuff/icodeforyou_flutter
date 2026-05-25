// packages/extensions/lib/int_ext/int_ext.dart
import 'package:flutter/material.dart' show Color;

/// Extensions on [int] for common type conversions.
extension IntExt on int {
  /// Interprets this integer as a 32-bit ARGB value and returns the
  /// corresponding [Color].
  Color toColor() => Color(this);

  /// Interprets this integer as a UTC microsecond epoch timestamp and
  /// returns the corresponding [DateTime].
  DateTime toUtc() => DateTime.fromMicrosecondsSinceEpoch(this, isUtc: true);
}
