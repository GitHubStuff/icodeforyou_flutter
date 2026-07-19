// packages/custom_widgets/lib/src/orientation_flex.dart
// ignore_for_file: always_use_package_imports

import 'package:flutter/widgets.dart';

import 'aspect_shape.dart';

/// A [Flex] whose [Flex.direction] is selected from the current viewport's
/// [AspectShape].
///
/// The viewport is measured with [MediaQuery.sizeOf], so the layout updates
/// automatically when the device is rotated (phones and tablets) or the window
/// is resized (desktop and web). Because that single signal carries both
/// changes, there is no separate "rotation" versus "resize" path.
///
/// The direction is resolved by classifying the viewport with
/// [AspectShape.fromSize] and mapping the result:
///
/// * [AspectShape.portrait] uses [forPortrait].
/// * [AspectShape.landscape] uses [forLandscape].
/// * [AspectShape.square] uses [forSquare]. A viewport counts as square when
///   its long-to-short side ratio is within [squareTolerance] of `1:1`.
///
/// Because the trigger (viewport shape) is decoupled from the result (the [Axis]
/// to lay out along), a portrait-style layout can be requested even in
/// landscape — for example `forLandscape: Axis.vertical`.
///
/// All remaining parameters are passed straight through to the underlying
/// [Flex] and therefore behave identically regardless of the resolved
/// direction. Note that [mainAxisAlignment] and [crossAxisAlignment] govern the
/// resolved main and cross axes, so a single value expresses one intent
/// (along-the-flow versus perpendicular-to-flow) even though the physical axis
/// it controls swaps when the direction changes.
class OrientationFlex extends StatelessWidget {
  /// Creates a [Flex] whose direction follows the viewport's [AspectShape].
  ///
  /// [squareTolerance] must be greater than or equal to `0.0`.
  const OrientationFlex({
    required this.children,
    this.forPortrait = Axis.vertical,
    this.forLandscape = Axis.horizontal,
    this.forSquare = Axis.vertical,
    this.squareTolerance = AspectShape.defaultSquareTolerance,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 0.0,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    super.key,
  }) : assert(
         squareTolerance >= 0.0,
         'squareTolerance must be >= 0.0',
       );

  /// The widgets laid out along the resolved [Axis].
  final List<Widget> children;

  /// The [Axis] used when the viewport is [AspectShape.portrait].
  ///
  /// Defaults to [Axis.vertical], producing a column.
  final Axis forPortrait;

  /// The [Axis] used when the viewport is [AspectShape.landscape].
  ///
  /// Defaults to [Axis.horizontal], producing a row.
  final Axis forLandscape;

  /// The [Axis] used when the viewport is [AspectShape.square].
  ///
  /// Defaults to [Axis.vertical], matching the tie-break that a square viewport
  /// resolves to a column.
  final Axis forSquare;

  /// The scale-invariant fraction by which the viewport's long-to-short side
  /// ratio may exceed `1:1` and still be treated as [AspectShape.square].
  ///
  /// Forwarded to [AspectShape.fromSize]. Defaults to
  /// [AspectShape.defaultSquareTolerance] (`0.0`), so only an exact `1:1`
  /// viewport is square and the widget otherwise behaves as a pure
  /// portrait/landscape binary.
  final double squareTolerance;

  /// Passed to [Flex.mainAxisAlignment]. Defaults to [MainAxisAlignment.start].
  final MainAxisAlignment mainAxisAlignment;

  /// Passed to [Flex.mainAxisSize]. Defaults to [MainAxisSize.max].
  final MainAxisSize mainAxisSize;

  /// Passed to [Flex.crossAxisAlignment].
  ///
  /// Defaults to [CrossAxisAlignment.center].
  final CrossAxisAlignment crossAxisAlignment;

  /// Passed to [Flex.spacing], the gap inserted between [children].
  ///
  /// Defaults to `0.0`. Requires Flutter 3.27 or newer.
  final double spacing;

  /// Passed to [Flex.textDirection].
  final TextDirection? textDirection;

  /// Passed to [Flex.verticalDirection]. Defaults to [VerticalDirection.down].
  final VerticalDirection verticalDirection;

  /// Passed to [Flex.textBaseline].
  final TextBaseline? textBaseline;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    debugPrint(
      'viewport: $size  shape: '
      '${size.width >= size.height ? "landscape" : "portrait"}',
    );
    return Flex(
      direction: _resolveDirection(MediaQuery.sizeOf(context)),
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: children,
    );
  }

  Axis _resolveDirection(Size size) {
    return switch (AspectShape.fromSize(
      size,
      squareTolerance: squareTolerance,
    )) {
      AspectShape.landscape => forLandscape,
      AspectShape.portrait => forPortrait,
      AspectShape.square => forSquare,
    };
  }
}
