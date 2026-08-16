// packages/custom_widgets/lib/src/slide_index_stack/slide_index_stack.dart

import 'dart:async';

import 'package:flutter/material.dart';

/// The default duration of the slide between children.
const Duration _kDefaultDuration = Duration(milliseconds: 750);

/// The default curve shaping the slide.
const Curve _kDefaultCurve = Curves.easeInOutCubic;

/// {@template slide_indexed_stack}
/// An [IndexedStack] replacement that slides between children when
/// [index] changes.
///
/// [IndexedStack] switches instantly: the newly selected child simply
/// replaces the old one on the next frame. This widget keeps the same
/// contract — every child stays mounted for the widget's whole
/// lifetime, so child state survives switches — but animates the
/// change: the outgoing child slides off horizontally while the
/// incoming child slides on beside it.
///
/// Slide direction is derived from index order. Moving to a higher
/// index slides content toward the start — the incoming child enters
/// from the end — and moving to a lower index slides the opposite
/// way. This reads as left/right paging in index order, matching
/// destination buttons declared in the same order as [children],
/// whether those buttons are laid out as a dock or a rail. The slide
/// is horizontal by design: it stays perpendicular to the vertical
/// scrolling typical inside children, so a slide never reads as a
/// scroll.
///
/// Every child renders inside the same wrapper chain on every build —
/// [Offstage], then [TickerMode], then [SlideTransition] — with only
/// the wrappers' parameters changing. Keeping the element tree above
/// each child identical in shape is what makes the state-keeping
/// contract hold: a wrapper whose type changed between builds would
/// force Flutter to reinflate the child and discard its state.
///
/// While at rest, every non-selected child sits offstage with its
/// tickers disabled, so hidden children cost no layout, paint, or
/// animation work; the selected child's [SlideTransition] holds a
/// stopped animation at [Offset.zero]. During a slide only the two
/// children involved come on stage; the rest remain off. A tap that
/// arrives mid-slide restarts the animation from the new pair.
/// {@endtemplate}
class SlideIndexedStack extends StatefulWidget {
  /// {@macro slide_indexed_stack}
  const SlideIndexedStack({
    required this.index,
    required this.children,
    this.duration = _kDefaultDuration,
    this.curve = _kDefaultCurve,
    super.key,
  });

  /// The index of the child to show.
  final int index;

  /// The children, all of which stay mounted across index changes.
  final List<Widget> children;

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
      unawaited(_controller.forward(from: 0));
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
  Offset get _enterFrom => _forward ? const Offset(1, 0) : const Offset(-1, 0);

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

  /// Whether the child at [index] is on stage: the current child
  /// always, plus the previous child while a slide is running.
  bool _isOnStage(int index) {
    return index == _current || (_previous != null && index == _previous);
  }

  /// The position driving the child at [index]: the live incoming or
  /// outgoing animation for the sliding pair, and a stopped animation
  /// holding center for everything else.
  Animation<Offset> _positionFor(int index) {
    if (_previous != null) {
      if (index == _current) {
        return _incoming;
      }
      if (index == _previous) {
        return _outgoing;
      }
    }
    return const AlwaysStoppedAnimation<Offset>(Offset.zero);
  }

  /// The stack entry for the child at [index].
  ///
  /// Every entry keeps the identical wrapper chain on every build —
  /// only the parameters change — so the child's element subtree is
  /// never reinflated and its state survives: the [IndexedStack]
  /// contract.
  Widget _entry(int index) {
    final onStage = _isOnStage(index);
    return Offstage(
      offstage: !onStage,
      child: TickerMode(
        enabled: onStage,
        child: SlideTransition(
          position: _positionFor(index),
          child: widget.children[index],
        ),
      ),
    );
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
