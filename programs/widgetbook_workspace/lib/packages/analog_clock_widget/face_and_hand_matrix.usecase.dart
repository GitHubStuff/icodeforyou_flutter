// programs/widgetbook_workspace/lib/packages/analog_clock_widget/face_and_hand_matrix.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:analog_clock_widget/analog_clock_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '_shared.dart';

@widgetbook.UseCase(name: 'Face × Hand matrix', type: AnalogClock)
Widget faceAndHandMatrixAnalogClockUseCase(BuildContext context) {
  final radius = context.knobs.double.slider(
    label: 'radius',
    initialValue: 70,
    min: 30,
    max: 120,
  );

  // face and hand are the matrix axes — every other ClockStyle property is
  // shared across the whole grid and surfaced via knobs.
  final baseStyle = clockStyleKnobs(
    context,
    axes: const {ClockStyleAxis.faceStyle, ClockStyleAxis.handStyle},
  );

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 100),
            for (final hand in HandStyle.values)
              Expanded(child: Center(child: _Label(hand.name))),
          ],
        ),
        const Gap(8),
        for (final face in ClockFaceStyle.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 100, child: _Label(face.name)),
                for (final hand in HandStyle.values)
                  Expanded(
                    child: Center(
                      child: AnalogClock(
                        radius: radius,
                        style: baseStyle.copyWith(
                          faceStyle: face,
                          handStyle: hand,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    );
  }
}
