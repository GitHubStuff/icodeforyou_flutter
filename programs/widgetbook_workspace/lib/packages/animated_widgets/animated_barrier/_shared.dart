// widgetbook_workspace/lib/packages/animated_barrier/_shared.dart

import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// A theme-safe card used by every `animated_barrier` usecase. Avoids the
/// near-black appearance you get from M3's `surfaceTint` stacking onto an
/// already-dark surface at high elevation. Forces a flat surface that reads
/// as a card in both light and dark themes.
class BarrierDemoCard extends StatelessWidget {
  const BarrierDemoCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Named barrier-tint swatches surfaced as a knob. Every entry resolves to a
/// concrete non-nullable [Color] so it can be passed directly to
/// `AnimatedBarrier.barrierColor`. `black54` is the standard Material
/// barrier tint and is the initial option.
class BarrierTintKnob {
  const BarrierTintKnob._(this.label, this.color);

  final String label;
  final Color color;

  static const BarrierTintKnob black54 = BarrierTintKnob._(
    'black54 (default)',
    Colors.black54,
  );
  static const BarrierTintKnob black87 = BarrierTintKnob._(
    'black87',
    Colors.black87,
  );
  static const BarrierTintKnob white54 = BarrierTintKnob._(
    'white54',
    Colors.white54,
  );
  static const BarrierTintKnob indigo = BarrierTintKnob._(
    'indigo · 60%',
    Color(0x99303F9F),
  );
  static const BarrierTintKnob teal = BarrierTintKnob._(
    'teal · 60%',
    Color(0x9900897B),
  );
  static const BarrierTintKnob crimson = BarrierTintKnob._(
    'crimson · 60%',
    Color(0x99DC143C),
  );
  static const BarrierTintKnob clear = BarrierTintKnob._(
    'transparent',
    Color(0x00000000),
  );

  static const List<BarrierTintKnob> values = [
    black54,
    black87,
    white54,
    indigo,
    teal,
    crimson,
    clear,
  ];
}

/// Surfaces a `barrier tint` dropdown and returns the picked [Color].
/// Always returns a concrete colour — never `null` — so it can be passed
/// straight into `AnimatedBarrier.barrierColor`.
Color barrierColorKnob(BuildContext context) {
  final tint = context.knobs.object.dropdown<BarrierTintKnob>(
    label: 'barrier tint',
    options: BarrierTintKnob.values,
    initialOption: BarrierTintKnob.black54,
    labelBuilder: (t) => t.label,
  );
  return tint.color;
}
