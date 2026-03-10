// datetime_delta_text.dart

// ignore_for_file: comment_references, document_ignores

import 'package:extensions/datetime_ext/datetime_ext.dart';
import 'package:flutter/material.dart';

// ignore: lines_longer_than_80_chars
/// A widget that displays a formatted DateTimeDelta with optional leading widget.
///
/// This widget wraps a [Text] widget and automatically formats the provided
/// [DateTimeDelta] using the specified format string. It supports all [Text]
/// parameters except [data], which is derived from the formatted delta.
class DateTimeDeltaText extends StatelessWidget {

  const DateTimeDeltaText({
    required this.delta, super.key,
    this.format,
    this.leading,
    this.trailing,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });
  /// The DateTimeDelta to format and display
  final DateTimeDelta delta;

  /// Optional format string for DateTimeDelta.format()
  /// If null, uses the default format from DateTimeDelta.format()
  final String? format;

  /// Optional widget to display before the formatted text
  /// If null, no leading widget is shown
  final Widget? leading;

  /// Optional widget to display after the formatted text
  /// If null, no trailing widget is shown
  final Widget? trailing;

  // All Text widget parameters except 'data'
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final displayString = _getDisplayString();
    final textWidget = _buildText(displayString);

    // No leading or trailing widgets
    if (leading == null && trailing == null) {
      return textWidget;
    }

    // Build row with optional leading and trailing widgets
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?leading,
        textWidget,
        ?trailing,
      ],
    );
  }

  /// Formats the DateTimeDelta to create the display string
  String _getDisplayString() {
    if (format != null) {
      return delta.format(format!);
    }
    return delta.format();
  }

  /// Builds the Text widget with all the provided parameters
  Widget _buildText(String displayString) {
    return Text(
      displayString,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
