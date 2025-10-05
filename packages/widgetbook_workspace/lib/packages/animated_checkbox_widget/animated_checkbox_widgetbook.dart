// wb_animated_checkbox_widgetbook.dart v0.05
// ignore_for_file: depend_on_referenced_packages
import 'package:animated_checkbox_widget/animated_checkbox_widget.dart'
    show AnimatedCheckbox, PlatformOptimizer;
import 'package:extensions/widget_ext/widget_ext.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

part 'widgetbook_demo_widgets.dart';

@widgetbook.UseCase(name: 'Default', type: AnimatedCheckbox)
Widget buildAnimatedCheckboxDefaultCase(BuildContext context) {
  return Center(
    child: AnimatedCheckbox(
      width: 100.0,
      strokeColor: Colors.green,
      draw: true,
      onAnimationComplete: (isDrawn) {
        debugPrint('Animation completed: $isDrawn');
      },
    ).withBorder(color: Colors.red),
  );
}

@widgetbook.UseCase(name: 'Custom Shapes', type: AnimatedCheckbox)
Widget buildAnimatedCheckboxCustomShapesCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Custom Checkmark Shapes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Gap(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                AnimatedCheckbox(
                  width: 80,
                  strokeColor: Colors.red,
                  draw: true,
                  startOffset: const Offset(0.2, 0.5),
                  midOffset: const Offset(0.4, 0.8),
                  finishOffset: const Offset(0.8, 0.2),
                  duration: const Duration(milliseconds: 1500),
                  onAnimationComplete: (_) {},
                ),
                const Gap(8),
                const Text('Compact'),
              ],
            ),
            Column(
              children: [
                AnimatedCheckbox(
                  width: 80,
                  strokeColor: Colors.green,
                  draw: true,
                  startOffset: const Offset(0.0, 0.3),
                  midOffset: const Offset(0.6, 0.9),
                  finishOffset: const Offset(1.0, 0.1),
                  duration: const Duration(milliseconds: 1500),
                  onAnimationComplete: (_) {},
                ),
                const Gap(8),
                const Text('Wide'),
              ],
            ),
            Column(
              children: [
                AnimatedCheckbox(
                  width: 80,
                  strokeColor: Colors.blue,
                  draw: true,
                  startOffset: const Offset(0.1, 0.7),
                  midOffset: const Offset(0.3, 0.9),
                  finishOffset: const Offset(0.9, 0.3),
                  duration: const Duration(milliseconds: 1500),
                  onAnimationComplete: (_) {},
                ),
                const Gap(8),
                const Text('Shallow'),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Animation Curves', type: AnimatedCheckbox)
Widget buildAnimatedCheckboxCurvesCase(BuildContext context) {
  return const _AnimationCurvesDemo();
}

@widgetbook.UseCase(name: 'Interactive Demo', type: AnimatedCheckbox)
Widget buildAnimatedCheckboxInteractiveCase(BuildContext context) {
  return const _InteractiveCheckboxDemo();
}

@widgetbook.UseCase(name: 'Extreme Shapes', type: AnimatedCheckbox)
Widget buildAnimatedCheckboxExtremeShapesCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Extreme Custom Shapes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Gap(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                AnimatedCheckbox(
                  width: 80,
                  strokeColor: Colors.red,
                  draw: true,
                  startOffset: const Offset(0.0, 0.0),
                  midOffset: const Offset(0.5, 0.5),
                  finishOffset: const Offset(1.0, 1.0),
                  duration: const Duration(milliseconds: 1500),
                  onAnimationComplete: (_) {},
                ),
                const Gap(8),
                const Text('Diagonal'),
              ],
            ),
            Column(
              children: [
                AnimatedCheckbox(
                  width: 80,
                  strokeColor: Colors.green,
                  draw: true,
                  startOffset: const Offset(0.5, 0.0),
                  midOffset: const Offset(0.2, 0.5),
                  finishOffset: const Offset(0.8, 1.0),
                  duration: const Duration(milliseconds: 1500),
                  onAnimationComplete: (_) {},
                ),
                const Gap(8),
                const Text('Lightening'),
              ],
            ),
            Column(
              children: [
                AnimatedCheckbox(
                  width: 80,
                  strokeColor: Colors.blue,
                  draw: true,
                  startOffset: const Offset(0.0, 1.0),
                  midOffset: const Offset(0.5, 0.2),
                  finishOffset: const Offset(1.0, 0.8),
                  duration: const Duration(milliseconds: 1500),
                  onAnimationComplete: (_) {},
                ),
                const Gap(8),
                const Text('Inverted'),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Platform Optimized', type: AnimatedCheckbox)
Widget buildAnimatedCheckboxPlatformCase(BuildContext context) {
  final isHighPerformance = PlatformOptimizer.shouldUseHighPerformanceMode();
  final platformName = PlatformOptimizer.getPlatformName();

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Platform: $platformName',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          'High Performance: $isHighPerformance',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Gap(20),
        AnimatedCheckbox(
          width: isHighPerformance ? 150.0 : 100.0,
          strokeColor: isHighPerformance ? Colors.green : Colors.blue,
          draw: true,
          curve: isHighPerformance ? Curves.elasticOut : Curves.easeInQuart,
          duration: Duration(milliseconds: isHighPerformance ? 800 : 1200),
          onAnimationComplete: (isDrawn) {
            debugPrint(
              'Platform optimized animation completed: $isDrawn on $platformName',
            );
          },
        ),
        const Gap(10),
        Text(
          'Optimized for $platformName',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Dissolve Effect', type: AnimatedCheckbox)
Widget buildAnimatedCheckboxDissolveCase(BuildContext context) {
  return const Center(child: _DissolveDemo());
}

@widgetbook.UseCase(name: 'Performance Test', type: AnimatedCheckbox)
Widget buildAnimatedCheckboxPerformanceCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Performance Test - 9 Custom Shapes & Curves',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const Gap(16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final colors = [
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.purple,
              Colors.orange,
              Colors.teal,
              Colors.pink,
              Colors.indigo,
              Colors.amber,
            ];

            final curves = [
              Curves.easeInQuart,
              Curves.bounceOut,
              Curves.elasticOut,
              Curves.linear,
              Curves.easeInOutBack,
              Curves.fastOutSlowIn,
              Curves.easeInCubic,
              Curves.decelerate,
              Curves.easeOutExpo,
            ];

            final offsets = [
              (Offset(0.0, 0.5), Offset(0.5, 1.0), Offset(1.0, 0.0)), // default
              (Offset(0.2, 0.4), Offset(0.4, 0.8), Offset(0.8, 0.2)), // compact
              (Offset(0.0, 0.3), Offset(0.6, 0.9), Offset(1.0, 0.1)), // wide
              (Offset(0.1, 0.7), Offset(0.3, 0.9), Offset(0.9, 0.3)), // shallow
              (
                Offset(0.0, 0.0),
                Offset(0.5, 0.5),
                Offset(1.0, 1.0),
              ), // diagonal
              (
                Offset(0.5, 0.0),
                Offset(0.2, 0.5),
                Offset(0.8, 1.0),
              ), // lightning
              (
                Offset(0.0, 1.0),
                Offset(0.5, 0.2),
                Offset(1.0, 0.8),
              ), // inverted
              (Offset(0.1, 0.6), Offset(0.4, 0.9), Offset(0.9, 0.1)), // custom1
              (Offset(0.0, 0.4), Offset(0.6, 1.0), Offset(1.0, 0.0)), // custom2
            ];

            final offset = offsets[index];

            return AnimatedCheckbox(
              width: 60,
              strokeColor: colors[index],
              draw: true,
              startOffset: offset.$1,
              midOffset: offset.$2,
              finishOffset: offset.$3,
              curve: curves[index],
              duration: Duration(milliseconds: 1000 + (index * 150)),
              onAnimationComplete: (_) {},
            );
          },
        ),
        const Gap(16),
        Text(
          'Each uses different shapes & curves on ${PlatformOptimizer.getPlatformName()}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
