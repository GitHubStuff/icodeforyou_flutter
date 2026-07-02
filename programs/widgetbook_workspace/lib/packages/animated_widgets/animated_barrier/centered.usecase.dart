// widgetbook_workspace/lib/packages/animated_barrier/centered.usecase.dart

import 'package:animated_widgets/animated_widgets.dart' show AnimatedBarrier;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

/// The simplest possible call: no [PopoverPosition], so the popover centers
/// itself on the screen. Knobs cover the user-facing toggles that don't
/// require an anchor.
@widgetbook.UseCase(name: 'Centered', type: AnimatedBarrier)
Widget centeredAnimatedBarrierUseCase(BuildContext context) {
  final barrierDismissible = context.knobs.boolean(
    label: 'barrierDismissible',
    initialValue: true,
  );
  context.knobs.boolean(
    label: 'hideStatusBar',
    initialValue: true,
  );
  final tint = barrierColorKnob(context);

  return Scaffold(
    body: Center(
      child: Builder(
        builder: (innerContext) => FilledButton(
          onPressed: () {
            AnimatedBarrier(
              barrierDismissible: barrierDismissible,
              barrierColor: tint,
              child: BarrierDemoCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Centered',
                      style: Theme.of(innerContext).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No anchor — the popover sits in the middle of the '
                      'safe area.',
                    ),
                  ],
                ),
              ),
            ).show(innerContext);
          },
          child: const Text('Show centered popover'),
        ),
      ),
    ),
  );
}
