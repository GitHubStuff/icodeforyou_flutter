// lib/packages/custom_widgets/lib/src/directional_slider/slider/directional_slider.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:custom_widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DirectionalSlider)
Widget directionalSliderUseCase(BuildContext context) {
  final rotation = context.knobs.object.dropdown<Axis>(
    label: 'rotation',
    options: Axis.values,
    initialOption: Axis.horizontal,
    labelBuilder: (a) => a.name,
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
    rotation: rotation,
    min: min,
    max: max <= min ? min + 1 : max,
    step: step,
  );
}

class _DirectionalSliderShowcase extends StatefulWidget {
  const _DirectionalSliderShowcase({
    required this.rotation,
    required this.min,
    required this.max,
    required this.step,
  });

  final Axis rotation;
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
    final horizontal = widget.rotation == Axis.horizontal;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<double>(
            valueListenable: _controller,
            builder: (_, value, __) => Text(
              'value: ${value.toStringAsFixed(1)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const Gap(16),
          SizedBox(
            width: horizontal ? 320 : 80,
            height: horizontal ? 80 : 320,
            child: DirectionalSlider(
              controller: _controller,
              rotation: widget.rotation,
              min: widget.min,
              max: widget.max,
              step: widget.step,
              onChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }
}
