// programs/widgetbook_workspace/lib/packages/ext_int/ext_int.usecase.dart

import 'package:ext_int/ext_int.dart' show ExtInt;
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

/// Anchor component for the `ext_int` Widgetbook use cases.
///
/// Dart extensions are not [Type]s, so Widgetbook cannot group use cases
/// under [ExtInt] directly. This widget exists purely to give the
/// `toColor`, `toSpeech` / `toSimpleSpeech`, and `toUtc` use cases a home in
/// the navigation tree; it renders whatever [child] it is given inside a
/// consistent, padded frame.
class ExtIntShowcase extends StatelessWidget {
  /// Creates a showcase frame around [child].
  const ExtIntShowcase({required this.child, super.key});

  /// The use-case content to display.
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: child,
        ),
      ),
    ),
  );
}

/// Demonstrates [ExtInt.toColor] by composing a 32-bit ARGB integer from four
/// channel sliders and rendering the resulting [Color].
@UseCase(name: 'toColor', type: ExtIntShowcase)
Widget toColorUseCase(BuildContext context) {
  final alpha = context.knobs.int.slider(
    label: 'Alpha',
    initialValue: 0xFF,
    max: 0xFF,
  );
  final red = context.knobs.int.slider(
    label: 'Red',
    initialValue: 0x21,
    max: 0xFF,
  );
  final green = context.knobs.int.slider(
    label: 'Green',
    initialValue: 0x96,
    max: 0xFF,
  );
  final blue = context.knobs.int.slider(
    label: 'Blue',
    initialValue: 0xF3,
    max: 0xFF,
  );

  final argb = (alpha << 24) | (red << 16) | (green << 8) | blue;
  final color = argb.toColor();
  final hex = argb.toRadixString(16).toUpperCase().padLeft(8, '0');

  return ExtIntShowcase(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
        ),
        const SizedBox(height: 16),
        SelectableText(
          '0x$hex.toColor()',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '$argb',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

/// Demonstrates [ExtInt.toSpeech] and [ExtInt.toSimpleSpeech] side by side
/// so the singular/plural switch and sign handling can be explored across
/// negative, zero and positive counts.
@UseCase(name: 'toSpeech / toSimpleSpeech', type: ExtIntShowcase)
Widget toSpeechUseCase(BuildContext context) {
  final count = context.knobs.int.slider(
    label: 'Count',
    initialValue: 1,
    min: -5,
    max: 5,
  );
  final singular = context.knobs.string(
    label: 'Singular',
    initialValue: 'child',
  );
  final plural = context.knobs.string(
    label: 'Plural',
    initialValue: 'children',
  );
  final simpleName = context.knobs.string(
    label: 'Simple name',
    initialValue: 'file',
  );

  final textTheme = Theme.of(context).textTheme;

  return ExtIntShowcase(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResultTile(
          label: "$count.toSpeech(singular: '$singular', plural: '$plural')",
          value: count.toSpeech(singular: singular, plural: plural),
          textTheme: textTheme,
        ),
        const SizedBox(height: 24),
        _ResultTile(
          label: "$count.toSimpleSpeech(name: '$simpleName')",
          value: count.toSimpleSpeech(name: simpleName),
          textTheme: textTheme,
        ),
      ],
    ),
  );
}

/// Demonstrates [ExtInt.toUtc] by converting an editable microsecond epoch
/// value into a UTC [DateTime] and showing the ISO 8601 rendering alongside
/// the local-time equivalent.
@UseCase(name: 'toUtc', type: ExtIntShowcase)
Widget toUtcUseCase(BuildContext context) {
  final micros = context.knobs.int.input(
    label: 'Microseconds since epoch',
    initialValue: 1700000000000000,
  );

  final utc = micros.toUtc();
  final textTheme = Theme.of(context).textTheme;

  return ExtIntShowcase(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResultTile(
          label: '$micros.toUtc()',
          value: utc.toIso8601String(),
          textTheme: textTheme,
        ),
        const SizedBox(height: 24),
        _ResultTile(
          label: 'isUtc',
          value: '${utc.isUtc}',
          textTheme: textTheme,
        ),
        const SizedBox(height: 24),
        _ResultTile(
          label: 'toLocal()',
          value: utc.toLocal().toString(),
          textTheme: textTheme,
        ),
      ],
    ),
  );
}

/// A labelled expression/result pair used by the use cases above.
class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: textTheme.bodySmall),
      const SizedBox(height: 4),
      SelectableText(value, style: textTheme.headlineSmall),
    ],
  );
}
