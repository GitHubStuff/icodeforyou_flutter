// extensions/lib/src/string_ext.dart
import 'package:flutter/painting.dart';

const _kDefaultFontSize = 14.0;
const _kDefaultMaxLines = 1;

/// Extensions on [String] for layout measurement and date parsing.
extension StringExt on String {
  /// Returns the pixel width and height required to render this string
  /// with the given [fontWeight], [fontSize], [maxLines], and [textDirection].
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

  /// Parses this string as an ISO 8601 date and returns microseconds since
  /// epoch, or `null` if the string is not a valid date format.
  int? toMicrosecondsOrNull() {
    try {
      return DateTime.parse(this).microsecondsSinceEpoch;
    } on FormatException {
      return null;
    }
  }
}
