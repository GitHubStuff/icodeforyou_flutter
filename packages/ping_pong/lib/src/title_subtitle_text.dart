// packages/ping_pong/lib/src/title_subtitle_text.dart

// TODO(steven): This is rubbish, its is a hack to see ping-pong ball content
import 'dart:math';

import 'package:duration_widget/duration_widget.dart'
    show TickingDurationWidget;
import 'package:extensions/extensions.dart' show ColorExt;
import 'package:flutter/material.dart';
import 'package:neon/neon.dart' show NeonBorderExtension, NeonText;

/// A vertically stacked, centred block of text sized to fit inside a circle
/// of [radius].
///
/// The block is laid out inside the largest square that fits the circle
/// (side `radius × √2`) and wrapped in a [FittedBox] with
/// [BoxFit.scaleDown], so when the circle is too small for every line the
/// whole stack shrinks uniformly instead of overflowing. Individual lines are
/// clamped to a single line and fade at the edge.
///
/// The stack currently renders, top to bottom:
///
/// 1. A fixed neon header reading `GYM`, drawn with [NeonText] and a
///    [NeonBorderExtension.withNeonBorder] outline.
/// 2. A [TickingDurationWidget] counting the elapsed time between a fixed
///    `eventTime` of March 1960 and a fixed `currentTime` of September 2026,
///    styled at [subtitleFontSize].
/// 3. An optional [caption], shown only when non-null, styled at
///    [captionFontSize].
///
/// Text colour is derived from [backgroundColor] via
/// [ColorExt.contrastingColor] so the block stays legible on any disc.
///
/// > **Note:** [title] and [titleFontSize] are required / configurable but
/// > are **not** currently used by [build]; the header and duration are
/// > hard-coded. Treat them as reserved until the header is wired up.
///
/// ## Example
///
/// ```dart
/// TitleSubtitleText(
///   title: 'Elapsed',
///   caption: 'since opening',
///   backgroundColor: Colors.deepPurple,
///   radius: 120,
/// )
/// ```
///
/// See also:
///
/// * [FittedBox], which provides the scale-down behaviour.
/// * [NeonText], which renders the glowing header.
/// * [TickingDurationWidget], which renders the live duration line.
class TitleSubtitleText extends StatelessWidget {
  /// Creates a text block that fits inside a circle of [radius].
  ///
  /// [radius] must be strictly positive; the constructor asserts this.
  ///
  /// [titleFontSize], [subtitleFontSize], and [captionFontSize] default to
  /// 24, 20, and 18 logical pixels respectively. These are the sizes *before*
  /// any scale-down applied by the enclosing [FittedBox].
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

  /// The primary heading for the block.
  ///
  /// **Currently unused.** [build] renders a fixed `GYM` neon header instead.
  /// The field is retained so callers do not break when the header becomes
  /// configurable.
  final String title;

  /// Optional trailing line rendered beneath the duration.
  ///
  /// When `null`, no caption row is laid out at all — the stack is two lines
  /// high instead of three. When provided it is centred, limited to one line,
  /// and fades at the edge if it is wider than the available square.
  final String? caption;

  /// The colour of the surface this block is drawn on.
  ///
  /// Not painted by this widget. It is used solely to pick a contrasting text
  /// colour through [ColorExt.contrastingColor], so pass the colour of the
  /// disc the block will sit on.
  final Color backgroundColor;

  /// The radius of the circle the block must fit inside, in logical pixels.
  ///
  /// Must be greater than zero. The block occupies a square of side
  /// `radius × √2` — the largest square inscribable in that circle — so the
  /// corners of the text never poke outside the disc.
  final double radius;

  /// Intended font size for [title], in logical pixels.
  ///
  /// **Currently unused**; see [title].
  final double titleFontSize;

  /// Font size for the duration line, in logical pixels.
  ///
  /// Applied to the [TickingDurationWidget]'s text style before any
  /// [FittedBox] scale-down.
  final double subtitleFontSize;

  /// Font size for [caption], in logical pixels.
  ///
  /// Only relevant when [caption] is non-null. Applied before any [FittedBox]
  /// scale-down.
  final double captionFontSize;

  @override
  Widget build(BuildContext context) {
    final contrastColor = backgroundColor.contrastingColor();

    final baseStyle = TextStyle(
      color: contrastColor,
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
              const NeonText(
                'GYM',
                maxLines: 1,
                color: Colors.green,
                distance: .45,
              ).withNeonBorder(color: Colors.blueGrey),
              TickingDurationWidget(
                eventTime: DateTime(1960, 3),
                currentTime: DateTime(2026, 9),
                textStyle: baseStyle.copyWith(fontSize: subtitleFontSize),
              ),
              if (caption != null)
                Text(
                  caption!,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
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
