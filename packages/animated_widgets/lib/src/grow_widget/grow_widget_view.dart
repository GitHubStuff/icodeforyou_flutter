// lib/src/grow_widget/grow_widget_view.dart

import 'package:animated_widgets/src/grow_widget/_grow_animation_mixin.dart';
import 'package:flutter/widgets.dart';

/// Scales [child] from 0.0 to 1.0 over [duration], centered in its parent.
///
/// Optionally calls [onComplete] when the animation finishes.
class GrowWidgetView extends StatefulWidget {
  const GrowWidgetView({
    required this.child,
    required this.duration,
    super.key,
    this.curve = Curves.easeOut,
    this.onComplete,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onComplete;

  @override
  State<GrowWidgetView> createState() => _GrowWidgetViewState();
}

class _GrowWidgetViewState extends State<GrowWidgetView>
    with SingleTickerProviderStateMixin, GrowAnimationMixin {
  @override
  void initState() {
    super.initState();
    initAnimation(
      vsync: this,
      duration: widget.duration,
      curve: widget.curve,
      onComplete: widget.onComplete,
    );
  }

  @override
  void dispose() {
    disposeAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
