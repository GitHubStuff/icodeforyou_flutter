// lib/src/grow_widget/grow_widget_view.dart
import 'package:animated_widgets/src/grow_widget/_grow_animation_mixin.dart';
import 'package:application_setup/application_setup.dart'
    show SplashScreenAbstract;
import 'package:flutter/widgets.dart';

/// Scales [child] from 0.0 to 1.0 over [duration], centered in its parent.
///
/// Calls [onComplete] when the animation finishes, satisfying the
/// [SplashScreenAbstract] contract.
class GrowWidgetView extends SplashScreenAbstract {
  const GrowWidgetView({
    required this.child,
    required this.duration,
    required super.onComplete,
    super.key,
    this.curve = Curves.easeOut,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return _GrowView(
      duration: duration,
      curve: curve,
      onComplete: onComplete,
      child: child,
    );
  }
}

class _GrowView extends StatefulWidget {
  const _GrowView({
    required this.child,
    required this.duration,
    required this.onComplete,
    required this.curve,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final VoidCallback onComplete;

  @override
  State<_GrowView> createState() => _GrowViewState();
}

class _GrowViewState extends State<_GrowView>
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
    startAnimation();
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
