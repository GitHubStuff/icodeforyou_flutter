// packages/border_caption/lib/src/border_caption.dart
import 'package:ext_string/ext_string.dart';
import 'package:flutter/material.dart';

/// Which border of the child a [BorderCaption] label is drawn into.
enum LabelBorder {
  /// The label interrupts the top border of the child.
  top,

  /// The label interrupts the bottom border of the child.
  bottom,
}

/// Overlays a short text label "in" the top or bottom border of [child].
///
/// ```text
/// ┌─ Title ──────────────┐
/// │  Some static stuff   │
/// └────── some text ─────┘
/// ```
///
/// The child is expected to draw its own border ([DecoratedBox],
/// [Container] with a [BoxDecoration], [Card], and so on). This widget does
/// not touch that border; instead it paints the label on top of a box
/// filled with [backgroundColor], positioned so the label's vertical centre
/// lies exactly on the child's chosen border. The filled box hides the
/// border underneath, which is what makes the text appear to interrupt it
/// — the same technique [OutlineInputBorder] uses for a floating label.
///
/// For the common case of a plain rectangular outline, [BorderCaption.outlined]
/// draws the border for you and takes the content directly.
///
/// The label's size is measured ahead of layout with `String.pixelSize`
/// so that half of its height can be reserved as overhang above or below
/// the child. The widget is therefore taller than its child by that
/// overhang and is never clipped by a tightly sized parent.
///
/// Horizontal placement needs no measurement at all: the label lives in a
/// slot exactly as wide as [child], and [labelAlignment] positions it
/// within that slot, so a centred or end-aligned label stays correct no
/// matter what width the child ends up with.
///
/// ## Parameters
///
/// * [label] — the text to show in the border.
/// * [labelBorder] — which border carries the label. Defaults to
///   [LabelBorder.bottom].
/// * [labelAlignment] — where along the border the label sits. Only the
///   horizontal component is used; the vertical placement is fixed by
///   [labelBorder]. Defaults to [AlignmentDirectional.centerStart], and
///   is resolved against the ambient [Directionality], so `centerStart`
///   is the right-hand side in right-to-left layouts.
/// * [labelInset] — minimum distance, in logical pixels, kept clear of
///   both the leading and trailing corners of [child], so the label never
///   overlaps a [BorderRadius]. Defaults to `16`.
/// * [labelStyle] — merged on top of the ambient [DefaultTextStyle]. Pass
///   `null` to inherit unchanged.
/// * [labelPadding] — padding inside the filled box around the text.
///   Horizontal padding controls how much border is hidden either side of
///   the text; vertical padding grows the overhang. Defaults to
///   `4` logical pixels horizontally.
/// * [backgroundColor] — the fill behind the label. It must match whatever
///   is behind the child's border for the "gap" illusion to hold. Defaults
///   to [ThemeData.scaffoldBackgroundColor].
/// * [child] — the bordered widget being labelled.
///
/// ## Example
///
/// ```dart
/// // Bring your own border.
/// BorderCaption(
///   label: 'some text',
///   labelAlignment: AlignmentDirectional.center,
///   child: Container(
///     padding: const EdgeInsets.all(16),
///     decoration: BoxDecoration(
///       border: Border.all(),
///       borderRadius: BorderRadius.circular(8),
///     ),
///     child: const Text('Some static stuff'),
///   ),
/// )
///
/// // Let the widget draw a plain outline.
/// BorderCaption.outlined(
///   label: 'some text',
///   labelAlignment: AlignmentDirectional.center,
///   borderColor: Theme.of(context).colorScheme.outline,
///   child: const Text('Some static stuff'),
/// )
/// ```
///
/// See also:
///
/// * [OutlineInputBorder], which achieves the same effect for text fields
///   by cutting a real gap in the border path.
class BorderCaption extends StatelessWidget {
  /// Creates a widget that shows [label] in a border of [child].
  ///
  /// [child] must draw its own border; see the class documentation.
  const BorderCaption({
    required this.label,
    required this.child,
    this.labelBorder = LabelBorder.bottom,
    this.labelAlignment = AlignmentDirectional.centerEnd,
    this.labelInset = 16,
    this.labelStyle,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 4),
    this.backgroundColor,
    super.key,
  });

  /// Creates a widget that draws a rectangular outline around [child] and
  /// shows [label] in that outline.
  ///
  /// This is the general constructor with the bordered container supplied
  /// for you: [child] is the *content*, and the border is described by
  /// [borderColor], [borderWidth], [borderRadius] and [padding]. Every
  /// `label*` parameter and [backgroundColor] behave exactly as in the
  /// general constructor.
  ///
  /// Because no [BuildContext] exists at construction time, the border
  /// cannot default to a theme colour; [borderColor] therefore defaults to
  /// opaque black, mirroring [Border.all]. Pass
  /// `Theme.of(context).colorScheme.outline` (or similar) at the call site
  /// for a theme-aware outline.
  ///
  /// * [borderColor] — colour of the outline. Defaults to black.
  /// * [borderWidth] — thickness of the outline in logical pixels.
  ///   Defaults to `1`.
  /// * [borderRadius] — corner rounding of the outline. Defaults to
  ///   `8` logical pixels on every corner.
  /// * [padding] — space between the outline and [child]. Defaults to
  ///   `16` logical pixels on every side.
  BorderCaption.outlined({
    required this.label,
    required Widget child,
    this.labelBorder = LabelBorder.bottom,
    this.labelAlignment = AlignmentDirectional.centerStart,
    this.labelInset = 16,
    this.labelStyle,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 4),
    this.backgroundColor,
    Color borderColor = const Color(0xFF000000),
    double borderWidth = 1,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(8),
    ),
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    super.key,
  }) : child = Container(
         padding: padding,
         decoration: BoxDecoration(
           border: Border.all(color: borderColor, width: borderWidth),
           borderRadius: borderRadius,
         ),
         child: child,
       );

  /// The text shown in the border.
  final String label;

  /// Which border of [child] carries the label.
  final LabelBorder labelBorder;

  /// Horizontal placement of the label along the border of [child].
  final AlignmentGeometry labelAlignment;

  /// Distance kept clear of both corners of [child].
  final double labelInset;

  /// Style merged on top of the ambient [DefaultTextStyle].
  final TextStyle? labelStyle;

  /// Padding between the text and the edge of its background box.
  final EdgeInsets labelPadding;

  /// Fill colour behind the label; must match the colour behind the border.
  final Color? backgroundColor;

  /// The bordered widget being labelled.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(labelStyle);
    final textSize = label.pixelSize(
      style: style,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    );
    final overhang = (textSize.height + labelPadding.vertical) / 2;
    final isTop = labelBorder == LabelBorder.top;
    final fill = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: isTop ? overhang : 0,
            bottom: isTop ? 0 : overhang,
          ),
          child: child,
        ),
        PositionedDirectional(
          start: labelInset,
          end: labelInset,
          top: isTop ? 0 : null,
          bottom: isTop ? null : 0,
          child: Align(
            alignment: labelAlignment,
            heightFactor: 1,
            child: ColoredBox(
              color: fill,
              child: Padding(
                padding: labelPadding,
                child: Text(
                  label,
                  style: style,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
