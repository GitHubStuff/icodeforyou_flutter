import 'package:flutter/material.dart';
import 'package:random_color_generator/random_color_generator.dart'
    show RandomColorGenerator;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// ---------------------------------------------------------------------------
// Use Case 1: generate() — Random Color Grid
// ---------------------------------------------------------------------------

/// Displays a grid of randomly generated colors with hex labels and
/// contrasting text, demonstrating [RandomColorGenerator.generate].
class _GenerateShowcase extends StatefulWidget {
  const _GenerateShowcase({required this.count, required this.alpha});

  final int count;
  final int alpha;

  @override
  State<_GenerateShowcase> createState() => _GenerateShowcaseState();
}

class _GenerateShowcaseState extends State<_GenerateShowcase> {
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _regenerate();
  }

  @override
  void didUpdateWidget(covariant _GenerateShowcase old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count || old.alpha != widget.alpha) {
      _regenerate();
    }
  }

  void _regenerate() {
    _colors = List.generate(
      widget.count,
      (_) => RandomColorGenerator.generate(alpha: widget.alpha),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => setState(_regenerate),
            icon: const Icon(Icons.refresh),
            label: const Text('Regenerate'),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _colors.length,
            itemBuilder: (context, index) {
              final color = _colors[index];
              final textColor = RandomColorGenerator.contrastingTextColor(
                color,
              );
              return Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  RandomColorGenerator.toHex(color),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Random Color Grid', type: _GenerateShowcase)
Widget buildGenerateUseCase(BuildContext context) {
  return _GenerateShowcase(
    count: context.knobs.int.slider(
      label: 'Color count',
      initialValue: 16,
      min: 4,
      max: 64,
    ),
    alpha: context.knobs.int.slider(
      label: 'Alpha (0-255)',
      initialValue: 255,
      min: 0,
      max: 255,
    ),
  );
}

// ---------------------------------------------------------------------------
// Use Case 2: toHex() / fromHex() — Hex Roundtrip
// ---------------------------------------------------------------------------

/// Demonstrates [RandomColorGenerator.toHex] and [RandomColorGenerator.fromHex]
/// by converting a color to hex and back, proving the roundtrip.
class _HexRoundtripShowcase extends StatefulWidget {
  const _HexRoundtripShowcase();

  @override
  State<_HexRoundtripShowcase> createState() => _HexRoundtripShowcaseState();
}

class _HexRoundtripShowcaseState extends State<_HexRoundtripShowcase> {
  late Color _original;
  late String _hex;
  late Color _restored;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    _original = RandomColorGenerator.generate();
    _hex = RandomColorGenerator.toHex(_original);
    _restored = RandomColorGenerator.fromHex(_hex);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => setState(_generate),
            icon: const Icon(Icons.refresh),
            label: const Text('Generate New Color'),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SwatchCard(label: 'Original', color: _original),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.arrow_forward, size: 32),
              ),
              Column(
                children: [
                  Text('toHex()', style: textStyle),
                  const SizedBox(height: 8),
                  SelectableText(
                    _hex,
                    style: textStyle?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.arrow_forward, size: 32),
              ),
              _SwatchCard(label: 'fromHex()', color: _restored),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _original.toARGB32() == _restored.toARGB32()
                ? 'Roundtrip match ✓'
                : 'Mismatch ✗',
            style: textStyle?.copyWith(
              color: _original.toARGB32() == _restored.toARGB32()
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwatchCard extends StatelessWidget {
  const _SwatchCard({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textColor = RandomColorGenerator.contrastingTextColor(color);
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          alignment: Alignment.center,
          child: Text(
            RandomColorGenerator.toHex(color),
            style: TextStyle(
              color: textColor,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Hex Roundtrip', type: _HexRoundtripShowcase)
Widget buildHexRoundtripUseCase(BuildContext context) {
  return const _HexRoundtripShowcase();
}

// ---------------------------------------------------------------------------
// Use Case 3: fromHex() — Manual Hex Input
// ---------------------------------------------------------------------------

/// Lets the user type a hex string and see the resulting color via
/// [RandomColorGenerator.fromHex].
class _FromHexShowcase extends StatefulWidget {
  const _FromHexShowcase();

  @override
  State<_FromHexShowcase> createState() => _FromHexShowcaseState();
}

class _FromHexShowcaseState extends State<_FromHexShowcase> {
  final _controller = TextEditingController(text: '#FFFF8040');
  Color? _parsed;
  String? _error;

  @override
  void initState() {
    super.initState();
    _parse();
  }

  void _parse() {
    try {
      final color = RandomColorGenerator.fromHex(_controller.text);
      setState(() {
        _parsed = color;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _parsed = null;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 240,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Hex (#AARRGGBB)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _parse(),
            ),
          ),
          const SizedBox(height: 24),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red))
          else if (_parsed != null) ...[
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _parsed,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              alignment: Alignment.center,
              child: Text(
                RandomColorGenerator.toHex(_parsed!),
                style: TextStyle(
                  color: RandomColorGenerator.contrastingTextColor(_parsed!),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Manual Hex Input', type: _FromHexShowcase)
Widget buildFromHexUseCase(BuildContext context) {
  return const _FromHexShowcase();
}

// ---------------------------------------------------------------------------
// Use Case 4: contrastingTextColor() — Contrast Demo
// ---------------------------------------------------------------------------

/// Shows a spectrum of colors with their computed contrasting text color,
/// demonstrating [RandomColorGenerator.contrastingTextColor].
class _ContrastShowcase extends StatelessWidget {
  const _ContrastShowcase({required this.sampleCount});

  final int sampleCount;

  @override
  Widget build(BuildContext context) {
    final colors = List.generate(
      sampleCount,
      (_) => RandomColorGenerator.generate(),
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final bg = colors[index];
        final fg = RandomColorGenerator.contrastingTextColor(bg);
        final hex = RandomColorGenerator.toHex(bg);
        final luminance = bg.computeLuminance().toStringAsFixed(3);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              '$hex  •  luminance: $luminance  •  text: ${fg == Colors.white ? "white" : "black"}',
              style: TextStyle(color: fg, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }
}

@widgetbook.UseCase(name: 'Contrasting Text Color', type: _ContrastShowcase)
Widget buildContrastUseCase(BuildContext context) {
  return _ContrastShowcase(
    sampleCount: context.knobs.int.slider(
      label: 'Sample count',
      initialValue: 20,
      min: 5,
      max: 50,
    ),
  );
}
