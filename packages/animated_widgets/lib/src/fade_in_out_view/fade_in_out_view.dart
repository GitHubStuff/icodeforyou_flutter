// animated_widgets/lib/src/fade_in_out_view/fade_in_out_view.dart
import 'package:flutter/widgets.dart';

/// Animates [child] from [startOpacity] to [endOpacity] over [duration].
///
/// Defaults to a fade-out (1.0 → 0.0). Set [startOpacity] to 0.0 and
/// [endOpacity] to 1.0 for a fade-in. Calls [onComplete] when the animation
/// finishes.
class FadeInOutView extends StatelessWidget {
  /// Creates a [FadeInOutView] that fades [child] between [startOpacity] and
  /// [endOpacity] over [duration].
  const FadeInOutView({
    required this.child,
    required this.duration,
    this.onComplete,
    this.startOpacity = 1.0,
    this.endOpacity = 0.0,
    this.curve = Curves.easeInOut,
    super.key,
  }) : assert(
         startOpacity >= 0.0 && startOpacity <= 1.0,
         'startOpacity must be between 0.0 and 1.0',
       ),
       assert(
         endOpacity >= 0.0 && endOpacity <= 1.0,
         'endOpacity must be between 0.0 and 1.0',
       );

  /// The widget to fade.
  final Widget child;

  /// The duration of the fade animation.
  final Duration duration;

  /// The opacity at the start of the animation. Defaults to 1.0 (fully
  /// visible).
  final double startOpacity;

  /// The opacity at the end of the animation. Defaults to 0.0 (fully
  /// transparent).
  final double endOpacity;

  /// The curve applied to the fade animation.
  final Curve curve;

  /// Called when the animation completes.
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return _FadeInOutView(
      duration: duration,
      startOpacity: startOpacity,
      endOpacity: endOpacity,
      curve: curve,
      onComplete: onComplete,
      child: child,
    );
  }
}

class _FadeInOutView extends StatefulWidget {
  const _FadeInOutView({
    required this.child,
    required this.duration,
    required this.startOpacity,
    required this.endOpacity,
    required this.curve,
    required this.onComplete,
  });

  final Widget child;
  final Duration duration;
  final double startOpacity;
  final double endOpacity;
  final Curve curve;
  final VoidCallback? onComplete;

  @override
  State<_FadeInOutView> createState() => _FadeInOutViewState();
}

class _FadeInOutViewState extends State<_FadeInOutView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacity = Tween<double>(
      begin: widget.startOpacity,
      end: widget.endOpacity,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    final onComplete = widget.onComplete;
    if (onComplete != null) {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) onComplete();
      });
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: widget.child,
  );
}
