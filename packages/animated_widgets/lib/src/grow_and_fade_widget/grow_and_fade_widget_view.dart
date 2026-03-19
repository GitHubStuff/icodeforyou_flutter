// lib/src/grow_and_fade_widget/grow_and_fade_widget_view.dart
import 'package:animated_widgets/src/grow_and_fade_widget/_fade_animation_mixin.dart';
import 'package:animated_widgets/src/grow_widget/_grow_animation_mixin.dart';
import 'package:application_setup/application_setup.dart';
import 'package:flutter/widgets.dart';

/// Scales and fades [child] from 0.0 to 1.0 over [duration], centered in its
/// parent.
///
/// Both the scale and opacity animate simultaneously over the same [duration]
/// and [curve]. Calls [onComplete] when the animation finishes, satisfying
/// the [SplashScreenAbstract] contract.
class GrowAndFadeWidgetView extends SplashScreenAbstract {
  const GrowAndFadeWidgetView({
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
    return _GrowAndFadeView(
      duration: duration,
      curve: curve,
      onComplete: onComplete,
      child: child,
    );
  }
}

class _GrowAndFadeView extends StatefulWidget {
  const _GrowAndFadeView({
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
  State<_GrowAndFadeView> createState() => _GrowAndFadeViewState();
}

class _GrowAndFadeViewState extends State<_GrowAndFadeView>
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
        child: FadeTransition(
          opacity: fadeAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
