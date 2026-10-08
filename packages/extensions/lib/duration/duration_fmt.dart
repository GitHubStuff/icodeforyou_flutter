/// Human-readable formatting for [Duration] values.
///
/// Dart's built-in [Duration.toString] produces an ISO-ish
/// `H:MM:SS.mmmmmm` string that is useful for debugging but unsuitable for
/// display. This library adds [DurationFormatting], which renders a duration
/// as a compact, adaptive clock-style string whose precision grows with the
/// magnitude of the value.
library;

/// Formats a [Duration] as a compact, adaptive clock-style string.
///
/// The rendered format depends on the largest non-zero unit present in the
/// duration, so short durations stay short and long durations stay readable:
///
/// | Largest unit | Format              | Example       |
/// |--------------|---------------------|---------------|
/// | days         | `D HH:MM:SS`        | `3 04:05:06`  |
/// | hours        | `HH:MM:SS`          | `04:05:06`    |
/// | minutes      | `MM:SS`             | `05:06`       |
/// | seconds      | `S`                 | `6`           |
///
/// Day counts of 1,000 or more are grouped with thousands separators
/// (e.g. `1,200 00:00:00`). Hours, minutes and seconds are always
/// zero-padded to two digits **except** in the seconds-only form, which is
/// rendered without padding (`6`, not `06`).
///
/// Sub-second precision (milliseconds and microseconds) is discarded; the
/// value is truncated, not rounded.
///
/// This extension assumes a non-negative [Duration]. Negative durations are
/// not rejected, but because [Duration.inDays], [Duration.inHours], etc. all
/// carry the sign through [num.remainder], the resulting string is not
/// meaningful and should not be relied upon.
///
/// Example:
///
/// ```dart
/// const Duration(days: 2, hours: 3, minutes: 4, seconds: 5).toFormattedString();
/// // => '2 03:04:05'
///
/// const Duration(hours: 1, seconds: 9).toFormattedString();
/// // => '01:00:09'
///
/// const Duration(minutes: 7, seconds: 30).toFormattedString();
/// // => '07:30'
///
/// const Duration(seconds: 42, milliseconds: 999).toFormattedString();
/// // => '42'
///
/// Duration.zero.toFormattedString();
/// // => '0'
/// ```
extension DurationFormatting on Duration {
  /// Returns this duration as an adaptive clock-style string.
  ///
  /// The format is selected by the largest non-zero unit:
  ///
  /// * One or more days → `D HH:MM:SS`, where `D` is the whole-day count
  ///   formatted with thousands separators (e.g. `1,200 03:04:05`).
  /// * One or more hours (and no days) → `HH:MM:SS` (e.g. `03:04:05`).
  /// * One or more minutes (and no hours) → `MM:SS` (e.g. `04:05`).
  /// * Otherwise → the whole-second count with no padding (e.g. `5`).
  ///
  /// Fractional seconds are truncated. A [Duration.zero] input yields `'0'`.
  ///
  /// This method is pure and allocation-light: it performs no locale lookup
  /// and the thousands separator is always a comma (`,`), regardless of the
  /// current locale. If locale-aware grouping is required, format the day
  /// count with `intl`'s `NumberFormat` instead.
  ///
  /// See the [DurationFormatting] documentation for the full format table
  /// and behavioural caveats regarding negative durations.
  String toFormattedString({bool showLeadingZero = true}) {
    // Decompose the duration into its clock components. Each component is
    // reduced modulo the next-larger unit so that, for example, `hours` is
    // always in the range 0–23 rather than the total hour count.
    final int days = inDays;
    final int hours = inHours.remainder(24);
    final int minutes = inMinutes.remainder(60);
    final int seconds = inSeconds.remainder(60);

    // Zero-pad the sub-day components to two digits so that `4:5:6`
    // renders as `04:05:06`.
    final String secStr = seconds.toString().padLeft(2, '0');
    final String minStr = minutes.toString().padLeft(2, '0');
    final String hrStr = hours.toString().padLeft(2, '0');

    if (days > 0 || showLeadingZero) {
      // Insert a comma before every group of three digits that is followed
      // only by complete groups of three (e.g. 1200 -> 1,200, 1200000 ->
      // 1,200,000). `\B` prevents a leading comma; the lookahead ensures the
      // grouping is anchored to the end of the number.
      final String formattedDays = days.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );

      return '$formattedDays $hrStr:$minStr:$secStr';
    } else if (hours > 0) {
      return '$hrStr:$minStr:$secStr';
    } else if (minutes > 0) {
      return '$minStr:$secStr';
    } else {
      // Deliberately unpadded: a bare `5` reads better than `05` when there
      // is no higher unit to align against.
      return '$seconds';
    }
  }
}
