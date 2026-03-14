// lib/packages/random_color_generator/random_color_generator.usecase.dart

// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:random_color_generator/random_color_generator.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// generate — random color swatches
// ---------------------------------------------------------------------------

class _GenerateHost extends StatefulWidget {
  const _GenerateHost({required this.count, required this.alpha});

  final int count;
  final int alpha;

  @override
  State<_GenerateHost> createState() => _GenerateHostState();
}

class _GenerateHostState extends State<_GenerateHost> {
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _colors = _generate();
  }

  @override
  void didUpdateWidget(_GenerateHost old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count || old.alpha != widget.alpha) {
      _colors = _generate();
    }
  }

  List<Color> _generate() => List.generate(
        widget.count,
        (_) => RandomColorGenerator.generate(alpha: widget.alpha),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colors.map(_swatch).toList(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(() => _colors = _generate()),
          child: const Text('Regenerate'),
        ),
      ],
    );
  }

  Widget _swatch(Color color) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

@widgetbook.UseCase(name: 'generate', type: RandomColorGenerator)
Widget randomColorGeneratorGenerate(BuildContext context) {
  final count = context.knobs.double.slider(
    label: 'Count',
    initialValue: 12,
    min: 1,
    max: 40,
  );

  final alpha = context.knobs.double.slider(
    label: 'Alpha (0–255)',
    initialValue: 255,
    min: 0,
    max: 255,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: _GenerateHost(count: count.toInt(), alpha: alpha.toInt()),
    ),
  );
}

// ---------------------------------------------------------------------------
// toHex / fromHex — round-trip display
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'toHex & fromHex', type: RandomColorGenerator)
Widget randomColorGeneratorHex(BuildContext context) {
  final colors = List.generate(
    8,
    (_) => RandomColorGenerator.generate(),
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: _HexRoundTripGrid(colors: colors),
    ),
  );
}

class _HexRoundTripGrid extends StatefulWidget {
  const _HexRoundTripGrid({required this.colors});

  final List<Color> colors;

  @override
  State<_HexRoundTripGrid> createState() => _HexRoundTripGridState();
}

class _HexRoundTripGridState extends State<_HexRoundTripGrid> {
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _colors = widget.colors;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colors.map(_hexTile).toList(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(
            () => _colors = List.generate(
              8,
              (_) => RandomColorGenerator.generate(),
            ),
          ),
          child: const Text('Regenerate'),
        ),
      ],
    );
  }

  Widget _hexTile(Color color) {
    final hex = RandomColorGenerator.toHex(color);
    final roundTripped = RandomColorGenerator.fromHex(hex);
    final textColor = RandomColorGenerator.contrastingTextColor(color);
    final matches = color.toARGB32() == roundTripped.toARGB32();

    return Container(
      width: 110,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: matches
            ? null
            : Border.all(color: Colors.red, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        hex,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// contrastingTextColor — legibility demo
// ---------------------------------------------------------------------------

@widgetbook.UseCase(name: 'contrastingTextColor', type: RandomColorGenerator)
Widget randomColorGeneratorContrast(BuildContext context) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: _ContrastGrid(),
    ),
  );
}

class _ContrastGrid extends StatefulWidget {
  const _ContrastGrid();

  @override
  State<_ContrastGrid> createState() => _ContrastGridState();
}

class _ContrastGridState extends State<_ContrastGrid> {
  List<Color> _colors = List.generate(
    12,
    (_) => RandomColorGenerator.generate(),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _colors.map(_contrastTile).toList(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(
            () => _colors = List.generate(
              12,
              (_) => RandomColorGenerator.generate(),
            ),
          ),
          child: const Text('Regenerate'),
        ),
      ],
    );
  }

  Widget _contrastTile(Color background) {
    final textColor = RandomColorGenerator.contrastingTextColor(background);
    final label = textColor == Colors.white ? 'White' : 'Black';

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
