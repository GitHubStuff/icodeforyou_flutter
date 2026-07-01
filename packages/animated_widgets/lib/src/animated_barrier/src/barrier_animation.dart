// packages/animated_widgets/lib/src/animated_barrier/src/barrier_animation.dart
part of '../animated_barrier.dart';

/// Describes how the barrier (and the popover child riding with it) animates
/// in on show and out on dismiss.
///
/// Symmetric by construction: the same spec drives both the entrance and the
/// reverse exit. To customize behavior, pick a variant and tune [duration] and
/// [curve].
///
/// This is a sealed hierarchy, so every site that matches a [BarrierAnimation]
/// can switch exhaustively over its variants:
///
/// ```dart
/// final Widget transition = switch (animation) {
///   FadeBarrier() => /* fade transition */,
///   SlideFromTopBarrier() => /* slide-down transition */,
///   SlideFromBottomBarrier() => /* slide-up transition */,
/// };
/// ```
///
/// To extend with a new style (e.g. scale, slide-from-left), add a new
/// [BarrierAnimation] subclass and an exhaustive switch arm wherever variants
/// are matched.
sealed class BarrierAnimation {
  /// Creates the shared configuration for a barrier animation variant.
  ///
  /// [duration] defaults to 750ms and [curve] to [Curves.easeOutCubic]. Both
  /// are inherited by every subclass via `super` parameters.
  const BarrierAnimation({
    this.duration = const Duration(milliseconds: 750),
    this.curve = Curves.easeOutCubic,
  });

  /// Duration of the entrance animation.
  ///
  /// The reverse exit uses the same duration.
  final Duration duration;

  /// Curve applied to the entrance.
  ///
  /// The reverse exit uses [Curve.flipped], so the exit mirrors the entrance
  /// without requiring a second curve to be specified.
  final Curve curve;
}

/// Fades the barrier and child in from fully transparent.
///
/// On dismiss the same fade plays in reverse, ending fully transparent.
final class FadeBarrier extends BarrierAnimation {
  /// Creates a fade-in/fade-out barrier animation.
  ///
  /// Inherits [duration] and [curve] defaults from [BarrierAnimation].
  const FadeBarrier({
    super.duration,
    super.curve,
  });
}

/// Slides the barrier and child down from above the top edge while also
/// fading in.
///
/// The opacity ride-along keeps the barrier from looking like a hard
/// rectangle entering the screen. On dismiss the motion reverses, sliding
/// back up off the top edge as it fades out.
final class SlideFromTopBarrier extends BarrierAnimation {
  /// Creates a slide-from-top (with fade) barrier animation.
  ///
  /// Inherits [duration] and [curve] defaults from [BarrierAnimation].
  const SlideFromTopBarrier({
    super.duration,
    super.curve,
  });
}

/// Slides the barrier and child up from below the bottom edge while also
/// fading in.
///
/// As with [SlideFromTopBarrier], the fade softens the entrance. On dismiss
/// the motion reverses, sliding back down off the bottom edge as it fades out.
final class SlideFromBottomBarrier extends BarrierAnimation {
  /// Creates a slide-from-bottom (with fade) barrier animation.
  ///
  /// Inherits [duration] and [curve] defaults from [BarrierAnimation].
  const SlideFromBottomBarrier({
    super.duration,
    super.curve,
  });
}
