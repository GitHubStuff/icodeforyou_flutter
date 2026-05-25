// lib/packages/slider_directional/slider_directional_horizontal.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:slider_directional/slider_directional.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// Two horizontal use cases for the Directional slider:
//   - Left:  min on the left,  max on the right.
//   - Right: min on the right, max on the left.
// Both: min 0, max 100, step 1, with a "Show Label" toggle that shows or
// hides a value readout above the slider.

const double _kSliderMainAxis = 320;
const double _kHorizontalStageWidth = _kSliderMainAxis + 48;
const double _kHorizontalStageHeight = 200;

// ---------------------------------------------------------------------------
// Horizontal — Left (min on left)
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Horizontal — Left (min on left)', type: Directional)
Widget directionalHorizontalLeft(BuildContext context) {
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
  type: Directional,
)
Widget directionalHorizontalRight(BuildContext context) {
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
// Stage
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
  static const double _step = 1;

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
              child: Directional(
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
