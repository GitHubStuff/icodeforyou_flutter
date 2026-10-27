// packages/counter_ring/lib/src/range_progress_ring.dart

import 'package:flutter/material.dart';

/// A circular ring that shows how far [currentValue] has travelled from
/// [startValue] toward [finishValue].
///
/// The ring is a thin wrapper around a determinate
/// [CircularProgressIndicator], sized to a square of [size] logical pixels,
/// with an optional [child] rendered at its centre. It is stateless and
/// performs no animation of its own: every rebuild simply draws the arc for
/// whatever [currentValue] it is given. To animate, drive [currentValue]
/// from an [AnimationController], a [TweenAnimationBuilder], a ticking
/// [Stream], or any other source that rebuilds the widget over time.
///
/// ## Direction
///
/// The ring supports both counting directions, determined solely by the
/// relative order of [startValue] and [finishValue]:
///
/// * **Count-up** (`startValue < finishValue`): the arc begins empty and
///   fills clockwise from twelve o'clock as [currentValue] rises toward
///   [finishValue]. A stopwatch or a "completed steps" indicator.
/// * **Count-down** (`startValue > finishValue`): the arc begins full and
///   unwinds counter-clockwise toward empty as [currentValue] falls toward
///   [finishValue]. A kitchen timer or a "time remaining" display.
///
/// In both cases the drawn arc represents *distance from the finish*: full
/// means "all of the range still ahead" only when counting down, and
/// "all of the range completed" when counting up. See [arcFraction] for the
/// exact mapping.
///
/// ## Value handling
///
/// The three values are plain [double]s in any unit the caller chooses —
/// seconds, metres, percentage points, bytes. Only their relative positions
/// matter. [currentValue] is clamped into the closed interval between
/// [startValue] and [finishValue], so a value that has overshot the finish
/// (or not yet reached the start) is drawn as full or empty respectively
/// rather than producing an out-of-range arc. See [progress].
///
/// The constructor asserts that [startValue] and [finishValue] differ,
/// because a zero-length range has no meaningful progress and would divide
/// by zero. This is a programming error, not a runtime condition, and is
/// therefore enforced with an [assert] rather than an exception in release
/// builds.
///
/// ## Theming
///
/// [color] and [backgroundColor] are forwarded verbatim to
/// [CircularProgressIndicator]. When either is `null`, the indicator falls
/// back to [ProgressIndicatorThemeData] from the ambient [Theme], and then
/// to the [ColorScheme] primary colour, exactly as a bare
/// [CircularProgressIndicator] would. The stroke ends are always rounded
/// ([StrokeCap.round]); callers who need square caps should compose a
/// [CircularProgressIndicator] directly.
///
/// ## Layout
///
/// The widget always occupies a [size] × [size] square regardless of the
/// constraints it receives; it does not expand to fill its parent. Wrap it
/// in a [LayoutBuilder] or compute [size] from [MediaQuery] if the ring
/// must scale with available space. [strokeWidth] is drawn *inside* the
/// square, so the visible ring's outer diameter equals [size] and its inner
/// diameter equals `size - 2 * strokeWidth`. [child], when present, is laid
/// out by a [Center] that spans the full square, including the area beneath
/// the stroke; constrain it yourself if it must stay within the inner disc.
///
/// ## Example
///
/// A ten-second countdown driven by a [TweenAnimationBuilder]:
///
/// ```dart
/// TweenAnimationBuilder<double>(
///   tween: Tween(begin: 10, end: 0),
///   duration: const Duration(seconds: 10),
///   builder: (context, remaining, _) => RangeProgressRing(
///     startValue: 10,
///     finishValue: 0,
///     currentValue: remaining,
///     size: 160,
///     strokeWidth: 12,
///     child: Text('${remaining.ceil()}s'),
///   ),
/// )
/// ```
///
/// A static "3 of 8 steps complete" indicator:
///
/// ```dart
/// const RangeProgressRing(
///   startValue: 0,
///   finishValue: 8,
///   currentValue: 3,
///   child: Text('3 / 8'),
/// )
/// ```
///
/// See also:
///
/// * [CircularProgressIndicator], which performs the actual painting and
///   whose determinate mode this widget configures.
/// * [ProgressIndicatorThemeData], for theming the ring colours globally.
/// * [LinearProgressIndicator], for the same information drawn as a bar.
class RangeProgressRing extends StatelessWidget {
  /// Creates a ring showing [currentValue]'s position between [startValue]
  /// and [finishValue].
  ///
  /// [startValue] and [finishValue] must differ; passing equal values
  /// triggers an assertion in debug mode. Their relative order determines
  /// the counting direction (see [isCountingDown]). [currentValue] may lie
  /// outside the range and is clamped (see [progress]).
  ///
  /// [size] defaults to `120` logical pixels and [strokeWidth] to `8`.
  /// Both are expected to be positive, and [strokeWidth] should be no more
  /// than half of [size] or the ring will paint over its own centre;
  /// neither constraint is asserted because [CircularProgressIndicator]
  /// tolerates degenerate values without throwing.
  ///
  /// [color], [backgroundColor], and [child] are optional; see the
  /// corresponding fields for their defaults.
  const RangeProgressRing({
    required this.startValue,
    required this.finishValue,
    required this.currentValue,
    this.size = 120,
    this.strokeWidth = 8,
    this.color,
    this.backgroundColor,
    this.child,
    super.key,
  }) : assert(
         startValue != finishValue,
         'startValue must differ from finishValue',
       );

