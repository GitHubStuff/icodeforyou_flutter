// packages/stacking_widgets/lib/src/stacking_widget.dart

import 'package:flutter/widgets.dart';
import 'package:stacking_widgets/stacking_widgets.dart' show PiledWidget;

class StackingWidgets extends StatelessWidget {
  const StackingWidgets({
    required this.base,
    required this.size,
    required this.piledWidgets,
    super.key,
  });

  final Widget base;
  final Size size;
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
