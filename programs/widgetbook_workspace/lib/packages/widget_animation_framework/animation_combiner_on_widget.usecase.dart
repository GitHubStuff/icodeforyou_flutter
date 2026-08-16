// programs/widgetbook_workspace/lib/packages/widget_animation_framework/animation_combiner_on_widget.usecase.dart

import 'package:flutter/material.dart';
import 'package:widget_animation_framework/widget_animation_framework.dart'
    show AnimationCombinerOnWidget;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Size of the demonstration child.
const double _kChildSize = 120;

/// Presents [AnimationCombinerOnWidget] scrubbed by hand.
///
/// The widget owns no timeline — it only reads its animation — so the
/// workbench supplies the simplest possible source: an
/// [AlwaysStoppedAnimation] pinned to the `t` slider. Dragging the slider
/// *is* the timeline, which makes every intermediate frame inspectable in a
/// way a live controller never allows.
///
/// The three booleans toggle each optional tween between a representative
/// value and `null`, exercising the documented guarantee that a `null`
/// tween omits its transition widget from the tree entirely. With all
/// three off, the child renders untouched at any `t`.
///
/// The turns tween runs `0 → 1` — one full rotation — so the slider's
/// endpoints look identical for rotation while opacity and scale differ,
/// a useful reminder that turns are fractions of 360 degrees.
@widgetbook.UseCase(name: 'Scrubbed', type: AnimationCombinerOnWidget)
Widget buildAnimationCombinerOnWidgetUseCase(BuildContext context) {
  final t = context.knobs.double.slider(
    label: 't (timeline)',
    initialValue: 1,
    min: 0,
    max: 1,
  );
  final useOpacity = context.knobs.boolean(
    label: 'opacity 0 → 1',
    initialValue: true,
  );
  final useScale = context.knobs.boolean(
    label: 'scale 0.6 → 1.2',
    initialValue: true,
  );
  final useTurns = context.knobs.boolean(
    label: 'turns 0 → 1',
    initialValue: false,
  );

  return Center(
    child: AnimationCombinerOnWidget(
      animation: AlwaysStoppedAnimation<double>(t),
      opacity: useOpacity ? Tween<double>(begin: 0, end: 1) : null,
      scale: useScale ? Tween<double>(begin: 0.6, end: 1.2) : null,
      turns: useTurns ? Tween<double>(begin: 0, end: 1) : null,
      child: const FlutterLogo(size: _kChildSize),
    ),
  );
}
