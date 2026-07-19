// widgetbook_workspace/lib/packages/animated_barrier/scrollable_list.usecase.dart

import 'package:animated_widgets/animated_widgets.dart'
    show AnimatedBarrier, FadeBarrier;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

/// Demonstrates [AnimatedBarrier.childSize] as a *maximum* constraint: a
/// 100-item [ListView] hits the height cap and scrolls inside the popover.
/// Item count is knob-driven so you can see the popover shrink to fit short
/// lists.
@widgetbook.UseCase(name: 'Scrollable list popover', type: AnimatedBarrier)
Widget scrollableListAnimatedBarrierUseCase(BuildContext context) {
  final itemCount = context.knobs.double
      .slider(
        label: 'item count',
        initialValue: 100,
        min: 1,
        max: 200,
        divisions: 199,
      )
      .toInt();
  final capHeight = context.knobs.double.slider(
    label: 'max height',
    initialValue: 360,
    min: 80,
    max: 600,
    divisions: 26,
  );
  final tint = barrierColorKnob(context);

  return Scaffold(
    body: Center(
      child: Builder(
        builder: (innerContext) => FilledButton(
          onPressed: () {
            AnimatedBarrier(
              childSize: Size(280, capHeight),
              barrierColor: tint,
              barrierAnimation: const FadeBarrier(),
              child: BarrierDemoCard(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  itemCount: itemCount,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) =>
                      ListTile(dense: true, title: Text('Item ${i + 1}')),
                ),
              ),
            ).show(innerContext);
          },
          child: Text('Open $itemCount-item list'),
        ),
      ),
    ),
  );
}
