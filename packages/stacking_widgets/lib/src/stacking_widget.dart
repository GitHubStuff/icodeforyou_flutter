// packages/stacking_widgets/lib/src/stacking_widget.dart

import 'package:flutter/widgets.dart';
import 'package:stacking_widgets/stacking_widgets.dart' show PiledWidget;

/// {@template stacking_widget.dart}
/// A widget that displays a centered [base] widget overlaid with a collection
/// of [PiledWidget] items inside a fixed-size container.
///
/// The container dimensions are constrained by [size], and elements are allowed
/// to render outside the boundary without clipping.
/// {@endtemplate}
class StackingWidgets extends StatelessWidget {
  /// {@macro stacking_widget.dart}
  const StackingWidgets({
    required this.base,
    required this.size,
    required this.piledWidgets,
    super.key,
  });

  /// The primary background or foundation widget centered at the root of the
  /// stack.
  final Widget base;

  /// The fixed dimensions ([Size.width] and [Size.height]) reserved for the
  /// parent [SizedBox].
  ///
  /// Both width and height must be strictly greater than zero.
  final Size size;

  /// The list of [PiledWidget] elements layered sequentially on top of
  /// the [base] widget.
  final List<PiledWidget> piledWidgets;

  @override
  Widget build(BuildContext context) {
    assert(size.width > 0, 'size.width must be greater than zero');
    assert(size.height > 0, 'size.height must be greater than zero');

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Align(alignment: Alignment.center, child: base),
          for (final PiledWidget piledWidget in piledWidgets)
            Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: piledWidget.offset,
                child: piledWidget.child,
              ),
            ),
        ],
      ),
    );
  }
}
