// programs/widgetbook_workspace/lib/packages/widget_animation_framework/animation_controller_widget.usecase.dart

import 'package:flutter/material.dart';
import 'package:widget_animation_framework/widget_animation_framework.dart'
    show AnimationCombinerOnWidget, AnimationControllerWidget;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Size of the demonstration child.
const double _kChildSize = 120;

/// Vertical gap between the animated child and the replay button.
const double _kGap = 24;

/// The curves offered by the `curve` knob.
///
/// [Curve] constants carry no names, so each entry pairs one with a label
/// for the dropdown.
const List<({String name, Curve curve})> _kCurves =
    <({String name, Curve curve})>[
      (name: 'easeInOut', curve: Curves.easeInOut),
      (name: 'linear', curve: Curves.linear),
      (name: 'decelerate', curve: Curves.decelerate),
      (name: 'easeOutBack', curve: Curves.easeOutBack),
      (name: 'elasticOut', curve: Curves.elasticOut),
      (name: 'bounceOut', curve: Curves.bounceOut),
    ];

/// Presents [AnimationControllerWidget] doing the one thing it does: playing
/// forward once on mount.
///
/// Because the run is mount-triggered, replaying means remounting: the
/// Replay button bumps a generation counter used as the subtree's [ValueKey],
/// which tears the widget down and inserts a fresh one. Changing the
/// `duration` or `curve` knob rebuilds the whole use-case, resetting that
/// counter — so knob changes also replay, which is exactly what you want
/// when tuning either value.
///
/// The [builder] composes an [AnimationCombinerOnWidget] fading and scaling
/// in, mirroring the pairing the class documentation prescribes: this widget
/// is the timeline half, the combiner the composition half. Completion is
/// reported through `onCompleted`, which here logs.
@widgetbook.UseCase(name: 'Play on mount', type: AnimationControllerWidget)
Widget buildAnimationControllerWidgetUseCase(BuildContext context) {
  final durationMs = context.knobs.double
      .slider(
        label: 'duration (ms)',
        initialValue: 2500,
        min: 250,
        max: 5000,
      )
      .round();
  final curveOption = context.knobs.object
      .dropdown<({String name, Curve curve})>(
        label: 'curve',
        options: _kCurves,
        initialOption: _kCurves.first,
        labelBuilder: (option) => option.name,
      );

  var generation = 0;

  return StatefulBuilder(
    builder: (context, setState) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          KeyedSubtree(
            key: ValueKey<int>(generation),
            child: AnimationControllerWidget(
              duration: Duration(milliseconds: durationMs),
              curve: curveOption.curve,
              onCompleted: () =>
                  debugPrint('AnimationControllerWidget.onCompleted'),
              builder: (context, animation) => AnimationCombinerOnWidget(
                animation: animation,
                opacity: Tween<double>(begin: 0, end: 1),
                scale: Tween<double>(begin: 0.6, end: 1),
                child: const FlutterLogo(size: _kChildSize),
              ),
            ),
          ),
          const SizedBox(height: _kGap),
          FilledButton.icon(
            onPressed: () => setState(() => generation++),
            icon: const Icon(Icons.replay),
            label: const Text('Replay'),
          ),
        ],
      ),
    ),
  );
}
