// packages/sequenced_animations/lib/src/core/range_sequence_widget.dart

import 'package:flutter/widgets.dart';
import 'package:sequenced_animations/sequenced_animations.dart'
    show AnimationRange;

/// Base for widgets that drive one property of [child] through
/// [ranges], in order.
///
/// With no [controller], an internal one plays `ranges[0]` through
/// `ranges[n]` once, then stops. With an external [controller], the
/// caller drives playback (forward, reverse, pause, repeat); the
/// controller's `0.0..1.0` spans the whole sequence, weighted by each
/// range's duration. Use [totalDuration] to size an external
/// controller.
///
/// Each range's `onEnd` fires when playback crosses the end of that
/// range going forward. [onFinally] fires when the controller reaches
/// [AnimationStatus.completed].
///
/// Subclasses supply only a [State] that extends [RangeSequenceState]
/// and implements `build` using [RangeSequenceState.animation].
abstract class RangeSequenceWidget extends StatefulWidget {
  const RangeSequenceWidget({
    required this.child,
    required this.ranges,
    this.onFinally,
    super.key,
    this.controller,
  }) : assert(ranges.length > 0, 'ranges must not be empty');

  final Widget child;
  final VoidCallback? onFinally;
  final List<AnimationRange> ranges;
  final AnimationController? controller;

  /// Sum of all range durations.
  static Duration totalDuration(List<AnimationRange> ranges) =>
      ranges.fold(Duration.zero, (sum, range) => sum + range.duration);
}

/// Shared lifecycle for every [RangeSequenceWidget]: controller
/// ownership, the [TweenSequence], per-range `onEnd` detection and
/// `onFinally`. Subclasses implement only `build`.
abstract class RangeSequenceState<W extends RangeSequenceWidget>
    extends State<W>
    with SingleTickerProviderStateMixin {
  AnimationController? _internalController;
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<double> _boundaries;
  late double _lastValue;

  /// The sequenced value, `ranges[0].begin` ... `ranges[n].end`.
  @protected
  Animation<double> get animation => _animation;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  @override
  void didUpdateWidget(W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.ranges != widget.ranges) {
      _detach();
      _attach();
    }
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  void _attach() {
    final external = widget.controller;
    if (external == null) {
      final internal = AnimationController(
        vsync: this,
        duration: RangeSequenceWidget.totalDuration(widget.ranges),
      );
      _internalController = internal;
      _controller = internal;
    } else {
      _controller = external;
    }

    _animation = _buildSequence().animate(_controller);
    _boundaries = _buildBoundaries();
    _lastValue = _controller.value;

    _controller
      ..addListener(_onTick)
      ..addStatusListener(_onStatus);

    _internalController?.forward();
  }

  void _detach() {
    _controller
      ..removeListener(_onTick)
      ..removeStatusListener(_onStatus);
    _internalController?.dispose();
    _internalController = null;
  }

  TweenSequence<double> _buildSequence() => TweenSequence<double>([
    for (final range in widget.ranges)
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: range.begin,
          end: range.end,
        ).chain(CurveTween(curve: range.curve)),
        weight: range.duration.inMicroseconds.toDouble(),
      ),
  ]);

  /// Controller values (0.0..1.0] at which each range ends.
  List<double> _buildBoundaries() {
    final total = RangeSequenceWidget.totalDuration(widget.ranges)
        .inMicroseconds;
    final boundaries = <double>[];
    var elapsed = 0;
    for (final range in widget.ranges) {
      elapsed += range.duration.inMicroseconds;
      boundaries.add(elapsed / total);
    }
    return boundaries;
  }

  void _onTick() {
    final value = _controller.value;
    if (value > _lastValue) {
      for (var i = 0; i < _boundaries.length; i++) {
        final boundary = _boundaries[i];
        if (boundary > _lastValue && boundary <= value) {
          widget.ranges[i].onEnd?.call();
        }
      }
    }
    _lastValue = value;
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onFinally?.call();
    }
  }
}
