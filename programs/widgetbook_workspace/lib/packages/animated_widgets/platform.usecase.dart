// lib/packages/animated_widgets/platform.usecase.dart

import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: PlatformIdentifier)
Widget platformIdentifierDefault(BuildContext context) {
  const optimizer = PlatformOptimizer();
  final sampleWidth = context.knobs.double.slider(
    label: 'Sample widget width',
    initialValue: 100,
    min: 10,
    max: 400,
  );

  return Center(
    child: Card(
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform: ${optimizer.getCurrentPlatformName()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Optimal particle count (width ${sampleWidth.toInt()}): '
              '${optimizer.calculateOptimalParticleCount(sampleWidth)}',
            ),
            const SizedBox(height: 8),
            Text(
              'Optimal frame rate: '
              '${optimizer.calculateOptimalFrameRate().inMicroseconds}µs',
            ),
            const SizedBox(height: 8),
            Text(
              'Particle step: ${optimizer.calculateParticleStep()}',
            ),
            const SizedBox(height: 8),
            Text(
              'High-performance mode: '
              '${optimizer.isHighPerformanceModeEnabled()}',
            ),
          ],
        ),
      ),
    ),
  );
}
