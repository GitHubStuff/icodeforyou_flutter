// widgetbook_workspace/lib/packages/animated_barrier/slide_down.usecase.dart

import 'package:animated_widgets/animated_widgets.dart'
    show AnimatedBarrier, SlideFromTopBarrier;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

/// Dedicated demo for `SlideFromTopBarrier` — the barrier enters by sliding
/// down from the top of the screen and exits the same way in reverse.
/// Knobs cover duration, curve, and barrier tint so the motion can be
/// tuned without leaving the usecase.
@widgetbook.UseCase(name: 'Slide down (from top)', type: AnimatedBarrier)
Widget slideDownAnimatedBarrierUseCase(BuildContext context) {
  final durationMs = context.knobs.double
      .slider(
        label: 'duration (ms)',
        initialValue: 350,
        min: 50,
        max: 2000,
        divisions: 39,
      )
      .toInt();
  final curve = context.knobs.object.dropdown<_LabeledCurve>(
    label: 'curve',
    options: _curves,
    initialOption: _curves.first,
    labelBuilder: (c) => c.label,
  );
  final tint = barrierColorKnob(context);

  return Scaffold(
    body: Center(
      child: Builder(
        builder: (innerContext) => FilledButton(
          onPressed: () {
            AnimatedBarrier(
              barrierAnimation: SlideFromTopBarrier(
                duration: Duration(milliseconds: durationMs),
                curve: curve.curve,
              ),
              barrierColor: tint,
              child: BarrierDemoCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Slide down',
                      style: Theme.of(innerContext).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('${durationMs}ms · ${curve.label}'),
                  ],
                ),
              ),
            ).show(innerContext);
          },
          child: const Text('Slide down from top'),
        ),
      ),
    ),
  );
}

class _LabeledCurve {
  const _LabeledCurve(this.label, this.curve);
  final String label;
  final Curve curve;
}

const List<_LabeledCurve> _curves = [
  _LabeledCurve('easeOutCubic', Curves.easeOutCubic),
  _LabeledCurve('linear', Curves.linear),
  _LabeledCurve('easeIn', Curves.easeIn),
  _LabeledCurve('easeOut', Curves.easeOut),
  _LabeledCurve('easeInOut', Curves.easeInOut),
  _LabeledCurve('bounceOut', Curves.bounceOut),
  _LabeledCurve('elasticOut', Curves.elasticOut),
  _LabeledCurve('decelerate', Curves.decelerate),
];
