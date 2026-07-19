// widgetbook_workspace/lib/packages/animated_barrier/fallback_chain.usecase.dart

// ignore_for_file: comment_references

import 'package:animated_widgets/animated_widgets.dart'
    show AnimatedBarrier, PopoverPosition;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

/// Pins an anchor to an extreme corner of the screen so the requested
/// [PopoverPosition] side cannot satisfy a wide child. Demonstrates the
/// fallback chain inside [_PopoverLayoutDelegate]: the popover walks
/// requested → orthogonal sides → center until a side fits.
@widgetbook.UseCase(name: 'Fallback chain', type: AnimatedBarrier)
Widget fallbackChainAnimatedBarrierUseCase(BuildContext context) {
  final corner = context.knobs.object.dropdown<_Corner>(
    label: 'anchor corner',
    options: _Corner.values,
    initialOption: _Corner.bottomRight,
    labelBuilder: (c) => c.name,
  );
  final preferredSide = context.knobs.object.dropdown<_Side>(
    label: 'preferred side (likely to fail)',
    options: _Side.values,
    initialOption: _Side.right,
    labelBuilder: (s) => s.name,
  );
  final childWidth = context.knobs.double.slider(
    label: 'child width',
    initialValue: 300,
    min: 80,
    max: 500,
    divisions: 21,
  );
  final tint = barrierColorKnob(context);

  return _FallbackScaffold(
    corner: corner,
    side: preferredSide,
    childWidth: childWidth,
    barrierColor: tint,
  );
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

enum _Side { above, below, left, right }

class _FallbackScaffold extends StatefulWidget {
  const _FallbackScaffold({
    required this.corner,
    required this.side,
    required this.childWidth,
    required this.barrierColor,
  });

  final _Corner corner;
  final _Side side;
  final double childWidth;
  final Color barrierColor;

  @override
  State<_FallbackScaffold> createState() => _FallbackScaffoldState();
}

class _FallbackScaffoldState extends State<_FallbackScaffold> {
  final GlobalKey _anchorKey = GlobalKey();

  Alignment _resolveAlignment() {
    switch (widget.corner) {
      case _Corner.topLeft:
        return Alignment.topLeft;
      case _Corner.topRight:
        return Alignment.topRight;
      case _Corner.bottomLeft:
        return Alignment.bottomLeft;
      case _Corner.bottomRight:
        return Alignment.bottomRight;
    }
  }

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: _resolveAlignment(),
          child: Builder(
            builder: (innerContext) => FilledButton(
              key: _anchorKey,
              onPressed: () {
                AnimatedBarrier(
                  position: _resolvePosition(),
                  barrierColor: widget.barrierColor,
                  childSize: Size(widget.childWidth, 100),
                  child: BarrierDemoCard(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Requested ${widget.side.name}, '
                        'anchored ${widget.corner.name}',
                        style: Theme.of(innerContext).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ).show(innerContext);
              },
              child: const Text('Anchor'),
            ),
          ),
        ),
      ),
    );
  }
}
