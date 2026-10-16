// programs/widgetbook_workspace/lib/packages/neon/neon_border.usecase.dart
import 'package:flutter/material.dart';
import 'package:neon/neon.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Named colour choices for the interactive knob.
const Map<String, Color> _palette = {
  'Green': Colors.green,
  'Red': Colors.red,
  'Blue': Colors.blue,
  'Pink': Colors.pink,
  'Orange': Colors.orange,
  'Purple': Colors.purple,
  'Cyan': Colors.cyan,
  'Yellow': Colors.yellow,
};

/// Interactive use case: every constructor parameter exposed as a knob.
@widgetbook.UseCase(name: 'Interactive', type: NeonBorder)
Widget buildNeonBorderInteractive(BuildContext context) {
  final colorName = context.knobs.object.dropdown<String>(
    label: 'Colour',
    options: _palette.keys.toList(),
    initialOption: 'Green',
  );

  final width = context.knobs.double.slider(
    label: 'Tube width',
    initialValue: 3,
    min: 1,
    max: 12,
    divisions: 22,
  );

  final radius = context.knobs.double.slider(
    label: 'Corner radius',
    initialValue: 12,
    min: 0,
    max: 64,
    divisions: 32,
  );

  final padding = context.knobs.double.slider(
    label: 'Padding',
    initialValue: 16,
    min: 0,
    max: 64,
    divisions: 32,
  );

  final label = context.knobs.string(
    label: 'Child text',
    initialValue: 'OPEN',
  );

  final color = _palette[colorName]!;

  return _Stage(
    child: NeonBorder(
      color: color,
      width: width,
      radius: radius,
      padding: EdgeInsets.all(padding),
      child: NeonText(label, color: color, package: 'neon'),
    ),
  );
}

/// Gallery use case: one framed sign per palette colour at default settings.
@widgetbook.UseCase(name: 'Colour Gallery', type: NeonBorder)
Widget buildNeonBorderColourGallery(BuildContext context) {
  return _Stage(
    child: Wrap(
      spacing: 48,
      runSpacing: 48,
      alignment: WrapAlignment.center,
      children: [
        for (final entry in _palette.entries)
          NeonBorder(
            color: entry.value,
            child: NeonText(
              entry.key.toUpperCase(),
              color: entry.value,
              fontSize: 32,
              package: 'neon',
            ),
          ),
      ],
    ),
  );
}

/// Gallery use case: the same frame across a range of tube widths.
@widgetbook.UseCase(name: 'Width Gallery', type: NeonBorder)
Widget buildNeonBorderWidthGallery(BuildContext context) {
  const widths = [1.0, 2.0, 3.0, 5.0, 8.0];

  return _Stage(
    child: Wrap(
      spacing: 48,
      runSpacing: 48,
      alignment: WrapAlignment.center,
      children: [
        for (final width in widths)
          NeonBorder(
            color: Colors.cyan,
            width: width,
            child: NeonText(
              'WIDTH ${width.toStringAsFixed(0)}',
              color: Colors.cyan,
              fontSize: 28,
              package: 'neon',
            ),
          ),
      ],
    ),
  );
}

/// Gallery use case: square frames from sharp corners through to a circle.
@widgetbook.UseCase(name: 'Radius Gallery', type: NeonBorder)
Widget buildNeonBorderRadiusGallery(BuildContext context) {
  const side = 140.0;
  const radii = [0.0, 8.0, 24.0, 48.0, side / 2];

  return _Stage(
    child: Wrap(
      spacing: 48,
      runSpacing: 48,
      alignment: WrapAlignment.center,
      children: [
        for (final radius in radii)
          NeonBorder(
            color: Colors.pink,
            radius: radius,
            padding: EdgeInsets.zero,
            child: SizedBox.square(
              dimension: side,
              child: Center(
                child: NeonText(
                  radius.toStringAsFixed(0),
                  color: Colors.pink,
                  fontSize: 32,
                  package: 'neon',
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Composition use case: the fluent extension on an arbitrary child.
@widgetbook.UseCase(name: 'Extension', type: NeonBorder)
Widget buildNeonBorderExtension(BuildContext context) {
  return _Stage(
    child: const Icon(
      Icons.local_bar,
      size: 96,
      color: Colors.white,
    ).withNeonBorder(color: Colors.purple, radius: 32),
  );
}

/// Dark backdrop so the glow reads correctly, shared by every use case.
class _Stage extends StatelessWidget {
  const _Stage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: child,
        ),
      ),
    );
  }
}
