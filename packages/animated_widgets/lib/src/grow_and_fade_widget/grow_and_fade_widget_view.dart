// lib/src/grow_and_fade_widget/grow_and_fade_widget_view.dart

import 'package:animated_widgets/src/grow_and_fade_widget/_fade_animation_mixin.dart';
import 'package:animated_widgets/src/grow_widget/_grow_animation_mixin.dart';
import 'package:flutter/widgets.dart';

/// Scales and fades [child] from 0.0 to 1.0 over [duration], centered in its
/// parent.
///
/// Both the scale and opacity animate simultaneously over the same [duration]
/// and [curve]. Optionally calls [onComplete] when the animation finishes.
class GrowAndFadeWidgetView extends StatefulWidget {
  const GrowAndFadeWidgetView({
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
  State<GrowAndFadeWidgetView> createState() => _GrowAndFadeWidgetViewState();
}

class _GrowAndFadeWidgetViewState extends State<GrowAndFadeWidgetView>
    with
        SingleTickerProviderStateMixin,
        GrowAnimationMixin,
        FadeAnimationMixin {
  @override
  void initState() {
    super.initState();
    initAnimation(
      vsync: this,
      duration: widget.duration,
      curve: widget.curve,
      onComplete: widget.onComplete,
    );
    initFadeAnimation(
      controller: growController,
      curve: widget.curve,
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
        child: FadeTransition(
          opacity: fadeAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
