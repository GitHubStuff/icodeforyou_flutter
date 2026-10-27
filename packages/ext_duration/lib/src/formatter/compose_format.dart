// packages/ext_duration/lib/src/formatter/compose_format.dart

part of '../ext_duration.dart';

/// The largest unit that appears in a composed template.
///
/// Because [ExtDuration.composeFormat] always emits every unit *smaller* than
/// the leading one, the leading unit alone determines the body of the
/// template. This enum makes that invariant explicit instead of encoding it
/// in a mutable flag threaded through a cascade of conditionals.
enum _LeadingUnit {
  days,
  hours,
  minutes,
  seconds,
}

/// Private helpers backing [ExtDuration.composeFormat].
///
/// Kept as a separate extension so the public [ExtDuration] surface stays
/// limited to what callers are meant to use.
extension _ComposeFormat on Duration {
  /// Returns the template sign prefix for this duration.
  ///
  /// Negative durations always yield `%n`. Non-negative durations yield `+`
  /// when [showPlusSign] is `true`, otherwise an empty string.
  String _templateSign({required bool showPlusSign}) {
    if (isNegative) {
      return '%n';
    }
    return showPlusSign ? '+' : '';
  }

  /// Determines the largest unit present in this duration, which **must** be
  /// non-negative — callers pass `abs()`.
  ///
  /// [showLeaderZero] forces [_LeadingUnit.days] regardless of magnitude.
  ///
  /// No modulus is needed: if days are not present then `inHours < 24`, and
  /// if hours are not present then `inMinutes < 60`, so each `in…` accessor
  /// is already the within-unit value at the point it is checked.
  _LeadingUnit _leadingUnit({required bool showLeaderZero}) {
    if (showLeaderZero || inDays > 0) {
      return _LeadingUnit.days;
    }
    if (inHours > 0) {
      return _LeadingUnit.hours;
    }
    if (inMinutes > 0) {
      return _LeadingUnit.minutes;
    }
    return _LeadingUnit.seconds;
  }
}

/// Returns the template body for the given leading [unit].
///
/// Every unit smaller than [unit] is included and padded; [unit] itself is
/// unpadded, except that hours honour [padHours] in every position.
String _templateBody(_LeadingUnit unit, {required bool padHours}) {
  final hours = padHours ? '%02h:' : '%h:';
  return switch (unit) {
    _LeadingUnit.days => '%d $hours%02m:%02s',
    _LeadingUnit.hours => '$hours%02m:%02s',
    _LeadingUnit.minutes => '%m:%02s',
    _LeadingUnit.seconds => '%s',
  };
}
