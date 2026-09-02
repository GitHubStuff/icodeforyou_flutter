// packages/animated_widgets/lib/src/crossfade_widgets/crossfade_axis.dart

/// {@template animated_widgets.cross_fade_axis}
/// Which horizontal end of a stepper is "forward".
///
/// Consumed by [CrossFadeWidgets.direction] to orient its stepper row:
/// the value is translated to `DirectionalSliderAndButtons.minValueFirst`,
/// mirroring the slider's endpoints and the `(−)` / `(+)` buttons together.
/// "Forward" means stepping toward higher indices — toward the last child.
///
/// This affects only the stepper's layout; the cross-fade animation itself
/// is direction-agnostic.
/// {@endtemplate}
///
/// See also:
///
///  * [CrossFadeWidgets], the stepper-driven carousel this orients.
enum CrossFadeAxis {
  /// Forward steps move right.
  ///
  /// The minimum — the first child — sits at the left end of the slider,
  /// with the `(−)` button beside it; `(+)` sits on the right. This is the
  /// conventional left-to-right arrangement and the default.
  left,

  /// Forward steps move left.
  ///
  /// The mirror of [left]: the minimum — the first child — sits at the
  /// right end of the slider, with the `(−)` button beside it; `(+)` sits
  /// on the left.
  right,
}