  /// The value at which the range begins.
  ///
  /// This is the value at which [progress] is `0.0`. It may be greater or
  /// less than [finishValue], and may be negative; only its position
  /// relative to [finishValue] and [currentValue] matters. Must not equal
  /// [finishValue].
  final double startValue;

  /// The value at which the range ends.
  ///
  /// This is the value at which [progress] is `1.0`. When less than
  /// [startValue] the ring counts down (see [isCountingDown]). Must not
  /// equal [startValue].
  final double finishValue;

  /// The value whose position within the range is displayed.
  ///
  /// Expressed in the same units as [startValue] and [finishValue]. Values
  /// outside the closed interval between them are clamped: anything at or
  /// beyond [finishValue] is drawn as fully travelled, and anything at or
  /// before [startValue] as not yet started. No assertion is made, so a
  /// timer that overruns or a sensor reading that overshoots simply pins
  /// the ring at its end state.
  final double currentValue;

  /// The width and height, in logical pixels, of the square the ring
  /// occupies.
  ///
  /// Defaults to `120`. The ring's outer diameter equals this value; the
  /// widget does not grow or shrink to fit its parent's constraints.
  final double size;

  /// The thickness of the arc, in logical pixels.
  ///
  /// Defaults to `8`. Drawn inside the [size] square, so a thicker stroke
  /// reduces the inner diameter available to [child] rather than enlarging
  /// the widget. Forwarded to [CircularProgressIndicator.strokeWidth].
  final double strokeWidth;

  /// The colour of the travelled (foreground) arc.
  ///
  /// When `null`, [CircularProgressIndicator] resolves the colour from
  /// [ProgressIndicatorThemeData.color], falling back to
  /// [ColorScheme.primary]. Forwarded to
  /// [CircularProgressIndicator.color].
  final Color? color;

  /// The colour of the untravelled (track) portion of the ring.
  ///
  /// When `null`, [CircularProgressIndicator] resolves the colour from
  /// [ProgressIndicatorThemeData.circularTrackColor]; if that is also
  /// `null`, no track is painted and only the foreground arc is visible.
  /// Forwarded to [CircularProgressIndicator.backgroundColor].
  final Color? backgroundColor;

  /// Optional content rendered at the centre of the ring.
  ///
  /// Typically a [Text] showing the remaining time, a percentage, or a
  /// step count, but any widget is accepted. It is placed with a [Center]
  /// spanning the full [size] square, so content wider than
  /// `size - 2 * strokeWidth` will overlap the stroke. When `null`, nothing
  /// is drawn inside the ring and the [Stack] contains only the indicator.
  final Widget? child;

  /// Whether the ring unwinds toward empty rather than filling toward full.
  ///
  /// `true` when [finishValue] is less than [startValue]. Because the
  /// constructor guarantees the two values differ, this is exactly the
  /// negation of "counting up"; there is no neutral state.
  ///
  /// This flag determines how [progress] is mapped to [arcFraction]:
  /// counting down draws the *remaining* fraction, counting up draws the
  /// *travelled* fraction, so that in both directions the arc shrinks
  /// toward empty as a countdown expires and grows toward full as a
  /// count-up completes.
  bool get isCountingDown => finishValue < startValue;

  /// The fraction of the range that [currentValue] has travelled from
  /// [startValue], clamped to `0.0`–`1.0`.
  ///
  /// Computed as `(currentValue - startValue) / (finishValue - startValue)`.
  /// Because both numerator and denominator carry the sign of the counting
  /// direction, the ratio is direction-independent: it is `0.0` at
  /// [startValue] and `1.0` at [finishValue] whether counting up or down,
  /// and `0.5` at the midpoint either way.
  ///
  /// Values of [currentValue] outside the range produce ratios below `0.0`
  /// or above `1.0`, which are clamped before being returned, so this
  /// getter never yields an out-of-range result for finite inputs. The
  /// constructor's assertion that the span is non-zero prevents division
  /// by zero.
  ///
  /// This is the *logical* progress. For the fraction of the ring actually
  /// painted, which flips for countdowns, see [arcFraction].
  double get progress {
    final span = finishValue - startValue;
    final travelled = currentValue - startValue;
    return (travelled / span).clamp(0.0, 1.0);
  }

  /// The fraction of the ring that is painted, in `0.0`–`1.0`.
  ///
  /// Equal to [progress] when counting up, so the arc grows as the value
  /// approaches [finishValue]; equal to `1 - progress` when counting down,
  /// so the arc shrinks as the value approaches [finishValue]. In both
  /// cases the painted arc therefore represents the portion of the journey
  /// that a user would intuitively expect to see — completed work for a
  /// count-up, remaining time for a countdown.
  ///
  /// Passed directly as [CircularProgressIndicator.value].
  double get arcFraction => isCountingDown ? 1 - progress : progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: arcFraction,
            strokeWidth: strokeWidth,
            color: color,
            backgroundColor: backgroundColor,
            strokeCap: StrokeCap.round,
          ),
          if (child != null) Center(child: child),
        ],
      ),
    );
  }
}
