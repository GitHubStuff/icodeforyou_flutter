// widgetbook/lib/animated_widgets/length_colored_border_field/length_colored_border_field.usecase.dart

// ignore_for_file: public_member_api_docs

import 'package:animated_widgets/animated_widgets.dart'
    show ColorPoint, ColorPointRamp, LengthColoredBorderField;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: LengthColoredBorderField)
Widget lengthColoredBorderFieldUseCase(BuildContext context) {
  final color0 = context.knobs.color(
    label: 'Color @ 0+',
    initialValue: const Color(0xFF800080),
  );
  final color1 = context.knobs.color(
    label: 'Color @ threshold 1',
    initialValue: const Color(0xFF00C853),
  );
  final color2 = context.knobs.color(
    label: 'Color @ threshold 2',
    initialValue: const Color(0xFFFFC107),
  );
  final color3 = context.knobs.color(
    label: 'Color @ threshold 3',
    initialValue: const Color(0xFFD32F2F),
  );

  final threshold1 = context.knobs.int.slider(
    label: 'Threshold 1',
    initialValue: 3,
    min: 1,
    max: 30,
  );
  final threshold2 = context.knobs.int.slider(
    label: 'Threshold 2',
    initialValue: 6,
    min: 1,
    max: 30,
  );
  final threshold3 = context.knobs.int.slider(
    label: 'Threshold 3',
    initialValue: 9,
    min: 1,
    max: 30,
  );

  final fontSize = context.knobs.double.slider(
    label: 'Font size',
    initialValue: 16,
    min: 10,
    max: 32,
  );

  final maxLength = context.knobs.int.slider(
    label: 'Max length (0 = no cap)',
    initialValue: 15,
    min: 0,
    max: 50,
  );

  return _LengthColoredBorderFieldUseCaseBody(
    color0: color0,
    color1: color1,
    color2: color2,
    color3: color3,
    threshold1: threshold1,
    threshold2: threshold2,
    threshold3: threshold3,
    fontSize: fontSize,
    maxLength: maxLength == 0 ? null : maxLength,
  );
}

class _LengthColoredBorderFieldUseCaseBody extends StatelessWidget {
  const _LengthColoredBorderFieldUseCaseBody({
    required this.color0,
    required this.color1,
    required this.color2,
    required this.color3,
    required this.threshold1,
    required this.threshold2,
    required this.threshold3,
    required this.fontSize,
    required this.maxLength,
  });

  final Color color0;
  final Color color1;
  final Color color2;
  final Color color3;
  final int threshold1;
  final int threshold2;
  final int threshold3;
  final double fontSize;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final ramp = _safeRamp();
    // DefaultTextStyle is the active resolved text style for this subtree —
    // its color always tracks the current light/dark theme. Merging the knob
    // font size onto it preserves the theme-correct color.
    final fieldStyle = DefaultTextStyle.of(context).style.copyWith(
      fontSize: fontSize,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LengthColoredBorderField(
              ramp: ramp,
              style: fieldStyle,
              maxLength: maxLength,
            ),
            const SizedBox(height: 24),
            _RampLegend(ramp: ramp),
          ],
        ),
      ),
    );
  }

  /// Builds a ramp from the knob values, dropping any threshold that would
  /// violate the strictly-ascending contract. Keeps the use case stable when
  /// the user drags sliders past one another.
  ColorPointRamp _safeRamp() {
    final points = <ColorPoint>[
      ColorPoint(point: 0, color: color0),
    ];
    if (threshold1 > 0) {
      points.add(ColorPoint(point: threshold1, color: color1));
    }
    if (threshold2 > points.last.point) {
      points.add(ColorPoint(point: threshold2, color: color2));
    }
    if (threshold3 > points.last.point) {
      points.add(ColorPoint(point: threshold3, color: color3));
    }
    return ColorPointRamp(points);
  }
}

class _RampLegend extends StatelessWidget {
  const _RampLegend({required this.ramp});

  final ColorPointRamp ramp;

  @override
  Widget build(BuildContext context) {
    final labelStyle = DefaultTextStyle.of(context).style.copyWith(
      fontWeight: FontWeight.w500,
    );

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (final p in ramp.points)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: p.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Text('${p.point}+', style: labelStyle),
            ],
          ),
      ],
    );
  }
}
