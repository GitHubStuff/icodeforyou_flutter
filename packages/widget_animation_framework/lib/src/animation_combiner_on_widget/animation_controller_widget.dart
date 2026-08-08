// packages/widget_animation_framework/lib/src/play_on_mount.dart

import 'dart:async';

import 'package:flutter/widgets.dart';

/// Builds a subtree against a timeline supplied by [AnimationControllerWidget].
typedef AnimationWidgetBuilder =
    Widget Function(BuildContext context, Animation<double> animation);

/// {@template play_on_mount}
/// Owns a single [AnimationController], plays it forward once when the widget
/// is inserted into the tree, and exposes the eased result to [builder].
///
/// This widget knows nothing about what is being animated. It is the timeline
/// half of the pairing with `AnimationCombinerOnWidget`, which is the
/// composition half.
///
/// Changing [duration] retargets the controller for its next run only. An
/// animation already in flight continues at its original rate, matching
/// [AnimationController.duration].
///
/// ```dart
/// AnimationControllerWidget(
///   duration: const Duration(milliseconds: 2500),
///   curve: Curves.easeInOut,
///   onCompleted: _handleDone,
///   builder: (context, animation) => AnimationCombinerOnWidget(
///     animation: animation,
///     opacity: Tween<double>(begin: 0, end: 1),
///     child: const Icon(Icons.star),
///   ),
/// )
/// ```
/// {@endtemplate}
class AnimationControllerWidget extends StatefulWidget {
  /// {@macro play_on_mount}
  const AnimationControllerWidget({
    required this.builder,
    required this.duration,
    required this.curve,
    required this.onCompleted,
    super.key,
  });

  /// Builds the subtree driven by the owned timeline.
  final AnimationWidgetBuilder builder;

  /// Invoked once the timeline reaches [AnimationStatus.completed].
  ///
  /// Read at call time, so a caller may swap the callback between rebuilds.
  final VoidCallback onCompleted;

  /// The time taken to run the timeline from begin to end.
  final Duration duration;

  /// The easing applied to the timeline before it reaches [builder].
  final Curve curve;

  @override
  State<AnimationControllerWidget> createState() => _AnimationControllerWidgetState();
}

class _AnimationControllerWidgetState extends State<AnimationControllerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late Animation<double> _animation = _easedTimeline();

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_handleStatusChanged);

    // The TickerFuture is intentionally discarded: completion is reported
    // through _handleStatusChanged, and the future never completes if the
    // ticker is cancelled on dispose.
    unawaited(_controller.forward());
  }

  @override
  void didUpdateWidget(AnimationControllerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }

    if (widget.curve != oldWidget.curve) {
      _animation = _easedTimeline();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleStatusChanged)
      ..dispose();
    super.dispose();
  }

  /// Applies [AnimationControllerWidget.curve] as an [Animatable] rather than a
  /// [CurvedAnimation].
  ///
  /// The result registers no listeners of its own, so swapping the curve on a
  /// live tree cannot invalidate an animation the previous subtree still holds.
  Animation<double> _easedTimeline() =>
      _controller.drive(CurveTween(curve: widget.curve));

  void _handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onCompleted.call();
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _animation);
}
