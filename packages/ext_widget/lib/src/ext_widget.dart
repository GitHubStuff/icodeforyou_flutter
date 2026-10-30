// packages/ext_widget/lib/src/ext_widget.dart

import 'package:flutter/widgets.dart';

const _kDefaultDuration = Duration(milliseconds: 300);
const Cubic _kDefaultCurve = Curves.easeInOut;
const Alignment _kDefaultAlignment = Alignment.topCenter;
const Clip _kDefaultClipBehavior = Clip.hardEdge;
const _kDefaultBorderWidth = 1.5;
const _kDefaultBorderRadius = 0.0;
const _kNoInset = 0.0;
const _kTransparent = Color(0x00000000);
const _kMinOpacity = 0.0;
const _kMaxOpacity = 1.0;

/// Convenience extensions on [Widget] for composing common wrappers.
///
/// Every member returns a new widget wrapping the receiver. Nothing is
/// mutated, no [BuildContext] is required, and members chain freely:
///
/// ```dart
/// import 'package:ext_widget/ext_widget.dart';
///
/// const Text('Hello')
///     .withPaddingAll(8)
///     .withBorder(const Color(0xFF000000))
///     .hide(isBusy);
/// ```
///
/// Members are listed alphabetically.
extension ExtWidget on Widget {
  /// Makes this widget invisible while keeping its layout space.
  ///
  /// When [shouldHide] is `true`, wraps the widget in an [Opacity] of `0`;
  /// the widget still participates in layout and hit-testing is disabled
  /// by [Opacity] at zero. Returns the widget unchanged otherwise.
  ///
  /// Use [remove] to also release the space.
  Widget hide(bool shouldHide) => shouldHide ? withOpacity(_kMinOpacity) : this;

  /// Collapses this widget to zero size immediately when [shouldRemove]
  /// is `true`, releasing the space it occupies in the layout.
  ///
  /// The receiver stays in the tree as the child of a [SizedBox.shrink],
  /// so its element and state are preserved across the toggle. Returns
  /// the widget unchanged otherwise.
  ///
  /// Use [hide] to keep the space, or [removeAnimated] to animate.
  Widget remove(bool shouldRemove) =>
      shouldRemove ? SizedBox.shrink(child: this) : this;

  /// The same collapse as [remove], animated over [duration].
  ///
  /// [AnimatedSize] animates its own size to match its child whenever that
  /// child's measured size changes, clipping any overflow for the duration
  /// of the transition. Swapping the child between the real widget and an
  /// empty [SizedBox.shrink] therefore animates both the widget and the
  /// space it uses open and closed. No [TickerProvider] is required.
  ///
  /// Note the content disappears the instant [shouldRemove] flips; only the
  /// gap closes over [duration]. Use [AnimatedCrossFade] if the content
  /// should fade as it collapses.
  Widget removeAnimated(
    bool shouldRemove, {
    Duration duration = _kDefaultDuration,
    Curve curve = _kDefaultCurve,
    Alignment alignment = _kDefaultAlignment,
    Clip clipBehavior = _kDefaultClipBehavior,
  }) => AnimatedSize(
    duration: duration,
    curve: curve,
    alignment: alignment,
    clipBehavior: clipBehavior,
    child: shouldRemove ? const SizedBox.shrink() : this,
  );

  ///
  Widget squareFit({
    required double side,
    AlignmentGeometry alignment = Alignment.center,
  }) => SizedBox.square(
    dimension: side,
    child: FittedBox(
      fit: BoxFit.fill,
      alignment: alignment,
      child: this,
    ),
  );

  /// Paints [color] behind this widget.
  ///
  /// Uses a [DecoratedBox], which adds no padding and no extra layout.
  Widget withBackground(Color color) => DecoratedBox(
    decoration: BoxDecoration(color: color),
    child: this,
  );

  /// Draws a border of [color] around this widget.
  ///
  /// [width] is the stroke width in logical pixels, [radius] the corner
  /// radius (`0` for square corners), and [style] the stroke style.
  /// The border is painted inside the widget's bounds and does not add
  /// to its size.
  Widget withBorder(
    Color color, {
    double width = _kDefaultBorderWidth,
    double radius = _kDefaultBorderRadius,
    BorderStyle style = BorderStyle.solid,
  }) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: color, width: width, style: style),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: this,
  );

  /// Renders this widget at [opacity], from `0.0` (invisible) to `1.0`.
  ///
  /// Throws an [ArgumentError] if [opacity] is outside that range.
  Widget withOpacity(double opacity) {
    if (opacity < _kMinOpacity || opacity > _kMaxOpacity) {
      throw ArgumentError.value(
        opacity,
        'opacity',
        'must be between $_kMinOpacity and $_kMaxOpacity',
      );
    }
    return Opacity(opacity: opacity, child: this);
  }

  /// Adds padding on each side independently. Sides default to `0`.
  Widget withPadding({
    double left = _kNoInset,
    double right = _kNoInset,
    double top = _kNoInset,
    double bottom = _kNoInset,
  }) => Padding(
    padding: EdgeInsets.only(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
    ),
    child: this,
  );

  /// Adds [value] padding on all four sides.
  Widget withPaddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// Adds [horizontal] padding left and right, and [vertical] padding top
  /// and bottom.
  Widget withSymmetricPadding({
    double horizontal = _kNoInset,
    double vertical = _kNoInset,
  }) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    ),
    child: this,
  );

  /// Adds per-side padding and paints [color] behind the padded area.
  ///
  /// Unlike [withPadding] followed by [withBackground], the colour fills
  /// the padding as well as the widget.
  Widget withWrap({
    double left = _kNoInset,
    double right = _kNoInset,
    double top = _kNoInset,
    double bottom = _kNoInset,
    Color color = _kTransparent,
  }) => ColoredBox(
    color: color,
    child: withPadding(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
    ),
  );

  /// Adds [value] padding on all sides and paints [color] behind the
  /// padded area.
  Widget withWrapAll(double value, {Color color = _kTransparent}) => withWrap(
    left: value,
    right: value,
    top: value,
    bottom: value,
    color: color,
  );
}
