// lib/packages/slider_directional/slider_directional_vertical.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:slider_directional/slider_directional.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// Two vertical use cases for the Directional slider:
//   - Top:    min at the top,    max at the bottom.
//   - Bottom: min at the bottom, max at the top.
// Both: min 0, max 100, step 1, with a "Show Label" toggle that shows or
// hides a value readout next to the slider.

const double _kSliderMainAxis = 320;
const double _kVerticalStageWidth = 200;
const double _kVerticalStageHeight = _kSliderMainAxis + 48;

// ---------------------------------------------------------------------------
// Vertical — Top (min at top)
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'Vertical — Top (min at top)', type: Directional)
Widget directionalVerticalTop(BuildContext context) {
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
  type: Directional,
)
Widget directionalVerticalBottom(BuildContext context) {
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
// Stage
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
