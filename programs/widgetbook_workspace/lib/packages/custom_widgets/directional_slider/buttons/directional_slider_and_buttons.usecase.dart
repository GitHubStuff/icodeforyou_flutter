// lib/packages/custom_widgets/lib/src/directional_slider/buttons/directional_slider_and_buttons.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:custom_widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DirectionalSliderAndButtons)
Widget directionalSliderAndButtonsUseCase(BuildContext context) {
  final axis = context.knobs.object.dropdown<Axis>(
    label: 'axis',
    options: Axis.values,
    initialOption: Axis.horizontal,
    labelBuilder: (a) => a.name,
  );

  final minValueFirst = context.knobs.boolean(
    label: 'minValueFirst',
    initialValue: true,
  );

  final min = context.knobs.double.slider(
    label: 'min',
    initialValue: 0,
    min: -50,
    max: 0,
  );

  final max = context.knobs.double.slider(
    label: 'max',
    initialValue: 100,
    min: 1,
    max: 200,
  );

  final step = context.knobs.double.slider(
    label: 'step',
    initialValue: 1,
    min: 0.5,
    max: 25,
  );

  return _DirectionalSliderShowcase(
    axis: axis,
    minValueFirst: minValueFirst,
    min: min,
    max: max <= min ? min + 1 : max,
    step: step,
  );
}

class _DirectionalSliderShowcase extends StatefulWidget {
  const _DirectionalSliderShowcase({
    required this.axis,
    required this.minValueFirst,
    required this.min,
    required this.max,
    required this.step,
  });

  final Axis axis;
  final bool minValueFirst;
  final double min;
  final double max;
  final double step;

  @override
  State<_DirectionalSliderShowcase> createState() =>
      _DirectionalSliderShowcaseState();
}

class _DirectionalSliderShowcaseState
    extends State<_DirectionalSliderShowcase> {
  late DirectionalController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DirectionalController(initial: widget.min);
  }

  @override
  void didUpdateWidget(_DirectionalSliderShowcase old) {
    super.didUpdateWidget(old);
    final clamped = _controller.value.clamp(widget.min, widget.max).toDouble();
    if (clamped != _controller.value) _controller.value = clamped;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slider = ValueListenableBuilder<double>(
      valueListenable: _controller,
      builder: (context, value, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'value: ${value.toStringAsFixed(1)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Gap(12),
          SizedBox(
            width: widget.axis == Axis.horizontal ? 320 : 80,
            height: widget.axis == Axis.horizontal ? 80 : 320,
            child: DirectionalSliderAndButtons(
              controller: _controller,
              axis: widget.axis,
              minValueFirst: widget.minValueFirst,
              min: widget.min,
              max: widget.max,
              step: widget.step,
              onChanged: (_) {},
            ),
          ),
        ],
      ),
    );

    return Center(child: slider);
  }
}
