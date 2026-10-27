// programs/widgetbook_workspace/lib/packages/neon/neon_text.usecase.dart
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
@widgetbook.UseCase(name: 'Interactive', type: NeonText)
Widget buildNeonTextInteractive(BuildContext context) {
  final text = context.knobs.string(
    label: 'Text',
    initialValue: 'OPEN',
  );

  final colorName = context.knobs.object.dropdown<String>(
    label: 'Colour',
    options: _palette.keys.toList(),
    initialOption: 'Green',
  );

  final tint = context.knobs.double.slider(
    label: 'Tint',
    initialValue: 0.45,
    min: 0,
    max: 1,
    divisions: 20,
  );

  final distance = context.knobs.double.slider(
    label: 'Distance',
    initialValue: 0,
    min: 0,
    max: 1,
    divisions: 20,
  );

  final fontSize = context.knobs.double.slider(
    label: 'Font size',
    initialValue: 48,
    min: 12,
    max: 120,
    divisions: 27,
  );

  final maxLines = context.knobs.intOrNull.slider(
    label: 'Max lines',
    initialValue: null,
    min: 1,
    max: 5,
  );

  final overflow = context.knobs.object.dropdown<TextOverflow>(
    label: 'Overflow',
    options: TextOverflow.values,
    initialOption: TextOverflow.ellipsis,
    labelBuilder: (overflow) => overflow.name,
  );

  return _Stage(
    child: NeonText(
      text,
      color: _palette[colorName]!,
      tint: tint,
      distance: distance,
      fontSize: fontSize,
      maxLines: maxLines,
      overflow: overflow,
      package: 'neon',
    ),
  );
}

/// Gallery use case: one sign per palette colour at default settings.
@widgetbook.UseCase(name: 'Colour Gallery', type: NeonText)
Widget buildNeonTextColourGallery(BuildContext context) {
  return _Stage(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: [
        for (final entry in _palette.entries)
          NeonText(
            entry.key.toUpperCase(),
            color: entry.value,
            fontSize: 40,
            package: 'neon',
          ),
      ],
    ),
  );
}

/// Gallery use case: the same sign receding from the viewer.
@widgetbook.UseCase(name: 'Distance Gallery', type: NeonText)
Widget buildNeonTextDistanceGallery(BuildContext context) {
  const steps = [0.0, 0.25, 0.5, 0.75, 1.0];

  return _Stage(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 32,
      children: [
        for (final distance in steps)
          NeonText(
            'DISTANCE ${distance.toStringAsFixed(2)}',
            color: Colors.cyan,
            distance: distance,
            fontSize: 36,
            package: 'neon',
          ),
      ],
    ),
  );
}

/// Gallery use case: overflow behaviours on a width-constrained sign.
@widgetbook.UseCase(name: 'Overflow Gallery', type: NeonText)
Widget buildNeonTextOverflowGallery(BuildContext context) {
  const long = 'OPEN TWENTY FOUR HOURS A DAY SEVEN DAYS A WEEK';

  return _Stage(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 32,
      children: [
        for (final overflow in TextOverflow.values)
          SizedBox(
            width: 320,
            child: NeonText(
              long,
              color: Colors.orange,
              fontSize: 28,
              maxLines: 1,
              overflow: overflow,
              package: 'neon',
            ),
          ),
      ],
    ),
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
