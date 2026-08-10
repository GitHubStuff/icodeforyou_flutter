// packages/custom_widgets/lib/src/slide_indexed_stack.dart

import 'package:flutter/material.dart';

/// The default duration of the slide between children.
const Duration _kDefaultDuration = Duration(milliseconds: 750);

/// The default curve shaping the slide.
const Curve _kDefaultCurve = Curves.easeInOutCubic;

/// An [IndexedStack] replacement that slides between children when
/// [index] changes.
///
/// [IndexedStack] switches instantly: the newly selected child simply
/// replaces the old one on the next frame. This widget keeps the same
/// contract — every child stays mounted for the widget's whole
/// lifetime, so child state survives switches — but animates the
/// change: the outgoing child slides off along [direction] while the
/// incoming child slides on beside it.
///
/// Slide direction is derived from index order. Moving to a higher
/// index slides content toward the start — the incoming child enters
/// from the end — and moving to a lower index slides the opposite way.
/// With [Axis.horizontal] this reads as left/right paging in index
/// order, which matches a rail whose buttons are declared in the same
/// order as [children].
///
/// While at rest, every non-selected child sits in an [Offstage] with
/// its tickers disabled by [TickerMode], so hidden children cost no
/// layout, paint, or animation work. During a slide only the two
/// children involved come on stage; the rest remain off. A tap that
/// arrives mid-slide restarts the animation from the new pair.
class SlideIndexedStack extends StatefulWidget {
  /// Creates a sliding indexed stack.
  const SlideIndexedStack({
    required this.index,
    required this.children,
    this.direction = Axis.horizontal,
    this.duration = _kDefaultDuration,
    this.curve = _kDefaultCurve,
    super.key,
  });

  /// The index of the child to show.
  final int index;

  /// The children, all of which stay mounted across index changes.
  final List<Widget> children;

  /// The axis along which children slide.
  final Axis direction;

  /// How long the slide runs.
  final Duration duration;

  /// The curve shaping the slide.
  final Curve curve;

  @override
  State<SlideIndexedStack> createState() => _SlideIndexedStackState();
}

/// State for [SlideIndexedStack]: owns the controller driving the
/// slide and the previous/current index pair it animates between.
class _SlideIndexedStackState extends State<SlideIndexedStack>
    with SingleTickerProviderStateMixin {
  /// Drives every slide; restarted from zero on each index change.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  /// The index currently shown (or sliding in).
  late int _current = widget.index;

  /// The index sliding out, or `null` while at rest.
  int? _previous;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onStatus);
  }

  @override
  void didUpdateWidget(SlideIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (widget.index != _current) {
      setState(() {
        _previous = _current;
        _current = widget.index;
      });
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Drops [_previous] once the slide completes, returning the stack
  /// to its at-rest configuration.
  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _previous = null;
      });
    }
  }

  /// Whether the slide moves toward a higher index.
  bool get _forward => _previous != null && _current > _previous!;

  /// The off-screen offset on the entering side.
  Offset get _enterFrom => switch (widget.direction) {
    Axis.horizontal => _forward ? const Offset(1, 0) : const Offset(-1, 0),
    Axis.vertical => _forward ? const Offset(0, 1) : const Offset(0, -1),
  };

  /// The off-screen offset on the exiting side.
  Offset get _exitTo => -_enterFrom;

  /// The position of the incoming child: from [_enterFrom] to center.
  Animation<Offset> get _incoming => _controller.drive(
    Tween<Offset>(
      begin: _enterFrom,
      end: Offset.zero,
    ).chain(CurveTween(curve: widget.curve)),
  );

  /// The position of the outgoing child: from center to [_exitTo].
  Animation<Offset> get _outgoing => _controller.drive(
    Tween<Offset>(
      begin: Offset.zero,
      end: _exitTo,
    ).chain(CurveTween(curve: widget.curve)),
  );

  /// The stack entry for the child at [index].
  ///
  /// The selected child at rest renders bare. During a slide the two
  /// involved children render inside [SlideTransition]s. Everything
  /// else sits in [Offstage] with tickers disabled, preserving state
  /// at zero cost — the [IndexedStack] contract.
  Widget _entry(int index) {
    final child = widget.children[index];
    if (_previous == null) {
      return index == _current
          ? child
          : Offstage(child: TickerMode(enabled: false, child: child));
    }
    if (index == _current) {
      return SlideTransition(position: _incoming, child: child);
    }
    if (index == _previous) {
      return SlideTransition(position: _outgoing, child: child);
    }
    return Offstage(child: TickerMode(enabled: false, child: child));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < widget.children.length; i++) _entry(i),
        ],
      ),
    );
  }
}
