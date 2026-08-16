// packages/widget_animation_framework/lib/src/animation_combiner_on_widget/animation_combiner_on_widget.dart

import 'package:flutter/widgets.dart';

/// {@template animation_combiner_on_widget}
/// Composes scale, opacity and rotation transitions over a [child], all driven
/// by a single externally owned [animation].
///
/// Each tween is optional. Passing `null` omits the corresponding transition
/// widget from the tree entirely, so the widget never pays for an effect it
/// does not apply.
///
/// This widget owns no timeline. It reads [animation] and nothing more, so the
/// caller is free to drive it forward, in reverse, on repeat, from a scroll
/// offset, or from any other [Animation] source. Two instances sharing one
/// animation stay in lockstep by construction.
///
/// Rebuilds are not driven per frame. Each transition subscribes to
/// [animation] itself, so this widget rebuilds only when its own configuration
/// changes.
///
/// [turns] is expressed in *fractions of a full rotation*, matching
/// [RotationTransition]. A value of `1.0` is 360 degrees, so a sweep from 40
/// degrees to 720 degrees is `Tween<double>(begin: 40 / 360, end: 2)`.
///
/// ```dart
/// AnimationCombinerOnWidget(
///   animation: myController,
///   opacity: Tween<double>(begin: 0, end: 1),
///   scale: Tween<double>(begin: 0.8, end: 1.2),
///   turns: Tween<double>(begin: 40 / 360, end: 2),
///   child: const Icon(Icons.star),
/// )
/// ```
/// {@endtemplate}
class AnimationCombinerOnWidget extends StatelessWidget {
  /// {@macro animation_combiner_on_widget}
  const AnimationCombinerOnWidget({
    required this.animation,
    required this.child,
    this.opacity,
    this.turns,
    this.scale,
    super.key,
  });

  /// The timeline every supplied tween is evaluated against.
  ///
  /// Ownership, playback and disposal belong to the caller.
  final Animation<double> animation;

  /// Scale factors, where `1` is the intrinsic size of [child].
  final Tween<double>? scale;

  /// Opacity values, clamped by [FadeTransition] to the range `0` to `1`.
  final Tween<double>? opacity;

  /// Rotation expressed in turns, where `1` is a full 360 degree rotation.
  final Tween<double>? turns;

  /// The widget the transitions are applied to.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var composed = child;

    final opacityTween = opacity;
    if (opacityTween != null) {
      composed = FadeTransition(
        opacity: opacityTween.animate(animation),
        child: composed,
      );
    }

    final scaleTween = scale;
    if (scaleTween != null) {
      composed = ScaleTransition(
        scale: scaleTween.animate(animation),
        child: composed,
      );
    }

    final turnsTween = turns;
    if (turnsTween != null) {
      composed = RotationTransition(
        turns: turnsTween.animate(animation),
        child: composed,
      );
    }

    return composed;
  }
}
