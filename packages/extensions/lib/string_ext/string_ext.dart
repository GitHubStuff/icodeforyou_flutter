// lib/src/string_ext.dart

import 'package:flutter/painting.dart';

const _kDefaultFontSize = 14.0;
const _kDefaultMaxLines = 1;

extension StringExt on String {
  /// The number pixels (height/width) needed to render a string
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

  /// Converts string to microseconds since epoch with error handling
  int? toMicrosecondsOrNull() {
    try {
      return DateTime.parse(this).microsecondsSinceEpoch;
    } on FormatException {
      return null;
    }
  }
}
