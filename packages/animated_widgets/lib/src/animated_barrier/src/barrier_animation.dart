// packages/animated_barrier/lib/src/barrier_animation.dart

// ignore_for_file: public_member_api_docs

part of '../animated_barrier.dart';

/// Describes how the barrier (and the popover child riding with it) animates
/// in on show and out on dismiss.
///
/// Symmetric by construction: the same spec drives both the entrance and the
/// reverse exit. To customize behavior, pick a variant and tune [duration] and
/// [curve].
///
/// To extend with a new style (e.g. scale, slide-from-left), add a new
/// [BarrierAnimation] subclass and an exhaustive switch arm wherever variants
/// are matched.
sealed class BarrierAnimation {
  const BarrierAnimation({
    this.duration = const Duration(milliseconds: 750),
    this.curve = Curves.easeOutCubic,
  });

  /// Duration of the entrance animation. The reverse exit uses the same
  /// duration.
  final Duration duration;

  /// Curve applied to the entrance. The reverse exit uses [Curve.flipped].
  final Curve curve;
}

/// Fades the barrier and child in from fully transparent.
final class FadeBarrier extends BarrierAnimation {
  const FadeBarrier({
    super.duration,
    super.curve,
  });
}

/// Slides the barrier and child down from above the top edge while also
/// fading in. The opacity ride-along keeps the barrier from looking like a
/// hard rectangle entering the screen.
final class SlideFromTopBarrier extends BarrierAnimation {
  const SlideFromTopBarrier({
    super.duration,
    super.curve,
  });
}

/// Slides the barrier and child up from below the bottom edge while also
/// fading in.
final class SlideFromBottomBarrier extends BarrierAnimation {
  const SlideFromBottomBarrier({
    super.duration,
    super.curve,
  });
}
