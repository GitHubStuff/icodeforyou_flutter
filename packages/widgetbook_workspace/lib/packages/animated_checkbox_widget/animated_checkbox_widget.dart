// animated_checkbox.dart
// ignore_for_file: depend_on_referenced_packages
import 'package:animated_checkbox_widget/animated_checkbox_widget.dart'
    show AnimatedCheckbox, PlatformOptimizer;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: AnimatedCheckbox)
Widget buildAnimatedCheckboxDefaultCase(BuildContext context) {
  return Center(
    child: AnimatedCheckbox(
      width: 100.0,
      strokeColor: Colors.purple,
      draw: true,
      duration: const Duration(seconds: 1),
      onAnimationComplete: (isDrawn) {
        debugPrint('Animation completed: $isDrawn');
      },
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive Demo', type: AnimatedCheckbox)
Widget buildAnimatedCheckboxInteractiveCase(BuildContext context) {
  return const _InteractiveCheckboxDemo();
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

@widgetbook.UseCase(name: 'Color Variations', type: AnimatedCheckbox)
Widget buildAnimatedCheckboxColorsCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AnimatedCheckbox(
              width: 80,
              strokeColor: Colors.red,
              draw: true,
              duration: const Duration(milliseconds: 1000),
              onAnimationComplete: (_) {},
            ),
            AnimatedCheckbox(
              width: 80,
              strokeColor: Colors.green,
              draw: true,
              duration: const Duration(milliseconds: 1200),
              onAnimationComplete: (_) {},
            ),
            AnimatedCheckbox(
              width: 80,
              strokeColor: Colors.blue,
              draw: true,
              duration: const Duration(milliseconds: 1400),
              onAnimationComplete: (_) {},
            ),
          ],
        ),
        const Gap(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AnimatedCheckbox(
              width: 80,
              strokeColor: Colors.orange,
              draw: true,
              duration: const Duration(milliseconds: 1600),
              onAnimationComplete: (_) {},
            ),
            AnimatedCheckbox(
              width: 80,
              strokeColor: Colors.purple,
              draw: true,
              duration: const Duration(milliseconds: 1800),
              onAnimationComplete: (_) {},
            ),
            AnimatedCheckbox(
              width: 80,
              strokeColor: Colors.teal,
              draw: true,
              duration: const Duration(milliseconds: 2000),
              onAnimationComplete: (_) {},
            ),
          ],
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Size Variations', type: AnimatedCheckbox)
Widget buildAnimatedCheckboxSizesCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Size Variations', style: Theme.of(context).textTheme.titleLarge),
        const Gap(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                AnimatedCheckbox(
                  width: 50,
                  strokeColor: Colors.indigo,
                  draw: true,
                  duration: const Duration(milliseconds: 800),
                  onAnimationComplete: (_) {},
                ),
                const Gap(8),
                Text('Small (50px)'),
                Text(
                  '${PlatformOptimizer.getOptimalParticleCount(50)} particles',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Column(
              children: [
                AnimatedCheckbox(
                  width: 100,
                  strokeColor: Colors.indigo,
                  draw: true,
                  duration: const Duration(milliseconds: 1000),
                  onAnimationComplete: (_) {},
                ),
                const Gap(8),
                Text('Medium (100px)'),
                Text(
                  '${PlatformOptimizer.getOptimalParticleCount(100)} particles',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Column(
              children: [
                AnimatedCheckbox(
                  width: 150,
                  strokeColor: Colors.indigo,
                  draw: true,
                  duration: const Duration(milliseconds: 1200),
                  onAnimationComplete: (_) {},
                ),
                const Gap(8),
                Text('Large (150px)'),
                Text(
                  '${PlatformOptimizer.getOptimalParticleCount(150)} particles',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        const Gap(20),
        Text(
          'Particle counts shown are what PlatformOptimizer suggests\nfor your current platform, but the widget works great\nwithout needing to know these numbers!',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
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
          'Performance Test - 9 Simultaneous Animations',
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

            return AnimatedCheckbox(
              width: 60,
              strokeColor: colors[index],
              draw: true,
              duration: Duration(milliseconds: 1000 + (index * 150)),
              onAnimationComplete: (_) {},
            );
          },
        ),
        const Gap(16),
        Text(
          'Optimized for ${PlatformOptimizer.getPlatformName()}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

// Interactive demo widget
class _InteractiveCheckboxDemo extends StatefulWidget {
  const _InteractiveCheckboxDemo();

  @override
  State<_InteractiveCheckboxDemo> createState() =>
      _InteractiveCheckboxDemoState();
}

class _InteractiveCheckboxDemoState extends State<_InteractiveCheckboxDemo> {
  bool _shouldDraw = true;
  String _status = 'Ready';

  void _toggleAnimation() {
    setState(() {
      _shouldDraw = !_shouldDraw;
      _status = _shouldDraw ? 'Drawing...' : 'Dissolving...';
    });
  }

  void _onAnimationComplete(bool isDrawn) {
    setState(() {
      _status = isDrawn ? 'Draw Complete' : 'Dissolve Complete';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Interactive Demo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(20),
          AnimatedCheckbox(
            width: 150,
            strokeColor: Colors.deepPurple,
            draw: _shouldDraw,
            duration: const Duration(milliseconds: 1500),
            onAnimationComplete: _onAnimationComplete,
          ),
          const Gap(20),
          Text(
            'Status: $_status',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: _toggleAnimation,
            child: Text(_shouldDraw ? 'Start Dissolve' : 'Start Draw'),
          ),
        ],
      ),
    );
  }
}

// Dissolve demo widget
class _DissolveDemo extends StatefulWidget {
  const _DissolveDemo();

  @override
  State<_DissolveDemo> createState() => _DissolveDemoState();
}

class _DissolveDemoState extends State<_DissolveDemo> {
  bool _isDissolving = false;
  String _status = 'Ready to dissolve';

  void _startDissolve() {
    if (_isDissolving) return;

    setState(() {
      _isDissolving = true;
      _status = 'Dissolving...';
    });
  }

  void _onDissolveComplete(bool isDrawn) {
    setState(() {
      _isDissolving = false;
      _status = isDrawn ? 'Drawn' : 'Dissolved - Tap to restart';
    });

    // Auto-restart after dissolve completes
    if (!isDrawn) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _status = 'Ready to dissolve';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Dissolve Effect Demo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(20),
          GestureDetector(
            onTap: _startDissolve,
            child: AnimatedCheckbox(
              width: 150,
              strokeColor: Colors.deepOrange,
              draw: false, // Always dissolve
              duration: const Duration(milliseconds: 2000),
              onAnimationComplete: _onDissolveComplete,
            ),
          ),
          const Gap(20),
          Text(_status, style: Theme.of(context).textTheme.titleMedium),
          const Gap(16),
          Text(
            'Tap the checkmark to see dissolve effect',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
