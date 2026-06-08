// widgetbook_workspace/lib/packages/animated_barrier/anchored.usecase.dart

import 'package:animated_widgets/animated_widgets.dart'
    show AnimatedBarrier, PopoverPosition;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

/// Anchors the popover to a button at the center of the screen, with a knob
/// to pick the preferred side. Demonstrates [PopoverPosition.left] /
/// `.right` / `.above` / `.below` / `.center` and the fallback chain — the
/// anchor is centered, so all four sides fit comfortably.
@widgetbook.UseCase(name: 'Anchored to button', type: AnimatedBarrier)
Widget anchoredAnimatedBarrierUseCase(BuildContext context) {
  final side = context.knobs.object.dropdown<_Side>(
    label: 'preferred side',
    options: _Side.values,
    initialOption: _Side.below,
    labelBuilder: (s) => s.name,
  );
  final tint = barrierColorKnob(context);

  return _AnchoredScaffold(side: side, barrierColor: tint);
}

enum _Side { above, below, left, right, center }

class _AnchoredScaffold extends StatefulWidget {
  const _AnchoredScaffold({required this.side, required this.barrierColor});

  final _Side side;
  final Color barrierColor;

  @override
  State<_AnchoredScaffold> createState() => _AnchoredScaffoldState();
}

class _AnchoredScaffoldState extends State<_AnchoredScaffold> {
  final GlobalKey _anchorKey = GlobalKey();

  PopoverPosition _resolvePosition() {
    switch (widget.side) {
      case _Side.above:
        return PopoverPosition.above(_anchorKey);
      case _Side.below:
        return PopoverPosition.below(_anchorKey);
      case _Side.left:
        return PopoverPosition.left(_anchorKey);
      case _Side.right:
        return PopoverPosition.right(_anchorKey);
      case _Side.center:
        return PopoverPosition.center();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (innerContext) => FilledButton(
            key: _anchorKey,
            onPressed: () {
              AnimatedBarrier(
                position: _resolvePosition(),
                barrierColor: widget.barrierColor,
                childSize: const Size(220, 120),
                child: BarrierDemoCard(
                  child: Center(
                    child: Text(
                      'Anchored ${widget.side.name}',
                      style: Theme.of(innerContext).textTheme.titleMedium,
                    ),
                  ),
                ),
              ).show(innerContext);
            },
            child: const Text('Anchor button'),
          ),
        ),
      ),
    );
  }
}
