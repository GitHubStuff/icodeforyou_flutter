// packages/rail_navigation/lib/src/widgets/rail_shell.dart

part of 'rail_shell.dart';

/// A state-preserving stack whose index changes animate per a
/// [RailTransition].
///
/// Every child stays mounted at its fixed position in the stack for
/// the widget's whole life, wrapped in a single constant chain
/// (offstage gate, ticker gate, pointer gate, fade, scale, translate).
/// Only the *animations* driving that chain differ by role — hidden,
/// outgoing, or incoming — so a child never changes ancestor
/// structure and its state is never lost, regardless of switches,
/// role changes, or even changing the transition kind at runtime.
///
/// On an index change the visible index snaps immediately: the old
/// child becomes the outgoing layer (pointer-blocked, tickers
/// paused), the new child becomes the incoming layer, and the
/// controller replays. When the controller completes, the outgoing
/// layer returns to hidden. Retargeting mid-transition — a third
/// index arriving while animating — restarts the controller with the
/// interrupted child as the new outgoing layer.
///
/// Switches are instant (no outgoing layer, controller pinned to 1)
/// when the transition is [RailTransition.none], the duration is
/// [Duration.zero], or the platform requests reduced motion.
class _TransitioningIndexedStack extends StatefulWidget {
  const _TransitioningIndexedStack({
    required this.index,
    required this.transition,
    required this.duration,
    required this.slideAxis,
    required this.children,
  });

  /// The index of the visible child.
  final int index;

  /// The choreography played when [index] changes.
  final RailTransition transition;

  /// How long the transition runs.
  final Duration duration;

  /// The axis [RailTransition.sharedAxis] slides along, derived from
  /// the rail's placement.
  final Axis slideAxis;

  /// The stacked children, all kept alive.
  final List<Widget> children;

  @override
  State<_TransitioningIndexedStack> createState() =>
      _TransitioningIndexedStackState();
}

class _TransitioningIndexedStackState extends State<_TransitioningIndexedStack>
    with SingleTickerProviderStateMixin {
  /// The index currently shown. Snaps immediately on change.
  late int _currentIndex = widget.index;

  /// The index animating out, or `null` when idle.
  int? _previousIndex;

  /// Whether the last switch moved to a higher index; drives the
  /// shared-axis direction.
  bool _forward = true;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  )..addStatusListener(_onStatus);

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _previousIndex != null) {
      setState(() {
        _previousIndex = null;
      });
    }
  }

  @override
  void didUpdateWidget(_TransitioningIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;

    if (widget.index == _currentIndex) return;

    final instant =
        widget.transition == RailTransition.none ||
        widget.duration == Duration.zero ||
        MediaQuery.disableAnimationsOf(context);

    // Field mutation without setState: didUpdateWidget always precedes
    // a build of this element, so the new values are picked up.
    _forward = widget.index > _currentIndex;
    _previousIndex = instant ? null : _currentIndex;
    _currentIndex = widget.index;

    if (instant) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onStatus)
      ..dispose();
    super.dispose();
  }

  /// Wraps [child] in the constant layer chain, driven by animations
  /// for its current role.
  Widget _buildLayer(int index, Widget child) {
    final isCurrent = index == _currentIndex;
    final isPrevious = index == _previousIndex;
    final hidden = !isCurrent && !isPrevious;

    final animations = hidden
        ? _kIdentityLayerAnimations
        : _layerAnimationsFor(
            transition: widget.transition,
            role: isCurrent ? _LayerRole.incoming : _LayerRole.outgoing,
            parent: _controller.view,
            axis: widget.slideAxis,
            forward: _forward,
          );

    return Offstage(
      offstage: hidden,
      child: TickerMode(
        enabled: isCurrent,
        child: IgnorePointer(
          ignoring: !isCurrent,
          child: FadeTransition(
            opacity: animations.opacity,
            child: ScaleTransition(
              scale: animations.scale,
              child: AnimatedBuilder(
                animation: animations.translation,
                child: child,
                builder: (context, child) {
                  return Transform.translate(
                    offset: animations.translation.value,
                    child: child,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ClipRect keeps shared-axis slides from painting into the rail or
    // outside the content region.
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final (index, child) in widget.children.indexed)
            _buildLayer(index, child),
        ],
      ),
    );
  }
}
