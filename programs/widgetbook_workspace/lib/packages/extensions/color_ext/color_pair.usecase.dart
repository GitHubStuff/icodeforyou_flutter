// programs/widgetbook_workspace/lib/packages/extensions/color_ext/color_pair.usecase.dart

import 'package:extensions/color/color_pair.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Named preset pairs for the interactive dropdown.
///
/// Records give structural equality for free, which is what
/// `object.dropdown` needs to track the selected option; [ColorPair]
/// itself has identity equality only.
const List<({String label, ColorPair pair})> _kPresets = [
  (
    label: 'Black / White',
    pair: ColorPair(dark: Colors.black, light: Colors.white),
  ),
  (
    label: 'Indigo / Amber',
    pair: ColorPair(dark: Colors.indigo, light: Colors.amber),
  ),
  (
    label: 'Teal / Deep Orange',
    pair: ColorPair(dark: Colors.teal, light: Colors.deepOrange),
  ),
  (
    label: 'Grey 900 / Grey 100',
    pair: ColorPair(dark: Color(0xFF212121), light: Color(0xFFF5F5F5)),
  ),
];

/// Interactive playground: pick a preset pair, then flip the theme
/// addon between light and dark to watch [ColorPair.current] resolve.
@widgetbook.UseCase(name: 'Interactive', type: ColorPair)
Widget colorPairInteractive(BuildContext context) {
  final preset = context.knobs.object
      .dropdown<({String label, ColorPair pair})>(
        label: 'Preset',
        options: _kPresets,
        initialOption: _kPresets.first,
        labelBuilder: (option) => option.label,
      );

  return _ColorPairDemo(pair: preset.pair);
}

/// Static gallery of every preset at once, for side-by-side contrast
/// checks under either brightness.
@widgetbook.UseCase(name: 'Preset Gallery', type: ColorPair)
Widget colorPairGallery(BuildContext context) {
  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      for (final preset in _kPresets)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _ColorPairDemo(pair: preset.pair, title: preset.label),
        ),
    ],
  );
}

/// Renders one [ColorPair]: both endpoint swatches, the theme-resolved
/// [ColorPair.current] swatch, and the [ColorPair.isDark] /
/// [ColorPair.isLight] readouts.
class _ColorPairDemo extends StatelessWidget {
  const _ColorPairDemo({required this.pair, this.title});

  final ColorPair pair;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final titleText = title;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (titleText != null) ...[
              Text(titleText, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                _Swatch(label: 'dark', color: pair.dark),
                const SizedBox(width: 12),
                _Swatch(label: 'light', color: pair.light),
                const SizedBox(width: 12),
                _Swatch(label: 'current', color: pair.current(context)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'isDark: ${pair.isDark(context)}   '
              'isLight: ${pair.isLight(context)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// A labeled color square.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
