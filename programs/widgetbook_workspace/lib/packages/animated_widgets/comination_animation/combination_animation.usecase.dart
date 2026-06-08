// widgetbook_workspace/lib/animated_widgets/combination_animation.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

/// A single [CombinationAnimation].
///
/// Scale and opacity animate from `0` up to the values chosen by the
/// `scale` and `opacity` knobs, over `duration` using `curve`. Changing
/// any knob restarts the animation (see [_replayable]).
@widgetbook.UseCase(name: 'Single', type: CombinationAnimation)
Widget buildCombinationAnimationSingleUseCase(BuildContext context) {
  final scale = _scaleKnob(context);
  final opacity = _opacityKnob(context);
  final curve = _curveKnob(context);
  final duration = _durationKnob(context);

  return _replayable(
    ValueKey<int>(Object.hash(scale, opacity, curve, duration)),
    CombinationAnimation(
      scale: AnimationTween.up(finish: scale),
      opacity: AnimationTween.up(finish: opacity),
      curve: curve,
      duration: duration,
      child: const _DemoBox(label: 'Single'),
    ),
  );
}

/// Three `combinationAnimation` calls chained on one widget via
/// [CombinationAnimationX].
///
/// Chaining stacks one widget per call and runs every animation in
/// parallel from `t = 0` — here with deliberately different curves and
/// durations, so the transforms compose and visibly desync mid-flight.
/// The composed end state still resolves to `scale` / `opacity`.
@widgetbook.UseCase(name: 'Chained x3 (parallel)', type: CombinationAnimation)
Widget buildCombinationAnimationChainedUseCase(BuildContext context) {
  final scale = _scaleKnob(context);
  final opacity = _opacityKnob(context);

  const child = _DemoBox(label: 'Chained x3');
  final animation = child
      // Innermost: grow to the target scale.
      .combinationAnimation(
        scale: AnimationTween(start: 1, finish: scale),
        curve: Curves.elasticOut,
        duration: const Duration(milliseconds: 900),
      )
      // Middle: pop in from zero.
      .combinationAnimation(
        scale: AnimationTween.up(),
        curve: Curves.easeOutBack,
        duration: const Duration(milliseconds: 600),
      )
      // Outermost: fade in to the target opacity (scale held).
      .combinationAnimation(
        scale: const AnimationTween(start: 1, finish: 1),
        opacity: AnimationTween.up(finish: opacity),
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 450),
      );

  return _replayable(ValueKey<int>(Object.hash(scale, opacity)), animation);
}

/// Three [CombinationAnimationStep]s run back-to-back on a single timeline
/// via `combinationAnimationSequenced` ([CombinationAnimationX]).
///
/// The steps are continuous (each step's start matches the previous
/// step's finish), so scale flows `0 -> 1 -> scale -> 1` and opacity holds
/// at the chosen value after the first fade-in. Contrast with the chained
/// use case, which runs its phases in parallel.
@widgetbook.UseCase(name: 'Sequenced x3', type: CombinationAnimationSequenced)
Widget buildCombinationAnimationSequencedUseCase(BuildContext context) {
  final scale = _scaleKnob(context);
  final opacity = _opacityKnob(context);

  const child = _DemoBox(label: 'Sequenced x3');
  final animation = child.combinationAnimationSequenced(
    <CombinationAnimationStep>[
      // 1) Pop + fade in.
      CombinationAnimationStep(
        scale: AnimationTween.up(),
        opacity: AnimationTween.up(finish: opacity),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      ),
      // 2) Grow to the target scale, holding opacity.
      CombinationAnimationStep(
        scale: AnimationTween(start: 1, finish: scale),
        opacity: AnimationTween(start: opacity, finish: opacity),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      ),
      // 3) Settle back to 1.0 with an elastic overshoot, holding opacity.
      CombinationAnimationStep(
        scale: AnimationTween(start: scale, finish: 1),
        opacity: AnimationTween(start: opacity, finish: opacity),
        duration: const Duration(milliseconds: 450),
        curve: Curves.elasticOut,
      ),
    ],
  );

  return _replayable(ValueKey<int>(Object.hash(scale, opacity)), animation);
}

/// Scale knob: `0.0` to `2.0` in steps of `0.1`.
double _scaleKnob(BuildContext context) => context.knobs.double.slider(
      label: 'scale',
      min: 0,
      max: 2,
      divisions: 20,
      initialValue: 1,
    );

/// Opacity knob: `0.0` to `1.0` in steps of `0.1`.
double _opacityKnob(BuildContext context) => context.knobs.double.slider(
      label: 'opacity',
      min: 0,
      max: 1,
      divisions: 10,
      initialValue: 1,
    );

/// Curve knob backed by [_curveOptions].
Curve _curveKnob(BuildContext context) =>
    context.knobs.object.dropdown<Curve>(
      label: 'curve',
      options: _curveOptions.keys.toList(),
      initialOption: Curves.linear,
      labelBuilder: (curve) => _curveOptions[curve] ?? '$curve',
    );

/// Duration knob: `250ms` to `1250ms` in steps of `10ms`.
Duration _durationKnob(BuildContext context) => Duration(
      milliseconds: context.knobs.int.slider(
        label: 'duration (ms)',
        min: 250,
        max: 1250,
        divisions: 100,
        initialValue: 1250,
      ),
    );

/// Wraps [animation] so that a change to [key] (derived from the knob
/// values) tears down and rebuilds the subtree, replaying the animation
/// from `t = 0` — otherwise a completed `TweenAnimationBuilder` would only
/// re-render its final frame when knobs change.
Widget _replayable(Key key, Widget animation) =>
    Center(child: KeyedSubtree(key: key, child: animation));

/// Curve options offered by the `curve` knob, paired with display labels.
const Map<Curve, String> _curveOptions = <Curve, String>{
  Curves.linear: 'linear',
  Curves.ease: 'ease',
  Curves.easeIn: 'easeIn',
  Curves.easeOut: 'easeOut',
  Curves.easeInOut: 'easeInOut',
  Curves.fastOutSlowIn: 'fastOutSlowIn',
  Curves.decelerate: 'decelerate',
  Curves.easeOutBack: 'easeOutBack',
  Curves.bounceOut: 'bounceOut',
  Curves.elasticOut: 'elasticOut',
};

/// Themed demo target. Uses [ColorScheme] roles so it renders correctly in
/// both light and dark Widgetbook themes.
class _DemoBox extends StatelessWidget {
  const _DemoBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: 128,
        height: 128,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
