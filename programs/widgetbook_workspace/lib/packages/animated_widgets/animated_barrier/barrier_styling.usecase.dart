// widgetbook_workspace/lib/packages/animated_barrier/barrier_styling.usecase.dart

import 'package:animated_widgets/animated_widgets.dart'
    show AnimatedBarrier, FadeBarrier;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

/// Drives [AnimatedBarrier.barrierColor] from a swatch dropdown and an
/// alpha slider so the barrier tint can be evaluated against the underlying
/// content. The host renders a colorful background so a translucent barrier
/// is visually obvious.
@widgetbook.UseCase(name: 'Barrier styling', type: AnimatedBarrier)
Widget barrierStylingAnimatedBarrierUseCase(BuildContext context) {
  final swatch = context.knobs.object.dropdown<_Swatch>(
    label: 'barrier tint',
    options: _swatches,
    initialOption: _swatches.first,
    labelBuilder: (s) => s.label,
  );
  final alpha = context.knobs.double
      .slider(
        label: 'alpha (0–255)',
        initialValue: 138, // 0x8A ≈ black54
        min: 0,
        max: 255,
        divisions: 51,
      )
      .toInt();

  final barrierColor = swatch.color.withAlpha(alpha);

  return Scaffold(
    body: Stack(
      children: [
        const Positioned.fill(child: _ColorfulBackdrop()),
        Center(
          child: Builder(
            builder: (innerContext) => FilledButton(
              onPressed: () {
                AnimatedBarrier(
                  barrierColor: barrierColor,
                  barrierAnimation: const FadeBarrier(),
                  child: BarrierDemoCard(
                    child: Text(
                      'Tint: ${swatch.label} · α=$alpha',
                      style: Theme.of(innerContext).textTheme.titleMedium,
                    ),
                  ),
                ).show(innerContext);
              },
              child: const Text('Show with tinted barrier'),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Swatch {
  const _Swatch(this.label, this.color);
  final String label;
  final Color color;
}

const List<_Swatch> _swatches = [
  _Swatch('black', Colors.black),
  _Swatch('white', Colors.white),
  _Swatch('indigo', Colors.indigo),
  _Swatch('teal', Colors.teal),
  _Swatch('crimson', Color(0xFFDC143C)),
];

class _ColorfulBackdrop extends StatelessWidget {
  const _ColorfulBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFB3BA), Color(0xFFBAE1FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
