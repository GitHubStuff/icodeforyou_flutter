import 'dart:math';

import 'package:duration_widget/duration_widget.dart'
    show TickingDurationWidget;
import 'package:extensions/extensions.dart' show ColorExt;
import 'package:flutter/material.dart';

/// A centred caption/detail pair that always fits inside a circle of
/// [radius]: over-long strings are truncated with an ellipsis, and when the
/// circle is too small for both lines the pair is scaled down rather than
/// overflowing.
class TitleSubtitleText extends StatelessWidget {
  const TitleSubtitleText({
    required this.title,
    required this.backgroundColor,
    required this.radius,
    this.caption,
    this.titleFontSize = 24,
    this.subtitleFontSize = 20,
    this.captionFontSize = 18,
    super.key,
  }) : assert(radius > 0, 'radius must be positive');

  final String title;
  final String? caption;
  final Color backgroundColor;
  final double radius;
  final double titleFontSize;
  final double subtitleFontSize;
  final double captionFontSize;

  @override
  Widget build(BuildContext context) {
    final constrastColor = backgroundColor.contrastingColor();

    final baseStyle = TextStyle(
      color: constrastColor,
      fontWeight: FontWeight.bold,
    );

    // Largest square that fits inside the circle.
    final side = radius * sqrt2;

    return SizedBox(
      width: side,
      height: side,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: side,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: baseStyle.copyWith(fontSize: titleFontSize),
              ),
              TickingDurationWidget(
                eventTime: DateTime(1960, 3),
                currentTime: DateTime(2026, 9),
                textStyle: baseStyle.copyWith(fontSize: subtitleFontSize),
              ),
              if (caption != null)
                Text(
                  caption!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: baseStyle.copyWith(fontSize: captionFontSize),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
