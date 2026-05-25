// lib/packages/slider_stepper/slider_stepper.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:slider_directional/slider_directional.dart' show DirectionalController, SliderDirection;
import 'package:slider_stepper/slider_stepper.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// Four use cases for SliderStepper — one per [SliderDirection]:
//   - Horizontal — Left:    min on the left,   max on the right.
//   - Horizontal — Right:   min on the right,  max on the left.
//   - Vertical   — Top:     min at the top,    max at the bottom.
//   - Vertical   — Bottom:  min at the bottom, max at the top.
//
// All cases: min 0, max 100, step 5, with a "Show Label" knob that toggles a
// live value readout. Tap the (−) / (+) buttons to step; press-and-hold to
// auto-repeat. The slider itself stays draggable.

const double _kSliderMainAxis = 320;
const double _kHorizontalStageWidth = _kSliderMainAxis + 160;
const double _kHorizontalStageHeight = 200;
const double _kVerticalStageWidth = 220;
const double _kVerticalStageHeight = _kSliderMainAxis + 160;

// ---------------------------------------------------------------------------
// Horizontal — Left (min on left)
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Horizontal — Left (min on left)',
  type: SliderStepper,
)
Widget sliderStepperHorizontalLeft(BuildContext context) {
  final showLabel = context.knobs.boolean(
    label: 'Show Label',
    initialValue: true,
  );
  return _HorizontalStage(
    direction: SliderDirection.left,
    showLabel: showLabel,
  );
}

// ---------------------------------------------------------------------------
// Horizontal — Right (min on right)
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Horizontal — Right (min on right)',
  type: SliderStepper,
)
Widget sliderStepperHorizontalRight(BuildContext context) {
  final showLabel = context.knobs.boolean(
    label: 'Show Label',
    initialValue: true,
  );
  return _HorizontalStage(
    direction: SliderDirection.right,
    showLabel: showLabel,
  );
}

// ---------------------------------------------------------------------------
// Vertical — Top (min at top)
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Vertical — Top (min at top)',
  type: SliderStepper,
)
Widget sliderStepperVerticalTop(BuildContext context) {
  final showLabel = context.knobs.boolean(
    label: 'Show Label',
    initialValue: true,
  );
  return _VerticalStage(
    direction: SliderDirection.top,
    showLabel: showLabel,
  );
}

// ---------------------------------------------------------------------------
// Vertical — Bottom (min at bottom)
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Vertical — Bottom (min at bottom)',
  type: SliderStepper,
)
Widget sliderStepperVerticalBottom(BuildContext context) {
  final showLabel = context.knobs.boolean(
    label: 'Show Label',
    initialValue: true,
  );
  return _VerticalStage(
    direction: SliderDirection.bottom,
    showLabel: showLabel,
  );
}

// ---------------------------------------------------------------------------
// Horizontal stage
// ---------------------------------------------------------------------------

class _HorizontalStage extends StatefulWidget {
  const _HorizontalStage({required this.direction, required this.showLabel});

  final SliderDirection direction;
  final bool showLabel;

  @override
  State<_HorizontalStage> createState() => _HorizontalStageState();
}

class _HorizontalStageState extends State<_HorizontalStage> {
  static const double _min = 0;
  static const double _max = 100;
  static const double _step = 5;

  late final DirectionalController _controller;
  double _value = _min;

  @override
  void initState() {
    super.initState();
    _controller = DirectionalController(initial: _min);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(double v) => setState(() => _value = v);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: _kHorizontalStageWidth,
      height: _kHorizontalStageHeight,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.showLabel)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Value: ${_value.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            SizedBox(
              width: _kSliderMainAxis,
              child: SliderStepper(
                controller: _controller,
                direction: widget.direction,
                min: _min,
                max: _max,
                step: _step,
                onChanged: _onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vertical stage
// ---------------------------------------------------------------------------

class _VerticalStage extends StatefulWidget {
  const _VerticalStage({required this.direction, required this.showLabel});

  final SliderDirection direction;
  final bool showLabel;

  @override
  State<_VerticalStage> createState() => _VerticalStageState();
}

class _VerticalStageState extends State<_VerticalStage> {
  static const double _min = 0;
  static const double _max = 100;
  static const double _step = 5;

  late final DirectionalController _controller;
  double _value = _min;

  @override
  void initState() {
    super.initState();
    _controller = DirectionalController(initial: _min);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(double v) => setState(() => _value = v);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: _kVerticalStageWidth,
      height: _kVerticalStageHeight,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.showLabel)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Value: ${_value.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            SizedBox(
              height: _kSliderMainAxis,
              child: SliderStepper(
                controller: _controller,
                direction: widget.direction,
                min: _min,
                max: _max,
                step: _step,
                onChanged: _onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
