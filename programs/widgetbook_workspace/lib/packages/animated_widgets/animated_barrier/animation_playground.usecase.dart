// widgetbook_workspace/lib/packages/animated_barrier/animation_playground.usecase.dart

import 'package:animated_widgets/animated_widgets.dart'
    show
        AnimatedBarrier,
        BarrierAnimation,
        FadeBarrier,
        SlideFromBottomBarrier,
        SlideFromTopBarrier;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

/// Lets a designer feel each [BarrierAnimation] variant with adjustable
/// duration and curve. The popover is centered so attention stays on the
/// motion itself, not on positioning.
@widgetbook.UseCase(name: 'Animation playground', type: AnimatedBarrier)
Widget animationPlaygroundAnimatedBarrierUseCase(BuildContext context) {
  final variant = context.knobs.object.dropdown<_Variant>(
    label: 'animation variant',
    options: _Variant.values,
    initialOption: _Variant.fade,
    labelBuilder: (v) => v.name,
  );
  final durationMs = context.knobs.double
      .slider(
        label: 'duration (ms)',
        initialValue: 750,
        min: 0,
        max: 5000,
        divisions: 100,
      )
      .toInt();
  final curve = context.knobs.object.dropdown<_LabeledCurve>(
    label: 'curve',
    options: _curves,
    initialOption: _curves.first,
    labelBuilder: (c) => c.label,
  );
  final tint = barrierColorKnob(context);

  final animation = _buildAnimation(
    variant,
    Duration(milliseconds: durationMs),
    curve.curve,
  );

  return Scaffold(
    body: Center(
      child: Builder(
        builder: (innerContext) => FilledButton(
          onPressed: () {
            AnimatedBarrier(
              barrierAnimation: animation,
              barrierColor: tint,
              child: BarrierDemoCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      variant.name,
                      style: Theme.of(innerContext).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('${durationMs}ms · ${curve.label}'),
                  ],
                ),
              ),
            ).show(innerContext);
          },
          child: const Text('Play animation'),
        ),
      ),
    ),
  );
}

enum _Variant { fade, slideFromTop, slideFromBottom }

BarrierAnimation _buildAnimation(
  _Variant variant,
  Duration duration,
  Curve curve,
) {
  switch (variant) {
    case _Variant.fade:
      return FadeBarrier(duration: duration, curve: curve);
    case _Variant.slideFromTop:
      return SlideFromTopBarrier(duration: duration, curve: curve);
    case _Variant.slideFromBottom:
      return SlideFromBottomBarrier(duration: duration, curve: curve);
  }
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
