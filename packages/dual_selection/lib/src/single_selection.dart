// packages/dual_selection/lib/src/single_selection.dart

import 'package:flutter/widgets.dart';

import 'defaults.dart';

/// A fixed-size, single-button panel.
///
/// The one-option counterpart of [DualSelection]: [first] fills the whole
/// header row at [width] by [headerHeight] and is responsible for its own
/// alignment, padding and colours. There is nothing to select, so there is
/// no tap handling, haptic, callback or animation.
///
/// [firstChild] is laid out to exactly [width] by [bodyHeight], so children
/// that need bounded constraints (pickers, scrollables) work without extra
/// wrapping.
///
/// The content area is [width] wide and `headerHeight + bodyHeight` tall;
/// the border of [borderWidth] is drawn around that area, so the rendered
/// size is larger by `2 * borderWidth` in each dimension.
class SingleSelection extends StatelessWidget {
  /// Creates a [SingleSelection].
  const SingleSelection({
    required this.first,
    required this.firstChild,
    required this.borderColor,
    this.cornerRadius = Defaults.kCornerRadius,
    this.borderWidth = Defaults.kBorderWidth,
    this.headerHeight = Defaults.kHeaderHeight,
    this.bodyHeight = Defaults.kBodyHeight,
    this.width = Defaults.kWidth,
    super.key,
  }) : assert(cornerRadius >= 0, 'cornerRadius must not be negative'),
       assert(borderWidth >= 0, 'borderWidth must not be negative'),
       assert(headerHeight > 0, 'headerHeight must be positive'),
       assert(bodyHeight > 0, 'bodyHeight must be positive'),
       assert(width > 0, 'width must be positive');

  /// Content of the header. Fills [width] × [headerHeight].
  final Widget first;

  /// Body content. Fills [width] × [bodyHeight].
  final Widget firstChild;

  /// Colour of the outer border.
  final Color borderColor;

  /// Radius of the outer border's corners.
  final double cornerRadius;

  /// Stroke width of the outer border.
  final double borderWidth;

  /// Height of the header row.
  final double headerHeight;

  /// Height of the body area.
  final double bodyHeight;

  /// Width of the content area.
  final double width;

  /// Inner clip radius so the body corners sit flush inside the border.
  double get _innerRadius =>
      (cornerRadius - borderWidth).clamp(0, double.infinity);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_innerRadius),
          child: SizedBox(
            width: width,
            height: headerHeight + bodyHeight,
            child: Column(
              children: [
                _buildHeader(),
                _buildBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: width,
      height: headerHeight,
      child: first,
    );
  }

  Widget _buildBody() {
    return SizedBox(
      width: width,
      height: bodyHeight,
      child: firstChild,
    );
  }
}
