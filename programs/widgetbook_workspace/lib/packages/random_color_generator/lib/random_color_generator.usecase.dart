// lib/packages/random_color_generator/lib/random_color_generator.usecase.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:random_color_generator/random_color_generator.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart'
    as widgetbook;

@widgetbook.UseCase(name: 'Palette', type: RandomColorGeneratorShowcase)
Widget randomColorGeneratorUseCase(BuildContext context) {
  final swatchCount = context.knobs.int.slider(
    label: 'swatch count',
    initialValue: 12,
    min: 1,
    max: 60,
  );

  return RandomColorGeneratorShowcase(swatchCount: swatchCount);
}

/// Showcase for [RandomColorGenerator] (a static utility, not a widget).
/// Generates a palette of swatches on each rebuild and inspects them with
/// the same isGenerated / toHex helpers the library exposes.
class RandomColorGeneratorShowcase extends StatefulWidget {
  const RandomColorGeneratorShowcase({required this.swatchCount, super.key});

  final int swatchCount;

  @override
  State<RandomColorGeneratorShowcase> createState() =>
      _RandomColorGeneratorShowcaseState();
}

class _RandomColorGeneratorShowcaseState
    extends State<RandomColorGeneratorShowcase> {
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _regenerate();
  }

  @override
  void didUpdateWidget(RandomColorGeneratorShowcase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.swatchCount != widget.swatchCount) {
      _regenerate();
    }
  }

  void _regenerate() {
    _colors = List.generate(
      widget.swatchCount,
      (_) => RandomColorGenerator.generate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              FilledButton.icon(
                onPressed: () => setState(_regenerate),
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerate'),
              ),
              const Gap(16),
              Text('${_colors.length} swatches'),
            ],
          ),
          const Gap(16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 160,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: _colors.length,
              itemBuilder: (context, i) => _Swatch(color: _colors[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final hex = RandomColorGenerator.toHex(color);
    final generated = RandomColorGenerator.isGenerated(color: color);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hex,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            generated ? 'in range ✓' : 'out of range',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
