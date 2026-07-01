// extensions/lib/src/string_ext.dart
import 'package:flutter/painting.dart';

/// Default font size used by [StringExt.renderSize] (14.0 logical pixels).
const _kDefaultFontSize = 14.0;

/// Default line count used by [StringExt.renderSize] (1), matching the common
/// single-line text field.
const _kDefaultMaxLines = 1;

/// Convenience helpers on [String] for measuring rendered text and parsing
/// ISO 8601 dates.
extension StringExt on String {
  /// Measures the space this string occupies when painted.
  ///
  /// Lays the string out with the supplied [fontWeight], [fontSize],
  /// [maxLines], and [textDirection], then returns the resulting `width` and
  /// `height` in logical pixels as a record.
  ///
  /// Internally this performs a real [TextPainter] layout, so cache the result
  /// when measuring the same string repeatedly rather than calling it on every
  /// build.
  ///
  /// ```dart
  /// final (:width, :height) = 'Hello'.renderSize(fontSize: 16);
  /// ```
  ///
  /// {@template string_ext.renderSize.params}
  /// - [fontWeight] defaults to [FontWeight.normal].
  /// - [fontSize] defaults to `14.0`.
  /// - [maxLines] defaults to `1`.
  /// - [textDirection] defaults to [TextDirection.ltr].
  /// {@endtemplate}
  ({double width, double height}) renderSize({
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = _kDefaultFontSize,
    int maxLines = _kDefaultMaxLines,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final TextStyle textStyle = TextStyle(
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
    final painter = TextPainter(
      text: TextSpan(
        text: this,
        style: textStyle,
      ),
      maxLines: maxLines,
      textDirection: textDirection,
    )..layout();
    return (width: painter.width, height: painter.height);
  }

  /// Parses this string as an ISO 8601 date.
  ///
  /// Returns the number of microseconds elapsed since the Unix epoch
  /// (`1970-01-01T00:00:00Z`), or `null` when the string is not a valid
  /// [DateTime] representation.
  ///
  /// Parsing is delegated to [DateTime.parse]; a [FormatException] from an
  /// invalid string is caught and surfaced as `null`.
  ///
  /// ```dart
  /// '2024-01-01'.toMicrosecondsOrNull(); // 1704067200000000
  /// 'not a date'.toMicrosecondsOrNull(); // null
  /// ```
  int? toMicrosecondsOrNull() {
    try {
      return DateTime.parse(this).microsecondsSinceEpoch;
    } on FormatException {
      return null;
    }
  }
}
