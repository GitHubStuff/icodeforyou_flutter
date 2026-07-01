// packages/animated_widgets/lib/src/combination_animation/widgets/combination_animation_sequenced.dart

part of 'animates_widget.dart';

/// Runs a list of [CombinationAnimationStep]s sequentially on a single
/// timeline.
///
/// One [AnimationController] drives the entire sequence, and only one
/// [Transform.scale] (plus at most one [Opacity]) ever exists in the tree.
/// Steps are mapped onto the controller's [0, 1] range by relative
/// [CombinationAnimationStep.duration], so a step twice as long occupies
/// twice as much of the timeline.
///
/// When the final step finishes, [onComplete] fires.
class CombinationAnimationSequenced extends StatefulWidget {
  const CombinationAnimationSequenced({
    required this.steps,
    required this.child,
    this.onComplete,
    super.key,
  }) : assert(steps.length > 0, 'steps must not be empty');

  final List<CombinationAnimationStep> steps;
  final Widget child;
  final VoidCallback? onComplete;

  @override
  State<CombinationAnimationSequenced> createState() =>
      _CombinationAnimationSequencedState();
}

class _CombinationAnimationSequencedState
    extends State<CombinationAnimationSequenced>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_StepWindow> _windows;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _rebuildTimeline();
    _controller = AnimationController(vsync: this, duration: _totalDuration)
      ..addStatusListener(_onStatus);
    unawaited(_controller.forward());
  }

  @override
  void didUpdateWidget(covariant CombinationAnimationSequenced oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_listsEqual(oldWidget.steps, widget.steps)) {
      _rebuildTimeline();
      _controller
        ..stop()
        ..duration = _totalDuration;
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onStatus)
      ..dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onComplete?.call();
    }
  }

  void _rebuildTimeline() {
    final totalMs = widget.steps.fold<int>(
      0,
      (sum, s) => sum + s.duration.inMilliseconds,
    );
    _totalDuration = Duration(milliseconds: totalMs == 0 ? 1 : totalMs);

    final windows = <_StepWindow>[];
    var accumulatedMs = 0;
    for (final step in widget.steps) {
      final startMs = accumulatedMs;
      final endMs = accumulatedMs + step.duration.inMilliseconds;
      windows.add(
        _StepWindow(
          step: step,
          start: totalMs == 0 ? 0.0 : startMs / totalMs,
          end: totalMs == 0 ? 1.0 : endMs / totalMs,
        ),
      );
      accumulatedMs = endMs;
    }
    _windows = windows;
  }

  bool _listsEqual(
    List<CombinationAnimationStep> a,
    List<CombinationAnimationStep> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Returns the window whose range contains [globalT].
  ///
  /// Only the non-final windows are scanned: the final window always ends at
  /// `1.0` and [globalT] never exceeds `1.0`, so any progress past the
  /// penultimate window's end belongs to the last window. Letting the last
  /// window be the terminal return keeps that intent explicit.
  _StepWindow _activeWindow(double globalT) {
    final lastIndex = _windows.length - 1;
    for (var i = 0; i < lastIndex; i++) {
      final window = _windows[i];
      if (globalT <= window.end) return window;
    }
    return _windows.last;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final globalT = _controller.value;
        final window = _activeWindow(globalT);
        final span = window.end - window.start;
        final localRaw = span <= 0
            ? 1.0
            : ((globalT - window.start) / span).clamp(0.0, 1.0);
        final localT = window.step.curve.transform(localRaw);
        return buildCombinationAnimationFrame(
          t: localT,
          scale: window.step.scaling,
          opacity: window.step.opacity,
          child: child!,
        );
      },
    );
  }
}

class _StepWindow {
  const _StepWindow({
    required this.step,
    required this.start,
    required this.end,
  });

  final CombinationAnimationStep step;
  final double start;
  final double end;
}
